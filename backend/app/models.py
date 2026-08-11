from datetime import datetime, timezone

from sqlalchemy import JSON, Boolean, Column, ForeignKey, Integer, String
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()


class Roadmap(Base):
    __tablename__ = "roadmaps"
    id = Column(String, primary_key=True)
    user_id = Column(String, nullable=False)
    skill_name = Column(String, nullable=False)
    domain_type = Column(String, nullable=False)
    verification_score = Column(Integer)
    created_at = Column(String)  # placeholder, use DateTime in real
    # Enhanced fields
    certification_info = Column(JSON)  # Store certification details
    prerequisites = Column(JSON)  # List of prerequisites
    learning_objectives = Column(JSON)  # Overall learning goals
    career_outcomes = Column(JSON)  # Job roles enabled
    salary_range = Column(String)  # Expected salary range
    market_demand = Column(String)  # Market demand level
    modules = relationship("Module", back_populates="roadmap")


class Module(Base):
    __tablename__ = "modules"
    id = Column(String, primary_key=True)
    roadmap_id = Column(String, ForeignKey("roadmaps.id"), nullable=False)
    module_name = Column(String, nullable=False)
    level = Column(String, nullable=False)
    difficulty_score = Column(Integer)
    verification_alignment_score = Column(Integer)
    estimated_hours = Column(Integer)
    pedagogical_basis = Column(String)
    # Enhanced fields
    learning_objectives = Column(JSON)  # Specific module objectives
    skills_gained = Column(JSON)  # Practical skills to acquire
    projects = Column(JSON)  # Hands-on projects
    assessment_criteria = Column(String)  # How to verify mastery
    roadmap = relationship("Roadmap", back_populates="modules")
    sources = relationship("ResearchSource", back_populates="module")


class ResearchSource(Base):
    __tablename__ = "research_sources"
    id = Column(String, primary_key=True)
    module_id = Column(String, ForeignKey("modules.id"), nullable=False)
    title = Column(String)
    doi = Column(String)
    url = Column(String)
    abstract = Column(String)
    # Enhanced fields
    source_type = Column(String)  # book|course|article|documentation|video
    author = Column(String)  # Author or instructor
    relevance_score = Column(Integer)  # 1-10 relevance score
    video_duration = Column(Integer)  # Duration in seconds for videos
    thumbnail = Column(String)  # Video thumbnail URL
    embedding = Column(JSON)  # placeholder for vector
    module = relationship("Module", back_populates="sources")


class User(Base):
    __tablename__ = "users"
    id = Column(String, primary_key=True)
    email = Column(String, unique=True, nullable=False, index=True)
    name = Column(String, nullable=False)
    hashed_password = Column(String, nullable=False)
    avatar_url = Column(String, default="")
    title = Column(String, default="Beginner")
    level = Column(Integer, default=1)
    xp = Column(Integer, default=0)
    streak_days = Column(Integer, default=0)
    total_minutes = Column(Integer, default=0)
    lessons_completed = Column(Integer, default=0)
    created_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    is_active = Column(Boolean, default=True)
    last_activity_date = Column(String)  # Track last activity for streak calculation


class UserProgress(Base):
    __tablename__ = "user_progress"
    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    roadmap_id = Column(String, ForeignKey("roadmaps.id"), nullable=False)
    module_id = Column(String, ForeignKey("modules.id"), nullable=True)
    lesson_id = Column(String, ForeignKey("lessons.id"), nullable=True)
    completed_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    xp_earned = Column(Integer, default=0)


class Lesson(Base):
    __tablename__ = "lessons"
    id = Column(String, primary_key=True)
    module_id = Column(String, ForeignKey("modules.id"), nullable=False, index=True)
    lesson_title = Column(String, nullable=False)
    lesson_order = Column(Integer, default=0)
    difficulty_level = Column(String, default="beginner")  # beginner, intermediate, advanced
    estimated_minutes = Column(Integer, default=30)
    # Enhanced fields
    learning_objectives = Column(JSON)  # Specific lesson objectives
    skills_gained = Column(JSON)  # Practical skills to acquire
    prerequisites = Column(JSON)  # List of prerequisite lesson IDs
    module = relationship("Module", backref="lessons")
    steps = relationship("LessonStep", back_populates="lesson", cascade="all, delete-orphan")


class LessonStep(Base):
    __tablename__ = "lesson_steps"
    id = Column(String, primary_key=True)
    lesson_id = Column(String, ForeignKey("lessons.id"), nullable=False, index=True)
    step_order = Column(Integer, default=0)
    step_type = Column(String, nullable=False)  # text, quiz, video, code, interactive
    title = Column(String, nullable=False)
    content = Column(JSON)  # Step-specific content (varies by type)
    # For quiz steps
    quiz_options = Column(JSON)  # Multiple choice options
    correct_answer = Column(String)  # Correct answer
    # For video steps
    video_url = Column(String)
    video_duration = Column(Integer)  # Duration in seconds
    lesson = relationship("Lesson", back_populates="steps")


class Badge(Base):
    __tablename__ = "badges"
    id = Column(String, primary_key=True)
    name = Column(String, nullable=False, unique=True)
    description = Column(String)
    icon_url = Column(String)
    category = Column(String)  # streak, xp, lessons, special
    requirement_type = Column(String)  # xp_threshold, streak_days, lessons_completed, custom
    requirement_value = Column(Integer)  # Numeric threshold
    custom_rule = Column(JSON)  # For complex custom rules
    is_active = Column(Boolean, default=True)


class UserBadge(Base):
    __tablename__ = "user_badges"
    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    badge_id = Column(String, ForeignKey("badges.id"), nullable=False)
    earned_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    user = relationship("User", backref="badges")
    badge = relationship("Badge")


class QuizQuestion(Base):
    __tablename__ = "quiz_questions"
    id = Column(String, primary_key=True)
    module_id = Column(String, ForeignKey("modules.id"), nullable=False, index=True)
    question_order = Column(Integer, default=0)
    question = Column(String, nullable=False)
    options = Column(JSON)  # List of 4 options
    correct_answer = Column(String, nullable=False)  # "A", "B", "C", or "D"
    explanation = Column(String)  # Explanation of why this answer is correct
    module = relationship("Module", backref="quiz_questions")
