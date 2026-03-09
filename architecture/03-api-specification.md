# 03 — API Specification (OpenAPI 3.1 Outline)

> REST API · JWT Auth · Versioned · Rate-Limited

---

## API Base

```
Base URL:  https://api.pathly.app/api/v1
Auth:      Bearer <JWT>
Format:    JSON (application/json)
Versioning: URL path (/api/v1, /api/v2)
Rate Limit: 100 req/min (auth), 20 req/min (anon)
```

---

## Auth Service

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| POST | `/auth/register` | Create account (email/password) | ❌ |
| POST | `/auth/login` | Login, returns access + refresh tokens | ❌ |
| POST | `/auth/refresh` | Refresh access token | 🔑 Refresh |
| POST | `/auth/logout` | Invalidate session | ✅ |
| POST | `/auth/forgot-password` | Send reset email | ❌ |
| POST | `/auth/reset-password` | Reset with token | ❌ |
| POST | `/auth/social/{provider}` | OAuth2 (Google/Apple) | ❌ |
| GET  | `/auth/me` | Current user profile | ✅ |

### Register Request
```json
{
  "email": "user@example.com",
  "password": "SecureP@ss123",
  "display_name": "Amit V",
  "timezone": "Asia/Kolkata"
}
```

### Login Response
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "expires_in": 3600,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "display_name": "Amit V",
    "avatar_url": "https://...",
    "level": 5,
    "total_xp": 2340
  }
}
```

---

## User Service

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| GET | `/users/me` | Get current user profile | ✅ |
| PATCH | `/users/me` | Update profile | ✅ |
| GET | `/users/me/stats` | Aggregated stats (XP, streak, level) | ✅ |
| PUT | `/users/me/settings` | Update preferences | ✅ |
| DELETE | `/users/me` | Soft-delete account | ✅ |

---

## Skills & Modules Service

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| GET | `/skills` | List all skills (paginated) | ✅ |
| GET | `/skills/{skill_id}` | Skill detail + modules | ✅ |
| GET | `/skills/{skill_id}/modules` | Modules in a skill | ✅ |
| GET | `/modules/{module_id}` | Module detail + lessons | ✅ |
| GET | `/modules/{module_id}/lessons` | Lessons in a module | ✅ |
| GET | `/lessons/{lesson_id}` | Lesson with steps | ✅ |
| GET | `/lessons/{lesson_id}/steps` | All steps for lesson | ✅ |

### Skill Response
```json
{
  "id": "uuid",
  "title": "Python Fundamentals",
  "description": "Master Python from basics to advanced",
  "icon_url": "https://...",
  "color": "#6C5CE7",
  "total_modules": 12,
  "estimated_hours": 40,
  "difficulty": "beginner",
  "prerequisites": [],
  "tags": ["python", "programming", "beginner"],
  "user_progress": {
    "completed_modules": 3,
    "percent_complete": 25.0,
    "last_activity": "2026-03-01T10:00:00Z"
  }
}
```

### Lesson Step Types
```json
{
  "steps": [
    { "type": "text",       "content": "..." },
    { "type": "code_editor","language": "python", "starter_code": "...", "solution": "..." },
    { "type": "quiz_mcq",   "question": "...", "options": [...], "correct": 2 },
    { "type": "quiz_fill",  "template": "The ___ keyword defines a function", "answer": "def" },
    { "type": "media",      "url": "...", "media_type": "video" },
    { "type": "interactive", "widget_type": "drag_drop", "config": {...} }
  ]
}
```

---

## Progress Service

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| POST | `/progress/complete` | Mark lesson step complete | ✅ |
| GET | `/progress/skills` | Progress across all skills | ✅ |
| GET | `/progress/skills/{skill_id}` | Detailed skill progress | ✅ |
| GET | `/progress/streak` | Current streak info | ✅ |
| GET | `/progress/history` | Activity history (paginated) | ✅ |
| GET | `/progress/heatmap` | Daily activity heatmap data | ✅ |

### Complete Step Request
```json
{
  "lesson_id": "uuid",
  "step_id": "uuid",
  "result": {
    "correct": true,
    "time_spent_seconds": 45,
    "attempts": 1,
    "answer": "def"
  }
}
```

### Complete Step Response
```json
{
  "xp_earned": 15,
  "total_xp": 2355,
  "level_up": false,
  "current_level": 5,
  "streak_count": 7,
  "badges_unlocked": [
    { "id": "uuid", "name": "Week Warrior", "icon": "🔥" }
  ],
  "lesson_complete": false,
  "next_step_id": "uuid"
}
```

---

## Achievement Service

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| GET | `/achievements` | All achievements (unlocked + locked) | ✅ |
| GET | `/achievements/{id}` | Achievement detail | ✅ |
| GET | `/achievements/recent` | Recently unlocked | ✅ |

### Achievement Response
```json
{
  "id": "uuid",
  "name": "First Steps",
  "description": "Complete your first lesson",
  "icon": "🎯",
  "category": "learning",
  "rarity": "common",
  "xp_reward": 50,
  "unlocked": true,
  "unlocked_at": "2026-02-28T15:30:00Z",
  "progress": { "current": 1, "target": 1 }
}
```

---

## Leaderboard Service

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| GET | `/leaderboard/weekly` | Weekly ranking (top 100) | ✅ |
| GET | `/leaderboard/alltime` | All-time ranking | ✅ |
| GET | `/leaderboard/friends` | Friends leaderboard | ✅ |
| GET | `/leaderboard/me` | Current user rank | ✅ |

### Leaderboard Entry
```json
{
  "rank": 1,
  "user": {
    "id": "uuid",
    "display_name": "Priya S",
    "avatar_url": "https://...",
    "level": 12
  },
  "score": 4520,
  "xp_this_week": 890,
  "streak": 14
}
```

---

## AI & Recommendations

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| GET | `/recommendations` | Personalized next lessons | ✅ |
| GET | `/recommendations/skills` | Suggested skills | ✅ |
| POST | `/ai/explain` | LLM-enhanced explanation | ✅ |
| GET | `/search?q=...` | Semantic search across content | ✅ |

---

## Notifications

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| GET | `/notifications` | User notifications (paginated) | ✅ |
| PATCH | `/notifications/{id}/read` | Mark as read | ✅ |
| POST | `/notifications/register-device` | Register push token | ✅ |

---

## Common Patterns

### Pagination
```
GET /skills?page=1&per_page=20&sort=popularity&order=desc
```
```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 156,
    "total_pages": 8
  }
}
```

### Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is already registered",
    "details": [
      { "field": "email", "message": "already exists" }
    ]
  }
}
```

### HTTP Status Codes Used

| Code | Meaning |
|---|---|
| 200 | Success |
| 201 | Created |
| 400 | Validation error |
| 401 | Not authenticated |
| 403 | Not authorized |
| 404 | Not found |
| 409 | Conflict (duplicate) |
| 422 | Unprocessable entity |
| 429 | Rate limited |
| 500 | Server error |
