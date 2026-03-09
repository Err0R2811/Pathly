"""Curriculum router — async job-based full roadmap generation.

Endpoints:
  POST /curriculum/request     → enqueue background job, return {job_id}
  GET  /curriculum/status/{id} → poll job status
  GET  /curriculum/{id}        → fetch completed roadmap from DB
"""
from __future__ import annotations
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..schemas import (
    CurriculumRequestBody,
    JobStatusResponse,
    RoadmapResponse,
    ModuleSchema,
    SourceSchema,
)
from ..models import Roadmap, Module, ResearchSource
from ..services.generator import generate_roadmap
from ..services.reviewer import review_roadmap
from ..services.job_store import job_store

router = APIRouter(prefix="/curriculum", tags=["curriculum"])

# ─── Background task ──────────────────────────────────────────────────────────

async def _run_generation_pipeline(
    job_id: str,
    skill_name: str,
    user_id: str,
    max_retries: int,
    db: Session,
) -> None:
    """Full generate → review → retry loop. Saves result to DB on success."""
    job_store.update(job_id, status="RUNNING", progress=10)
    try:
        roadmap = await generate_roadmap(skill_name)
        job_store.update(job_id, progress=40)

        alignment_score = 0
        attempts = 0
        while alignment_score < 85 and attempts < max_retries:
            roadmap = await review_roadmap(roadmap)
            alignment_score = roadmap.get("verification_score", 0)
            attempts += 1
            job_store.update(job_id, progress=40 + int(40 * attempts / max_retries))
            if alignment_score < 85 and attempts < max_retries:
                # Re-generate then re-review
                roadmap = await generate_roadmap(skill_name)

        job_store.update(job_id, progress=85)

        # Persist to DB
        roadmap_id = str(uuid.uuid4())
        db_roadmap = Roadmap(
            id=roadmap_id,
            user_id=user_id,
            skill_name=roadmap["skill_name"],
            domain_type=roadmap.get("domain_type", "technical"),
            verification_score=roadmap.get("verification_score", 0),
            created_at=datetime.now(timezone.utc).isoformat(),
        )
        db.add(db_roadmap)

        for mod in roadmap.get("modules", []):
            mod_id = str(uuid.uuid4())
            db_mod = Module(
                id=mod_id,
                roadmap_id=roadmap_id,
                module_name=mod["module_name"],
                level=mod["level"],
                difficulty_score=mod.get("difficulty_score", 50),
                verification_alignment_score=mod.get("verification_alignment_score", 0),
                estimated_hours=mod.get("estimated_hours", 5),
                pedagogical_basis=mod.get("pedagogical_basis", ""),
            )
            db.add(db_mod)

            for src in mod.get("sources", []):
                db.add(ResearchSource(
                    id=str(uuid.uuid4()),
                    module_id=mod_id,
                    title=src.get("title", ""),
                    doi=src.get("doi"),
                    url=src.get("url"),
                    abstract=src.get("abstract"),
                ))

        db.commit()
        job_store.update(job_id, status="COMPLETED", progress=100, roadmap_id=roadmap_id)

    except Exception as exc:  # noqa: BLE001
        db.rollback()
        job_store.update(job_id, status="FAILED", error=str(exc))


# ─── Endpoints ────────────────────────────────────────────────────────────────

@router.post("/request", response_model=JobStatusResponse, status_code=202)
async def request_curriculum(
    body: CurriculumRequestBody,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
):
    """Kick off a full generate-review pipeline in the background."""
    job_id = str(uuid.uuid4())
    job_store.create(job_id)
    background_tasks.add_task(
        _run_generation_pipeline,
        job_id,
        body.skill_name,
        body.user_id,
        body.max_retries,
        db,
    )
    return JobStatusResponse(job_id=job_id, status="PENDING", progress=0)


@router.get("/status/{job_id}", response_model=JobStatusResponse)
async def get_job_status(job_id: str):
    """Poll the status of a generation job."""
    state = job_store.get(job_id)
    if not state:
        raise HTTPException(status_code=404, detail="Job not found")
    return JobStatusResponse(
        job_id=state.job_id,
        status=state.status,
        progress=state.progress,
        roadmap_id=state.roadmap_id,
        error=state.error,
    )


@router.get("/{roadmap_id}", response_model=RoadmapResponse)
async def get_roadmap(roadmap_id: str, db: Session = Depends(get_db)):
    """Retrieve a completed, verified roadmap from the database."""
    roadmap = db.query(Roadmap).filter(Roadmap.id == roadmap_id).first()
    if not roadmap:
        raise HTTPException(status_code=404, detail="Roadmap not found")

    modules = []
    for mod in roadmap.modules:
        sources = [
            SourceSchema(
                title=s.title,
                doi=s.doi,
                url=s.url,
                abstract=s.abstract,
            )
            for s in mod.sources
        ]
        modules.append(
            ModuleSchema(
                module_name=mod.module_name,
                level=mod.level,
                difficulty_score=mod.difficulty_score or 0,
                verification_alignment_score=mod.verification_alignment_score or 0,
                estimated_hours=mod.estimated_hours or 0,
                pedagogical_basis=mod.pedagogical_basis or "",
                sources=sources,
            )
        )

    return RoadmapResponse(
        id=roadmap.id,
        skill_name=roadmap.skill_name,
        domain_type=roadmap.domain_type,
        verification_score=roadmap.verification_score or 0,
        modules=modules,
    )
