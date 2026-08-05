"""Badges router — badge management and user badge endpoints."""
from __future__ import annotations
from typing import List
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..schemas import BadgeSchema, UserBadgeSchema
from ..models import Badge, UserBadge, User
from .auth import get_current_user
from ..services.achievement import seed_default_badges

router = APIRouter(prefix="/badges", tags=["badges"])


@router.get("/", response_model=List[BadgeSchema])
async def get_all_badges(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all available badges."""
    badges = db.query(Badge).filter(Badge.is_active == True).all()
    return [
        BadgeSchema(
            id=badge.id,
            name=badge.name,
            description=badge.description,
            icon_url=badge.icon_url,
            category=badge.category,
            requirement_type=badge.requirement_type,
            requirement_value=badge.requirement_value,
            is_active=badge.is_active,
        )
        for badge in badges
    ]


@router.get("/my", response_model=List[UserBadgeSchema])
async def get_my_badges(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get current user's earned badges."""
    user_badges = db.query(UserBadge).filter(
        UserBadge.user_id == current_user.id
    ).order_by(UserBadge.earned_at.desc()).all()
    
    result = []
    for ub in user_badges:
        badge = db.query(Badge).filter(Badge.id == ub.badge_id).first()
        result.append(UserBadgeSchema(
            id=ub.id,
            badge_id=ub.badge_id,
            earned_at=ub.earned_at,
            badge=BadgeSchema(
                id=badge.id,
                name=badge.name,
                description=badge.description,
                icon_url=badge.icon_url,
                category=badge.category,
                requirement_type=badge.requirement_type,
                requirement_value=badge.requirement_value,
                is_active=badge.is_active,
            ) if badge else None,
        ))
    
    return result


@router.get("/achievements", response_model=List[dict])
async def get_achievements(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all achievements with user's unlock status."""
    # Get all badges
    all_badges = db.query(Badge).filter(Badge.is_active == True).all()
    
    # Get user's earned badges
    user_badges = db.query(UserBadge).filter(
        UserBadge.user_id == current_user.id
    ).all()
    earned_badge_ids = {ub.badge_id for ub in user_badges}
    
    result = []
    for badge in all_badges:
        is_unlocked = badge.id in earned_badge_ids
        user_badge = next((ub for ub in user_badges if ub.badge_id == badge.id), None)
        
        result.append({
            "id": badge.id,
            "name": badge.name,
            "description": badge.description,
            "icon_name": badge.icon_url or "emoji_events",  # Fallback icon
            "is_unlocked": is_unlocked,
            "unlocked_at": user_badge.earned_at.isoformat() if user_badge else None,
            "category": badge.category,
            "requirement_type": badge.requirement_type,
            "requirement_value": badge.requirement_value
        })
    
    return result


@router.post("/seed")
async def seed_badges(db: Session = Depends(get_db)):
    """Seed default badges (admin endpoint)."""
    seed_default_badges(db)
    return {"message": "Default badges seeded successfully"}
