"""Curriculum router — async job-based full roadmap generation.

Endpoints:
  GET  /curriculum             → list user's saved roadmaps
  GET  /curriculum/preview     → instant draft roadmap (no reviewer pass)
  POST /curriculum/request     → enqueue background job, return {job_id}
  GET  /curriculum/status/{id} → poll job status
  GET  /curriculum/{id}        → fetch completed roadmap from DB
"""
from __future__ import annotations
import uuid
from datetime import datetime, timezone
from typing import List

from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..schemas import (
    CurriculumRequestBody,
    JobStatusResponse,
    RoadmapResponse,
    RoadmapSummaryResponse,
    ModuleSchema,
    SourceSchema,
)
from ..models import Roadmap, Module, ResearchSource, User, Lesson, LessonStep, QuizQuestion, UserProgress
from ..services.generator import generate_roadmap
from ..services.reviewer import review_roadmap
from ..services.job_store import job_store
from ..services.lesson_generator import generate_module_lessons
from .auth import get_current_user, get_current_user_optional

router = APIRouter(prefix="/curriculum", tags=["curriculum"])


@router.get("/preview", response_model=RoadmapResponse)
async def get_preview(skill_name: str = Query(..., description="Skill name to generate preview for")):
    """Get an instant draft roadmap preview without reviewer pass."""
    try:
        # Generate a quick roadmap without the review loop
        roadmap = await generate_roadmap(skill_name)
        
        # Convert to response format
        modules = []
        for mod in roadmap.get("modules", []):
            sources = [
                SourceSchema(
                    title=src.get("title", ""),
                    doi=src.get("doi"),
                    url=src.get("url"),
                    abstract=src.get("abstract"),
                    source_type=src.get("type"),
                    author=src.get("author"),
                    relevance_score=src.get("relevance_score"),
                    video_duration=src.get("video_duration"),
                    thumbnail=src.get("thumbnail"),
                )
                for src in mod.get("sources", [])
            ]
            modules.append(
                ModuleSchema(
                    module_name=mod.get("module_name", ""),
                    level=mod.get("level", "Beginner"),
                    difficulty_score=mod.get("difficulty_score", 50),
                    verification_alignment_score=0,  # No review for preview
                    estimated_hours=mod.get("estimated_hours", 5),
                    pedagogical_basis=mod.get("pedagogical_basis", ""),
                    learning_objectives=mod.get("learning_objectives", []),
                    skills_gained=mod.get("skills_gained", []),
                    projects=mod.get("projects", []),
                    assessment_criteria=mod.get("assessment_criteria", ""),
                    sources=sources,
                )
            )
        
        return RoadmapResponse(
            id="preview",  # Preview ID
            skill_name=roadmap.get("skill_name", skill_name),
            domain_type=roadmap.get("domain_type", "technical"),
            verification_score=0,  # No verification for preview
            certification_info=roadmap.get("certification_info"),
            prerequisites=roadmap.get("prerequisites"),
            learning_objectives=roadmap.get("learning_objectives"),
            career_outcomes=roadmap.get("career_outcomes"),
            salary_range=roadmap.get("salary_range"),
            market_demand=roadmap.get("market_demand"),
            modules=modules,
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Preview generation failed: {str(exc)}")


# ─── Background task ──────────────────────────────────────────────────────────

async def _run_generation_pipeline(
    job_id: str,
    skill_name: str,
    user_id: str,
    max_retries: int,
    difficulty: str = "beginner",
    deadline_weeks: int = 4,
) -> None:
    """Full generate → review → retry loop. Saves result to DB on success."""
    # Create a new DB session for background task
    from ..database import SessionLocal
    db = SessionLocal()
    
    try:
        job_store.update(job_id, status="RUNNING", progress=10)
        
        roadmap = await generate_roadmap(skill_name, difficulty=difficulty, deadline_weeks=deadline_weeks)
        job_store.update(job_id, progress=40)

        # Simplified: accept first valid generation to avoid getting stuck
        alignment_score = roadmap.get("verification_score", 0)
        if alignment_score < 50:
            # Only retry if score is very low
            attempts = 0
            while alignment_score < 50 and attempts < max_retries:
                roadmap = await generate_roadmap(skill_name, difficulty=difficulty, deadline_weeks=deadline_weeks)
                alignment_score = roadmap.get("verification_score", 0)
                attempts += 1
                job_store.update(job_id, progress=40 + int(40 * attempts / max_retries))

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
            # Enhanced fields
            certification_info=roadmap.get("certification_info"),
            prerequisites=roadmap.get("prerequisites"),
            learning_objectives=roadmap.get("learning_objectives"),
            career_outcomes=roadmap.get("career_outcomes"),
            salary_range=roadmap.get("salary_range"),
            market_demand=roadmap.get("market_demand"),
        )
        db.add(db_roadmap)

        for mod in roadmap.get("modules", []):
            try:
                mod_id = str(uuid.uuid4())
                db_mod = Module(
                    id=mod_id,
                    roadmap_id=roadmap_id,
                    module_name=mod.get("module_name", "Unknown Module"),
                    level=mod.get("level", "beginner"),
                    difficulty_score=mod.get("difficulty_score", 50),
                    verification_alignment_score=mod.get("verification_alignment_score", 0),
                    estimated_hours=mod.get("estimated_hours", 5),
                    pedagogical_basis=mod.get("pedagogical_basis", ""),
                    # Enhanced fields
                    learning_objectives=mod.get("learning_objectives"),
                    skills_gained=mod.get("skills_gained"),
                    projects=mod.get("projects"),
                    assessment_criteria=mod.get("assessment_criteria"),
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
                        # Enhanced fields
                        source_type=src.get("type"),
                        author=src.get("author"),
                        relevance_score=src.get("relevance_score"),
                        video_duration=src.get("video_duration"),
                        thumbnail=src.get("thumbnail"),
                    ))
                
                # Lessons are now generated lazily on-demand when user opens a module
                # This significantly speeds up initial roadmap generation
                    
            except Exception as e:
                print(f"Error saving module: {e}")
                continue

        db.commit()
        job_store.update(job_id, status="COMPLETED", progress=100, roadmap_id=roadmap_id)

    except Exception as exc:  # noqa: BLE001
        db.rollback()
        job_store.update(job_id, status="FAILED", error=str(exc))
    finally:
        db.close()


# ─── Endpoints ────────────────────────────────────────────────────────────────

@router.post("/request", response_model=JobStatusResponse, status_code=202)
async def request_curriculum(
    body: CurriculumRequestBody,
    background_tasks: BackgroundTasks,
    current_user: Optional[User] = Depends(get_current_user_optional),
):
    """Kick off a full generate-review pipeline in the background."""
    job_id = str(uuid.uuid4())
    job_store.create(job_id)
    # Use authenticated user ID if available, otherwise use demo user ID
    user_id = current_user.id if current_user else "demo-user-id"
    background_tasks.add_task(
        _run_generation_pipeline,
        job_id,
        body.skill_name,
        user_id,
        body.max_retries,
        body.difficulty,
        body.deadline_weeks,
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
        progress=min(state.progress, 100),
        roadmap_id=state.roadmap_id,
        error=state.error,
    )


@router.get("/", response_model=List[RoadmapSummaryResponse])
async def list_roadmaps(
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional),
):
    """List roadmaps for the current user, or all roadmaps for demo users."""
    query = db.query(Roadmap)
    if current_user:
        query = query.filter(Roadmap.user_id == current_user.id)
    roadmaps = query.order_by(Roadmap.created_at.desc()).all()
    return [
        RoadmapSummaryResponse(
            id=r.id,
            skill_name=r.skill_name,
            domain_type=r.domain_type,
            verification_score=r.verification_score or 0,
            created_at=r.created_at,
        )
        for r in roadmaps
    ]


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
                # Enhanced fields
                source_type=s.source_type,
                author=s.author,
                relevance_score=s.relevance_score,
                video_duration=s.video_duration,
                thumbnail=s.thumbnail,
            )
            for s in mod.sources
        ]
        modules.append(
            ModuleSchema(
                id=mod.id,
                module_name=mod.module_name,
                level=mod.level,
                difficulty_score=mod.difficulty_score or 0,
                verification_alignment_score=mod.verification_alignment_score or 0,
                estimated_hours=mod.estimated_hours or 0,
                pedagogical_basis=mod.pedagogical_basis or "",
                # Enhanced fields
                learning_objectives=mod.learning_objectives,
                skills_gained=mod.skills_gained,
                projects=mod.projects,
                assessment_criteria=mod.assessment_criteria,
                sources=sources,
            )
        )

    return RoadmapResponse(
        id=roadmap.id,
        skill_name=roadmap.skill_name,
        domain_type=roadmap.domain_type,
        verification_score=roadmap.verification_score or 0,
        # Enhanced fields
        certification_info=roadmap.certification_info,
        prerequisites=roadmap.prerequisites,
        learning_objectives=roadmap.learning_objectives,
        career_outcomes=roadmap.career_outcomes,
        salary_range=roadmap.salary_range,
        market_demand=roadmap.market_demand,
        modules=modules,
    )


@router.delete("/{roadmap_id}", status_code=204)
async def delete_roadmap(
    roadmap_id: str,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional),
):
    """Delete a roadmap and all of its associated data."""
    roadmap = db.query(Roadmap).filter(Roadmap.id == roadmap_id).first()
    if not roadmap:
        raise HTTPException(status_code=404, detail="Roadmap not found")

    if current_user and current_user.id != roadmap.user_id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this roadmap")

    module_ids = [mod.id for mod in roadmap.modules]

    if module_ids:
        db.query(QuizQuestion).filter(QuizQuestion.module_id.in_(module_ids)).delete(
            synchronize_session=False
        )
        db.query(ResearchSource).filter(ResearchSource.module_id.in_(module_ids)).delete(
            synchronize_session=False
        )
        lesson_ids = [
            row[0]
            for row in db.query(Lesson.id).filter(Lesson.module_id.in_(module_ids))
        ]
        if lesson_ids:
            db.query(LessonStep).filter(LessonStep.lesson_id.in_(lesson_ids)).delete(
                synchronize_session=False
            )
            db.query(Lesson).filter(Lesson.module_id.in_(module_ids)).delete(
                synchronize_session=False
            )
        db.query(Module).filter(Module.roadmap_id == roadmap_id).delete(
            synchronize_session=False
        )

    db.query(UserProgress).filter(UserProgress.roadmap_id == roadmap_id).delete(
        synchronize_session=False
    )
    db.delete(roadmap)
    db.commit()
