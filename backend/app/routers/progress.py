"""Progress tracking router — track user learning progress."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Module, Roadmap, User, UserProgress
from ..schemas import UserResponse
from ..services.achievement import check_and_award_badges
from ..services.leaderboard import update_leaderboard
from .auth import get_current_user

router = APIRouter(prefix="/progress", tags=["progress"])


def update_streak(user: User) -> None:
    """Update user streak based on last activity date."""
    today = datetime.now(timezone.utc).date()

    if user.last_activity_date:
        last_activity = datetime.fromisoformat(user.last_activity_date).date()
        days_diff = (today - last_activity).days

        if days_diff == 1:
            # Consecutive day - increment streak
            user.streak_days += 1
        elif days_diff > 1:
            # Streak broken - reset to 1 (today's activity)
            user.streak_days = 1
        # If days_diff == 0, same day - no change
    else:
        # First activity - start streak
        user.streak_days = 1

    user.last_activity_date = today.isoformat()


def award_lesson_completion_xp(user: User, xp_earned: int, db: Session) -> dict:
    """Shared logic for awarding XP, updating streak, badges, leaderboard, and level on lesson completion."""
    # Update user stats
    user.xp += xp_earned
    user.lessons_completed += 1

    # Update streak
    update_streak(user)

    # Check for new badges
    new_badges = check_and_award_badges(user, db)

    # Update leaderboard
    update_leaderboard(user.id, user.xp)

    # Level up every 500 XP
    new_level = (user.xp // 500) + 1
    level_up = False
    if new_level > user.level:
        user.level = new_level
        level_up = True
        # Update title based on level
        titles = {
            1: "Beginner",
            5: "Apprentice",
            10: "Journeyman",
            20: "Expert",
            30: "Master",
            50: "Grandmaster",
        }
        for level_threshold, title in sorted(titles.items()):
            if user.level >= level_threshold:
                user.title = title

    db.commit()

    return {
        "xp_earned": xp_earned,
        "total_xp": user.xp,
        "level": user.level,
        "level_up": level_up,
        "streak_days": user.streak_days,
        "new_badges": new_badges,
    }


@router.get("/user-stats", response_model=dict)
async def get_user_stats(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Get comprehensive user statistics including XP, level, streak, and progress."""
    # Get user's active roadmap progress
    active_progress = (
        db.query(UserProgress)
        .filter(UserProgress.user_id == current_user.id)
        .order_by(UserProgress.completed_at.desc())
        .first()
    )

    # Calculate total lessons across all roadmaps
    total_lessons_completed = db.query(UserProgress).filter(UserProgress.user_id == current_user.id).count()

    # Get current skill (from most recent roadmap)
    current_skill = "No active course"
    current_roadmap_id = None
    current_module_id = None
    lessons_in_current_roadmap = 0
    completed_in_current_roadmap = 0

    if active_progress:
        roadmap = db.query(Roadmap).filter(Roadmap.id == active_progress.roadmap_id).first()
        if roadmap:
            current_skill = roadmap.skill_name
            current_roadmap_id = roadmap.id
            current_module_id = active_progress.module_id

            # Count total modules in this roadmap
            modules_in_roadmap = db.query(Module).filter(Module.roadmap_id == roadmap.id).all()
            lessons_in_current_roadmap = len(modules_in_roadmap)

            # Count completed modules in this roadmap
            completed_modules = (
                db.query(UserProgress)
                .filter(UserProgress.user_id == current_user.id, UserProgress.roadmap_id == roadmap.id)
                .count()
            )
            completed_in_current_roadmap = completed_modules

    # Calculate XP to next level
    xp_to_next_level = ((current_user.level + 1) * 500) - current_user.xp
    level_progress = (current_user.xp % 500) / 500 if current_user.xp > 0 else 0

    return {
        "current_skill": current_skill,
        "current_roadmap_id": current_roadmap_id,
        "current_module_id": current_module_id,
        "lessons_completed": total_lessons_completed,
        "total_lessons": lessons_in_current_roadmap,
        "completed_in_current_roadmap": completed_in_current_roadmap,
        "progress_percentage": int(
            (completed_in_current_roadmap / lessons_in_current_roadmap * 100) if lessons_in_current_roadmap > 0 else 0
        ),
        "streak_days": current_user.streak_days,
        "total_minutes": current_user.total_minutes,
        "xp": current_user.xp,
        "level": current_user.level,
        "xp_to_next_level": max(0, xp_to_next_level),
        "level_progress": level_progress,
        "title": current_user.title or "Beginner",
    }


@router.get("/daily-goal", response_model=dict)
async def get_daily_goal(current_user: User = Depends(get_current_user)):
    """Get daily learning goal status."""
    target_minutes = 15  # Default daily goal
    completed_minutes = current_user.total_minutes % 60  # Minutes today (simplified)

    return {
        "target_minutes": target_minutes,
        "completed_minutes": completed_minutes,
        "lessons_completed": current_user.lessons_completed,
        "streak_days": current_user.streak_days,
        "is_goal_met": completed_minutes >= target_minutes,
        "progress": completed_minutes / target_minutes if target_minutes > 0 else 0,
    }


class ProgressCreateRequest(BaseModel):
    roadmap_id: str
    module_id: str | None = None
    lesson_id: str | None = None
    xp_earned: int = 10


class ProgressResponse(BaseModel):
    id: str
    user_id: str
    roadmap_id: str
    module_id: str | None
    lesson_id: str | None
    completed_at: str
    xp_earned: int


class UserStatsResponse(BaseModel):
    user: UserResponse
    total_roadmaps: int
    total_modules_completed: int
    total_lessons_completed: int
    recent_progress: list[ProgressResponse]


@router.post("/complete", response_model=ProgressResponse, status_code=201)
async def complete_lesson(
    body: ProgressCreateRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    """Record a lesson/module completion and award XP."""
    # Verify roadmap exists
    roadmap = db.query(Roadmap).filter(Roadmap.id == body.roadmap_id).first()
    if not roadmap:
        raise HTTPException(status_code=404, detail="Roadmap not found")

    # Create progress record
    progress_id = str(uuid.uuid4())
    progress = UserProgress(
        id=progress_id,
        user_id=current_user.id,
        roadmap_id=body.roadmap_id,
        module_id=body.module_id,
        lesson_id=body.lesson_id,
        xp_earned=body.xp_earned,
        completed_at=datetime.now(timezone.utc).isoformat(),
    )

    db.add(progress)

    # Use shared XP awarding logic
    award_lesson_completion_xp(current_user, body.xp_earned, db)

    db.refresh(progress)

    return ProgressResponse(
        id=progress.id,
        user_id=progress.user_id,
        roadmap_id=progress.roadmap_id,
        module_id=progress.module_id,
        lesson_id=progress.lesson_id,
        completed_at=progress.completed_at,
        xp_earned=progress.xp_earned,
    )


@router.get("/user", response_model=UserStatsResponse)
async def get_user_progress(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Get current user progress and statistics."""
    # Get all progress for user
    progress_records = (
        db.query(UserProgress)
        .filter(UserProgress.user_id == current_user.id)
        .order_by(UserProgress.completed_at.desc())
        .limit(20)
        .all()
    )

    # Count unique roadmaps and modules
    total_roadmaps = (
        db.query(UserProgress).filter(UserProgress.user_id == current_user.id).distinct(UserProgress.roadmap_id).count()
    )

    total_modules_completed = (
        db.query(UserProgress)
        .filter(UserProgress.user_id == current_user.id, UserProgress.module_id.isnot(None))
        .distinct(UserProgress.module_id)
        .count()
    )

    total_lessons_completed = current_user.lessons_completed

    recent_progress = [
        ProgressResponse(
            id=p.id,
            user_id=p.user_id,
            roadmap_id=p.roadmap_id,
            module_id=p.module_id,
            lesson_id=p.lesson_id,
            completed_at=p.completed_at,
            xp_earned=p.xp_earned,
        )
        for p in progress_records
    ]

    return UserStatsResponse(
        user=UserResponse(
            id=current_user.id,
            email=current_user.email,
            name=current_user.name,
            avatar_url=current_user.avatar_url,
            title=current_user.title,
            level=current_user.level,
            xp=current_user.xp,
            streak_days=current_user.streak_days,
            total_minutes=current_user.total_minutes,
            lessons_completed=current_user.lessons_completed,
            created_at=current_user.created_at,
        ),
        total_roadmaps=total_roadmaps,
        total_modules_completed=total_modules_completed,
        total_lessons_completed=total_lessons_completed,
        recent_progress=recent_progress,
    )


@router.get("/roadmap/{roadmap_id}")
async def get_roadmap_progress(
    roadmap_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    """Get progress for a specific roadmap for current user."""
    progress_records = (
        db.query(UserProgress)
        .filter(UserProgress.roadmap_id == roadmap_id, UserProgress.user_id == current_user.id)
        .all()
    )

    completed_modules = set()
    completed_lessons = []
    total_xp = 0

    for p in progress_records:
        if p.module_id:
            completed_modules.add(p.module_id)
        if p.lesson_id:
            completed_lessons.append(p.lesson_id)
        total_xp += p.xp_earned

    return {
        "roadmap_id": roadmap_id,
        "user_id": current_user.id,
        "completed_modules": list(completed_modules),
        "completed_lessons": completed_lessons,
        "total_xp_earned": total_xp,
        "completion_count": len(progress_records),
    }
