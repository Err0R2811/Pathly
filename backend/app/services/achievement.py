"""Achievement service — badge rule engine and event triggers."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from ..models import Badge, User, UserBadge


def check_and_award_badges(user: User, db: Session) -> list[Badge]:
    """Check user stats against badge requirements and award new badges."""
    # Get all active badges
    badges = db.query(Badge).filter(Badge.is_active).all()

    # Get user's existing badges
    existing_badge_ids = {ub.badge_id for ub in user.badges}

    newly_awarded = []

    for badge in badges:
        # Skip if user already has this badge
        if badge.id in existing_badge_ids:
            continue

        # Check if badge requirements are met
        if _check_badge_requirement(badge, user):
            # Award the badge
            user_badge = UserBadge(
                id=str(uuid.uuid4()),
                user_id=user.id,
                badge_id=badge.id,
                earned_at=datetime.now(timezone.utc).isoformat(),
            )
            db.add(user_badge)
            newly_awarded.append(badge)

    if newly_awarded:
        db.commit()

    return newly_awarded


def _check_badge_requirement(badge: Badge, user: User) -> bool:
    """Check if a single badge's requirements are met."""
    if badge.requirement_type == "xp_threshold":
        return user.xp >= badge.requirement_value
    elif badge.requirement_type == "streak_days":
        return user.streak_days >= badge.requirement_value
    elif badge.requirement_type == "lessons_completed":
        return user.lessons_completed >= badge.requirement_value
    elif badge.requirement_type == "level_reached":
        return user.level >= badge.requirement_value
    elif badge.requirement_type == "custom":
        # Custom rules would be evaluated here
        # For now, return False as custom rules need more complex logic
        return False

    return False


def seed_default_badges(db: Session) -> None:
    """Seed default badges if they don't exist (idempotent)."""
    default_badges = [
        {
            "id": "badge_first_lesson",
            "name": "First Steps",
            "description": "Complete your first lesson",
            "icon_url": "🎯",
            "category": "lessons",
            "requirement_type": "lessons_completed",
            "requirement_value": 1,
        },
        {
            "id": "badge_10_lessons",
            "name": "Dedicated Learner",
            "description": "Complete 10 lessons",
            "icon_url": "📚",
            "category": "lessons",
            "requirement_type": "lessons_completed",
            "requirement_value": 10,
        },
        {
            "id": "badge_50_lessons",
            "name": "Knowledge Seeker",
            "description": "Complete 50 lessons",
            "icon_url": "🎓",
            "category": "lessons",
            "requirement_type": "lessons_completed",
            "requirement_value": 50,
        },
        {
            "id": "badge_3_day_streak",
            "name": "On Fire",
            "description": "Maintain a 3-day learning streak",
            "icon_url": "🔥",
            "category": "streak",
            "requirement_type": "streak_days",
            "requirement_value": 3,
        },
        {
            "id": "badge_7_day_streak",
            "name": "Week Warrior",
            "description": "Maintain a 7-day learning streak",
            "icon_url": "⚔️",
            "category": "streak",
            "requirement_type": "streak_days",
            "requirement_value": 7,
        },
        {
            "id": "badge_30_day_streak",
            "name": "Monthly Master",
            "description": "Maintain a 30-day learning streak",
            "icon_url": "👑",
            "category": "streak",
            "requirement_type": "streak_days",
            "requirement_value": 30,
        },
        {
            "id": "badge_100_xp",
            "name": "Rising Star",
            "description": "Earn 100 XP",
            "icon_url": "⭐",
            "category": "xp",
            "requirement_type": "xp_threshold",
            "requirement_value": 100,
        },
        {
            "id": "badge_1000_xp",
            "name": "XP Champion",
            "description": "Earn 1,000 XP",
            "icon_url": "🏆",
            "category": "xp",
            "requirement_type": "xp_threshold",
            "requirement_value": 1000,
        },
        {
            "id": "badge_level_5",
            "name": "Apprentice",
            "description": "Reach level 5",
            "icon_url": "🔧",
            "category": "level",
            "requirement_type": "level_reached",
            "requirement_value": 5,
        },
        {
            "id": "badge_level_10",
            "name": "Journeyman",
            "description": "Reach level 10",
            "icon_url": "🛠️",
            "category": "level",
            "requirement_type": "level_reached",
            "requirement_value": 10,
        },
    ]

    for badge_data in default_badges:
        existing = db.query(Badge).filter(Badge.id == badge_data["id"]).first()
        if not existing:
            badge = Badge(**badge_data)
            db.add(badge)

    db.commit()
