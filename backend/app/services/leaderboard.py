"""Leaderboard service — Redis-based ranking system."""

from __future__ import annotations

import os

import redis

# Redis connection
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
REDIS_DB = int(os.getenv("REDIS_DB", 0))

# Key patterns
WEEKLY_LEADERBOARD_KEY = "leaderboard:weekly"
MONTHLY_LEADERBOARD_KEY = "leaderboard:monthly"
ALL_TIME_LEADERBOARD_KEY = "leaderboard:all_time"


def get_redis_client() -> redis.Redis:
    """Get Redis client instance."""
    try:
        return redis.Redis(
            host=REDIS_HOST,
            port=REDIS_PORT,
            db=REDIS_DB,
            decode_responses=True,
        )
    except Exception:
        # Return None if Redis is not available (graceful degradation)
        return None


def update_leaderboard(user_id: str, xp: int) -> None:
    """Update user's score in all leaderboards."""
    r = get_redis_client()
    if not r:
        return  # Skip if Redis is not available

    try:
        # Update all-time leaderboard
        r.zadd(ALL_TIME_LEADERBOARD_KEY, {user_id: xp})

        # Update weekly leaderboard (expires after 7 days)
        r.zadd(WEEKLY_LEADERBOARD_KEY, {user_id: xp})
        r.expire(WEEKLY_LEADERBOARD_KEY, 7 * 24 * 60 * 60)

        # Update monthly leaderboard (expires after 30 days)
        r.zadd(MONTHLY_LEADERBOARD_KEY, {user_id: xp})
        r.expire(MONTHLY_LEADERBOARD_KEY, 30 * 24 * 60 * 60)
    except Exception:
        # Silently fail if Redis operations fail
        pass


def get_leaderboard(leaderboard_type: str = "all_time", limit: int = 100, offset: int = 0) -> list[dict]:
    """Get leaderboard entries sorted by score (descending)."""
    r = get_redis_client()
    if not r:
        return []  # Return empty if Redis is not available

    try:
        key = {
            "weekly": WEEKLY_LEADERBOARD_KEY,
            "monthly": MONTHLY_LEADERBOARD_KEY,
            "all_time": ALL_TIME_LEADERBOARD_KEY,
        }.get(leaderboard_type, ALL_TIME_LEADERBOARD_KEY)

        # Get top users with scores (descending order)
        results = r.zrevrange(key, offset, offset + limit - 1, withscores=True)

        return [
            {"user_id": user_id, "score": int(score), "rank": offset + i + 1}
            for i, (user_id, score) in enumerate(results)
        ]
    except Exception:
        return []


def get_user_rank(user_id: str, leaderboard_type: str = "all_time") -> int | None:
    """Get user's rank in a specific leaderboard."""
    r = get_redis_client()
    if not r:
        return None

    try:
        key = {
            "weekly": WEEKLY_LEADERBOARD_KEY,
            "monthly": MONTHLY_LEADERBOARD_KEY,
            "all_time": ALL_TIME_LEADERBOARD_KEY,
        }.get(leaderboard_type, ALL_TIME_LEADERBOARD_KEY)

        rank = r.zrevrank(key, user_id)
        return rank + 1 if rank is not None else None
    except Exception:
        return None
