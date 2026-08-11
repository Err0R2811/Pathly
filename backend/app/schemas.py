"""Pydantic schemas for all API request and response bodies."""

from __future__ import annotations

from pydantic import BaseModel, Field


class SourceSchema(BaseModel):
    title: str
    doi: str | None = None
    url: str | None = None
    abstract: str | None = None
    # Enhanced fields
    source_type: str | None = None  # book|course|article|documentation|video
    author: str | None = None
    relevance_score: int | None = Field(default=5, ge=1, le=10)
    video_duration: int | None = None  # Duration in seconds for videos
    thumbnail: str | None = None  # Video thumbnail URL


class ModuleSchema(BaseModel):
    id: str | None = ""
    module_name: str
    level: str
    difficulty_score: int = Field(ge=0, le=100)
    verification_alignment_score: int = Field(ge=0, le=100, default=0)
    estimated_hours: int
    pedagogical_basis: str
    # Enhanced fields
    learning_objectives: list[str] | None = []
    skills_gained: list[str] | None = []
    projects: list[str] | None = []
    assessment_criteria: str | None = None
    sources: list[SourceSchema] = []


class CertificationInfo(BaseModel):
    available_certifications: list[str] = []
    recommended_certification: str | None = None
    certification_body: str | None = None


class RoadmapPreviewResponse(BaseModel):
    skill_name: str
    domain_type: str
    verification_score: int = 0
    # Enhanced fields
    certification_info: CertificationInfo | None = None
    prerequisites: list[str] | None = []
    learning_objectives: list[str] | None = []
    career_outcomes: list[str] | None = []
    salary_range: str | None = None
    market_demand: str | None = None
    modules: list[ModuleSchema]


class CurriculumRequestBody(BaseModel):
    skill_name: str
    max_retries: int = Field(default=3, ge=1, le=5)
    difficulty: str = Field(default="beginner", description="Difficulty level: beginner, intermediate, or advanced")
    deadline_weeks: int = Field(default=4, ge=1, le=52, description="Target completion time in weeks")


class JobStatusResponse(BaseModel):
    job_id: str
    status: str  # PENDING | RUNNING | COMPLETED | FAILED
    progress: int = Field(ge=0, le=100, default=0)
    roadmap_id: str | None = None
    error: str | None = None


class RoadmapSummaryResponse(BaseModel):
    id: str
    skill_name: str
    domain_type: str
    verification_score: int = 0
    created_at: str | None = None


class RoadmapResponse(BaseModel):
    id: str
    skill_name: str
    domain_type: str
    verification_score: int
    # Enhanced fields
    certification_info: CertificationInfo | None = None
    prerequisites: list[str] | None = []
    learning_objectives: list[str] | None = []
    career_outcomes: list[str] | None = []
    salary_range: str | None = None
    market_demand: str | None = None
    modules: list[ModuleSchema]


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
    refresh_token: str | None = None
    user: UserResponse


# Badge Schemas
class BadgeSchema(BaseModel):
    id: str
    name: str
    description: str | None = None
    icon_url: str | None = None
    category: str | None = None
    requirement_type: str | None = None
    requirement_value: int | None = None
    is_active: bool = True


class UserBadgeSchema(BaseModel):
    id: str
    badge_id: str
    earned_at: str
    badge: BadgeSchema | None = None


# Lesson Response Schemas
class LessonStepResponse(BaseModel):
    id: str
    lesson_id: str
    step_order: int
    step_type: str
    title: str
    content: dict | None = None
    quiz_options: list | None = None
    correct_answer: str | None = None
    video_url: str | None = None
    video_duration: int | None = None


class LessonResponse(BaseModel):
    id: str
    module_id: str
    lesson_title: str
    lesson_order: int
    difficulty_level: str
    estimated_minutes: int
    learning_objectives: list | None = []
    skills_gained: list | None = []
    prerequisites: list | None = []
    is_completed: bool = False
    steps: list[LessonStepResponse] = []


class LessonListResponse(BaseModel):
    lessons: list[dict] = []
    total: int


# Quiz Response Schemas
class QuizQuestionResponse(BaseModel):
    id: str
    module_id: str
    question_order: int
    question: str
    options: list[str] = []
    correct_answer: str
    explanation: str | None = None


class ModuleQuizResponse(BaseModel):
    questions: list[QuizQuestionResponse] = []
    total: int
