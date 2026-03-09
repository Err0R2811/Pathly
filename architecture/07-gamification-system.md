# 07 — Gamification System Design

> XP · Levels · Badges · Streaks · Leaderboard · Decay

---

## XP System

### XP Sources

| Action | XP | Multiplier |
|---|---|---|
| Complete a lesson step | 5–15 | 1.0× |
| Complete a full lesson | 25 bonus | 1.0× |
| Complete a module | 100 bonus | 1.0× |
| Correct quiz answer (first try) | +5 bonus | — |
| Daily streak bonus | +10 × streak_day | up to 7× |
| Perfect lesson (no mistakes) | 2.0× on lesson XP | — |
| Speed bonus (< 50% estimated time) | 1.5× | — |

### XP Calculation
```python
def calculate_xp(step: LessonStep, result: StepResult, streak: int) -> int:
    base_xp = step.xp_value

    # Accuracy bonus
    if result.correct and result.attempts == 1:
        base_xp += 5

    # Streak multiplier (caps at 7-day bonus)
    streak_mult = 1.0 + min(streak, 7) * 0.1  # 1.0 → 1.7

    # Speed bonus
    if result.time_spent < step.estimated_time * 0.5:
        base_xp = int(base_xp * 1.5)

    return int(base_xp * streak_mult)
```

---

## Level System

### Level Thresholds (Logarithmic Curve)

```
Level  1:        0 XP     Level 11:  5,000 XP
Level  2:      100 XP     Level 15: 10,000 XP
Level  3:      250 XP     Level 20: 25,000 XP
Level  5:      750 XP     Level 30: 75,000 XP
Level  7:    1,500 XP     Level 50: 250,000 XP
Level 10:    3,500 XP     Level 99: 1,000,000 XP
```

### Formula
```python
def xp_for_level(level: int) -> int:
    """XP required to reach this level."""
    if level <= 1:
        return 0
    return int(100 * (level ** 1.8))

def level_from_xp(total_xp: int) -> int:
    """Current level based on total XP."""
    level = 1
    while xp_for_level(level + 1) <= total_xp:
        level += 1
    return level
```

### Level Titles

| Level Range | Title | Icon |
|---|---|---|
| 1–4 | Novice | 🌱 |
| 5–9 | Apprentice | 📘 |
| 10–14 | Student | 🎓 |
| 15–19 | Scholar | 📚 |
| 20–29 | Expert | ⭐ |
| 30–39 | Master | 💎 |
| 40–49 | Grandmaster | 👑 |
| 50+ | Legend | 🏆 |

---

## Badge / Achievement System

### Badge Categories

| Category | Examples |
|---|---|
| **Learning** | First Lesson, Module Master, Skill Champion |
| **Streak** | 3-Day Streak, Week Warrior, Month Master, 100-Day Legend |
| **Speed** | Speed Demon (5 lessons in 1 hour) |
| **Accuracy** | Perfectionist (10 perfect lessons in a row) |
| **Social** | Friendly (added 5 friends), Team Player |
| **Milestone** | 100 Lessons, 1000 XP, Level 10 |
| **Special** | Early Bird, Night Owl, Weekend Warrior |

### Badge Rarity

| Rarity | Color | % of Users |
|---|---|---|
| Common | 🟢 Gray | >50% |
| Uncommon | 🔵 Green | 20–50% |
| Rare | 🟣 Blue | 5–20% |
| Epic | 🟠 Purple | 1–5% |
| Legendary | 🟡 Gold | <1% |

### Rule Engine
```python
# achievements.unlock_rules (JSONB)
{
    "type": "lessons_completed",
    "threshold": 10,
    "conditions": {
        "skill_id": null,          # Any skill (null = global)
        "consecutive_perfect": false
    }
}

# Rule types:
# - lessons_completed     : Total lessons finished
# - streak_days           : Consecutive active days
# - total_xp              : Cumulative XP threshold
# - level_reached         : Minimum level
# - modules_completed     : Modules finished
# - perfect_lessons       : Lessons with 100% accuracy
# - speed_completions     : Lessons under time target
# - login_streak          : Consecutive daily logins
```

---

## Streak Mechanics

### Rules
1. A streak increments when a user completes ≥1 lesson step in a calendar day (user's timezone)
2. A streak breaks if no activity for an entire calendar day
3. **Streak Freeze** (future): 1 free freeze per week; additional via XP purchase
4. **Recovery Window**: 2-hour grace period after midnight

### Streak Risk Detection
```python
def check_streak_risk(user: User, streak: Streak) -> StreakRisk:
    now = datetime.now(tz=user.timezone)
    last = streak.last_activity_date

    if last == now.date():
        return StreakRisk.SAFE                # Already active today

    hours_remaining = (midnight(now) - now).total_seconds() / 3600

    if hours_remaining < 2:
        return StreakRisk.CRITICAL            # < 2 hours left
    elif hours_remaining < 6:
        return StreakRisk.AT_RISK             # < 6 hours left
    else:
        return StreakRisk.SAFE
```

### Notifications
- **AT_RISK** → Push: "Don't lose your 🔥 {N}-day streak! Complete a quick lesson."
- **CRITICAL** → Push: "⚠️ Only {X}h left to save your streak!"
- **BROKEN** → Push: "Your streak ended at {N} days. Start fresh today! 💪"

---

## Leaderboard System

### Ranking Algorithm

Leaderboard uses a **weighted score** with a **decay function** for inactivity:

```python
def calculate_score(user: User, period: str) -> float:
    """
    Score = (XP earned in period) × activity_multiplier × recency_weight
    """
    xp_in_period = get_xp_earned_in_period(user.id, period)

    # Activity multiplier: reward consistency
    active_days = get_active_days_in_period(user.id, period)
    total_days = get_period_length(period)
    activity_mult = 1.0 + (active_days / total_days) * 0.5  # 1.0 → 1.5

    # Recency weight: decay for inactivity
    days_since_last = (today() - user.last_activity_date).days
    decay = max(0.5, 1.0 - (days_since_last * 0.05))  # 5% decay per day, floor 50%

    return xp_in_period * activity_mult * decay
```

### Leaderboard Periods

| Period | Reset Cycle | Visibility |
|---|---|---|
| Weekly | Every Monday 00:00 UTC | Primary |
| Monthly | 1st of month | Secondary |
| All-Time | Never resets | Profile stat |

### League System (Future)
```
🥉 Bronze  → Silver → 🥈 Gold → 💎 Platinum → 👑 Diamond
Top 10 promote, bottom 10 demote each week
```

### Implementation (Redis Sorted Sets)
```python
# Real-time leaderboard using Redis ZADD/ZRANK
await redis.zadd("leaderboard:weekly:2026-W09", {user_id: score})
rank = await redis.zrevrank("leaderboard:weekly:2026-W09", user_id)
top_100 = await redis.zrevrange("leaderboard:weekly:2026-W09", 0, 99, withscores=True)
```
