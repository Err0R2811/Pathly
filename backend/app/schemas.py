"""Pydantic schemas for all API request and response bodies."""
from __future__ import annotations
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


class SourceSchema(BaseModel):
    title: str
    doi: Optional[str] = None
    url: Optional[str] = None
    abstract: Optional[str] = None
    # Enhanced fields
    source_type: Optional[str] = None  # book|course|article|documentation|video
    author: Optional[str] = None
    relevance_score: Optional[int] = Field(default=5, ge=1, le=10)
    video_duration: Optional[int] = None  # Duration in seconds for videos
    thumbnail: Optional[str] = None  # Video thumbnail URL


class ModuleSchema(BaseModel):
    id: Optional[str] = ""
    module_name: str
    level: str
    difficulty_score: int = Field(ge=0, le=100)
    verification_alignment_score: int = Field(ge=0, le=100, default=0)
    estimated_hours: int
    pedagogical_basis: str
    # Enhanced fields
    learning_objectives: Optional[List[str]] = []
    skills_gained: Optional[List[str]] = []
    projects: Optional[List[str]] = []
    assessment_criteria: Optional[str] = None
    sources: List[SourceSchema] = []


class CertificationInfo(BaseModel):
    available_certifications: List[str] = []
    recommended_certification: Optional[str] = None
    certification_body: Optional[str] = None


class RoadmapPreviewResponse(BaseModel):
    skill_name: str
    domain_type: str
    verification_score: int = 0
    # Enhanced fields
    certification_info: Optional[CertificationInfo] = None
    prerequisites: Optional[List[str]] = []
    learning_objectives: Optional[List[str]] = []
    career_outcomes: Optional[List[str]] = []
    salary_range: Optional[str] = None
    market_demand: Optional[str] = None
    modules: List[ModuleSchema]


class CurriculumRequestBody(BaseModel):
    skill_name: str
    max_retries: int = Field(default=3, ge=1, le=5)
    difficulty: str = Field(default="beginner", description="Difficulty level: beginner, intermediate, or advanced")
    deadline_weeks: int = Field(default=4, ge=1, le=52, description="Target completion time in weeks")


class JobStatusResponse(BaseModel):
    job_id: str
    status: str  # PENDING | RUNNING | COMPLETED | FAILED
    progress: int = Field(ge=0, le=100, default=0)
    roadmap_id: Optional[str] = None
    error: Optional[str] = None


class RoadmapSummaryResponse(BaseModel):
    id: str
    skill_name: str
    domain_type: str
    verification_score: int = 0
    created_at: Optional[str] = None


class RoadmapResponse(BaseModel):
    id: str
    skill_name: str
    domain_type: str
    verification_score: int
    # Enhanced fields
    certification_info: Optional[CertificationInfo] = None
    prerequisites: Optional[List[str]] = []
    learning_objectives: Optional[List[str]] = []
    career_outcomes: Optional[List[str]] = []
    salary_range: Optional[str] = None
    market_demand: Optional[str] = None
    modules: List[ModuleSchema]


# Auth Schemas
class UserRegisterRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    email: str = Field(..., min_length=1, max_length=100)
    password: str = Field(..., min_length=6, max_length=100)


class UserLoginRequest(BaseModel):
    email: str = Field(..., min_length=1, max_length=100)
    password: str = Field(..., min_length=1, max_length=100)


class UserResponse(BaseModel):
    id: str
    email: str
    name: str
    avatar_url: str = ""
    title: str = "Beginner"
    level: int = 1
    xp: int = 0
    streak_days: int = 0
    total_minutes: int = 0
    lessons_completed: int = 0
    created_at: str


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    refresh_token: Optional[str] = None
    user: UserResponse


# Badge Schemas
class BadgeSchema(BaseModel):
    id: str
    name: str
    description: Optional[str] = None
    icon_url: Optional[str] = None
    category: Optional[str] = None
    requirement_type: Optional[str] = None
    requirement_value: Optional[int] = None
    is_active: bool = True


class UserBadgeSchema(BaseModel):
    id: str
    badge_id: str
    earned_at: str
    badge: Optional[BadgeSchema] = None


# Lesson Response Schemas
class LessonStepResponse(BaseModel):
    id: str
    lesson_id: str
    step_order: int
    step_type: str
    title: str
    content: Optional[dict] = None
    quiz_options: Optional[list] = None
    correct_answer: Optional[str] = None
    video_url: Optional[str] = None
    video_duration: Optional[int] = None


class LessonResponse(BaseModel):
    id: str
    module_id: str
    lesson_title: str
    lesson_order: int
    difficulty_level: str
    estimated_minutes: int
    learning_objectives: Optional[list] = []
    skills_gained: Optional[list] = []
    prerequisites: Optional[list] = []
    is_completed: bool = False
    steps: List[LessonStepResponse] = []


class LessonListResponse(BaseModel):
    lessons: List[dict] = []
    total: int


# Quiz Response Schemas
class QuizQuestionResponse(BaseModel):
    id: str
    module_id: str
    question_order: int
    question: str
    options: List[str] = []
    correct_answer: str
    explanation: Optional[str] = None


class ModuleQuizResponse(BaseModel):
    questions: List[QuizQuestionResponse] = []
    total: int
