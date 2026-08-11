"""Search router — semantic search over roadmaps and modules."""

from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import User
from ..services.semantic_search import fallback_search, search
from .auth import get_current_user

router = APIRouter(prefix="/search", tags=["search"])


@router.get("/")
async def search_content(
    q: str = Query(..., description="Search query"),
    limit: int = Query(10, ge=1, le=50),
    content_type: str | None = Query(None, description="Filter by content type: roadmap or module"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Search for roadmaps and modules using semantic similarity."""
    # Try semantic search first
    results = search(q, limit, content_type)

    # Fallback to keyword search if Qdrant is unavailable
    if not results:
        results = fallback_search(q, db)

    return {
        "query": q,
        "results": results,
        "count": len(results),
        "search_type": "semantic" if results else "keyword_fallback",
    }
