"""Updated preview router — calls the real generator now."""

from fastapi import APIRouter, Query

from ..schemas import RoadmapPreviewResponse
from ..services.generator import generate_roadmap

router = APIRouter(tags=["preview"])


@router.get("/curriculum/preview", response_model=RoadmapPreviewResponse)
async def preview_curriculum(
    skill_name: str = Query(..., description="Name of the skill to generate a curriculum preview for"),
):
    """Return an instant draft roadmap preview (no reviewer pass).
    Calls Ollama if available, falls back to a rich static roadmap otherwise.
    """
    roadmap = await generate_roadmap(skill_name)
    return roadmap
