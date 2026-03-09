"""Pydantic schemas for all API request and response bodies."""
from __future__ import annotations
from pydantic import BaseModel, Field
from typing import List, Optional


class SourceSchema(BaseModel):
    title: str
    doi: Optional[str] = None
    url: Optional[str] = None
    abstract: Optional[str] = None


class ModuleSchema(BaseModel):
    module_name: str
    level: str
    difficulty_score: int = Field(ge=0, le=100)
    verification_alignment_score: int = Field(ge=0, le=100, default=0)
    estimated_hours: int
    pedagogical_basis: str
    sources: List[SourceSchema] = []


class RoadmapPreviewResponse(BaseModel):
    skill_name: str
    domain_type: str
    verification_score: int = 0
    modules: List[ModuleSchema]


class CurriculumRequestBody(BaseModel):
    skill_name: str
    user_id: str = "anonymous"
    max_retries: int = Field(default=3, ge=1, le=5)


class JobStatusResponse(BaseModel):
    job_id: str
    status: str  # PENDING | RUNNING | COMPLETED | FAILED
    progress: int = Field(ge=0, le=100, default=0)
    roadmap_id: Optional[str] = None
    error: Optional[str] = None


class RoadmapResponse(BaseModel):
    id: str
    skill_name: str
    domain_type: str
    verification_score: int
    modules: List[ModuleSchema]
