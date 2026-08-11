"""Leaderboard router — ranking endpoints."""

from __future__ import annotations

from fastapi import APIRouter, Depends, Query

from ..models import User
from ..services.leaderboard import get_leaderboard, get_user_rank
from .auth import get_current_user

router = APIRouter(prefix="/leaderboard", tags=["leaderboard"])


@router.get("/")
async def get_leaderboard_endpoint(
    leaderboard_type: str = Query("all_time", description="weekly, monthly, or all_time"),
    limit: int = Query(100, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    """Get leaderboard entries."""
    entries = get_leaderboard(leaderboard_type, limit, offset)

    # Enrich with user names if available
    from ..database import SessionLocal

    db = SessionLocal()
    try:
        user_ids = [e["user_id"] for e in entries]
        users = db.query(User).filter(User.id.in_(user_ids)).all()
        user_map = {u.id: u.name for u in users}

        for entry in entries:
            entry["user_name"] = user_map.get(entry["user_id"], "Unknown")
    finally:
        db.close()

    return {
        "leaderboard_type": leaderboard_type,
        "entries": entries,
        "count": len(entries),
    }


@router.get("/my-rank")
async def get_my_rank(
    leaderboard_type: str = Query("all_time", description="weekly, monthly, or all_time"),
    current_user: User = Depends(get_current_user),
):
    """Get current user's rank in the leaderboard."""
    rank = get_user_rank(current_user.id, leaderboard_type)

    return {
        "user_id": current_user.id,
        "user_name": current_user.name,
        "leaderboard_type": leaderboard_type,
        "rank": rank,
    }
