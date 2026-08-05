"""Lessons router — fetch lessons and lesson steps for learning (consolidated from content.py)."""
from __future__ import annotations
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
import uuid

from ..database import get_db
from ..models import Lesson, LessonStep, Module, UserProgress, User, QuizQuestion
from ..schemas import LessonResponse, LessonStepResponse, LessonListResponse, ModuleQuizResponse, QuizQuestionResponse
from .auth import get_current_user_optional, get_current_user
from .progress import award_lesson_completion_xp
from ..services.lesson_generator import generate_module_lessons
from ..services.quiz_generator import generate_module_quiz

router = APIRouter(prefix="/lessons", tags=["lessons"])


@router.get("/module/{module_id}", response_model=LessonListResponse)
async def get_module_lessons(
    module_id: str,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    """Get all lessons for a specific module. Generates lessons lazily if they don't exist."""
    # Verify module exists
    module = db.query(Module).filter(Module.id == module_id).first()
    if not module:
        raise HTTPException(status_code=404, detail="Module not found")
    
    lessons = db.query(Lesson).filter(Lesson.module_id == module_id).order_by(Lesson.lesson_order).all()
    
    # Lazy lesson generation: if no lessons exist, generate them now
    if not lessons:
        try:
            # Generate lessons using the lesson generator service
            generated_lessons = await generate_module_lessons(
                module_name=module.module_name,
                skill_name=module.roadmap.skill_name if module.roadmap else "General",
                difficulty=module.level,
                estimated_hours=module.estimated_hours
            )
            
            # Persist generated lessons
            for lesson_data in generated_lessons:
                lesson_id = str(uuid.uuid4())
                db_lesson = Lesson(
                    id=lesson_id,
                    module_id=module_id,
                    lesson_title=lesson_data.get("lesson_title", ""),
                    lesson_order=lesson_data.get("lesson_order", 0),
                    difficulty_level=lesson_data.get("difficulty_level", "beginner"),
                    estimated_minutes=lesson_data.get("estimated_minutes", 30),
                    learning_objectives=lesson_data.get("learning_objectives"),
                    skills_gained=lesson_data.get("skills_gained"),
                    prerequisites=lesson_data.get("prerequisites"),
                )
                db.add(db_lesson)
                
                # Add lesson steps
                for step_data in lesson_data.get("steps", []):
                    step_id = str(uuid.uuid4())
                    db_step = LessonStep(
                        id=step_id,
                        lesson_id=lesson_id,
                        step_order=step_data.get("step_order", 0),
                        step_type=step_data.get("step_type", "text"),
                        title=step_data.get("title", ""),
                        content=step_data.get("content"),
                        quiz_options=step_data.get("quiz_options"),
                        correct_answer=step_data.get("correct_answer"),
                        video_url=step_data.get("content", {}).get("video_url") if step_data.get("step_type") == "video" else None,
                        video_duration=step_data.get("content", {}).get("video_duration") if step_data.get("step_type") == "video" else None,
                    )
                    db.add(db_step)
            
            db.commit()
            
            # Re-query to get the persisted lessons
            lessons = db.query(Lesson).filter(Lesson.module_id == module_id).order_by(Lesson.lesson_order).all()
            
        except Exception as e:
            print(f"[lessons] Lazy lesson generation failed: {e}")
            raise HTTPException(status_code=500, detail="Failed to generate lessons")
    
    # Get completion status if user is authenticated
    completed_lessons = set()
    if current_user:
        progress = db.query(UserProgress).filter(
            UserProgress.user_id == current_user.id,
            UserProgress.module_id == module_id
        ).all()
        completed_lessons = {p.lesson_id for p in progress if p.lesson_id}
    
    lesson_responses = []
    for lesson in lessons:
        lesson_dict = {
            "id": lesson.id,
            "module_id": lesson.module_id,
            "lesson_title": lesson.lesson_title,
            "lesson_order": lesson.lesson_order,
            "difficulty_level": lesson.difficulty_level,
            "estimated_minutes": lesson.estimated_minutes,
            "learning_objectives": lesson.learning_objectives,
            "skills_gained": lesson.skills_gained,
            "prerequisites": lesson.prerequisites,
            "is_completed": lesson.id in completed_lessons
        }
        lesson_responses.append(lesson_dict)
    
    return {"lessons": lesson_responses, "total": len(lesson_responses)}


@router.get("/{lesson_id}", response_model=LessonResponse)
async def get_lesson(
    lesson_id: str,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    """Get detailed lesson content including steps."""
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    
    # Get lesson steps
    steps = db.query(LessonStep).filter(LessonStep.lesson_id == lesson_id).order_by(LessonStep.step_order).all()
    
    # Check completion status
    is_completed = False
    if current_user:
        progress = db.query(UserProgress).filter(
            UserProgress.user_id == current_user.id,
            UserProgress.lesson_id == lesson_id
        ).first()
        is_completed = progress is not None
    
    step_responses = []
    for step in steps:
        step_dict = {
            "id": step.id,
            "lesson_id": step.lesson_id,
            "step_order": step.step_order,
            "step_type": step.step_type,
            "title": step.title,
            "content": step.content,
            "quiz_options": step.quiz_options,
            "correct_answer": step.correct_answer,
            "video_url": step.video_url,
            "video_duration": step.video_duration
        }
        step_responses.append(step_dict)
    
    return {
        "id": lesson.id,
        "module_id": lesson.module_id,
        "lesson_title": lesson.lesson_title,
        "lesson_order": lesson.lesson_order,
        "difficulty_level": lesson.difficulty_level,
        "estimated_minutes": lesson.estimated_minutes,
        "learning_objectives": lesson.learning_objectives,
        "skills_gained": lesson.skills_gained,
        "prerequisites": lesson.prerequisites,
        "is_completed": is_completed,
        "steps": step_responses
    }


@router.post("/{lesson_id}/complete", status_code=200)
async def complete_lesson(
    lesson_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Mark a lesson as completed for the current user."""
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    
    # Check if already completed
    existing_progress = db.query(UserProgress).filter(
        UserProgress.user_id == current_user.id,
        UserProgress.lesson_id == lesson_id
    ).first()
    
    if existing_progress:
        return {"message": "Lesson already completed", "xp_earned": existing_progress.xp_earned}
    
    # Create progress record
    progress = UserProgress(
        user_id=current_user.id,
        roadmap_id=None,  # Will be filled if needed
        module_id=lesson.module_id,
        lesson_id=lesson_id,
        xp_earned=50  # Base XP for completing a lesson
    )
    db.add(progress)
    
    # Use shared XP awarding logic (includes streak, badges, leaderboard, level-up)
    award_result = award_lesson_completion_xp(current_user, 50, db)
    
    db.refresh(progress)
    
    return {
        "message": "Lesson completed successfully",
        "xp_earned": 50,
        "total_xp": award_result["total_xp"],
        "level": award_result["level"],
        "level_up": award_result["level_up"],
        "streak_days": award_result["streak_days"],
        "new_badges": award_result["new_badges"]
    }


@router.get("/module/{module_id}/quiz", response_model=ModuleQuizResponse)
async def get_module_quiz(
    module_id: str,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    """Get practice quiz for a specific module. Generates quiz lazily if it doesn't exist."""
    # Verify module exists
    module = db.query(Module).filter(Module.id == module_id).first()
    if not module:
        raise HTTPException(status_code=404, detail="Module not found")
    
    quiz_questions = db.query(QuizQuestion).filter(QuizQuestion.module_id == module_id).order_by(QuizQuestion.question_order).all()
    
    # Lazy quiz generation: if no quiz exists, generate it now
    if not quiz_questions:
        try:
            # Generate quiz using the quiz generator service
            generated_questions = await generate_module_quiz(
                module_name=module.module_name,
                skill_name=module.roadmap.skill_name if module.roadmap else "General",
                difficulty=module.level,
                learning_objectives=module.learning_objectives,
                skills_gained=module.skills_gained,
                num_questions=4
            )
            
            # Persist generated quiz questions
            for question_data in generated_questions:
                question_id = str(uuid.uuid4())
                db_question = QuizQuestion(
                    id=question_id,
                    module_id=module_id,
                    question_order=question_data.get("question_order", 0),
                    question=question_data.get("question", ""),
                    options=question_data.get("options", []),
                    correct_answer=question_data.get("correct_answer", ""),
                    explanation=question_data.get("explanation", "")
                )
                db.add(db_question)
            
            db.commit()
            
            # Re-query to get the persisted quiz questions
            quiz_questions = db.query(QuizQuestion).filter(QuizQuestion.module_id == module_id).order_by(QuizQuestion.question_order).all()
            
        except Exception as e:
            print(f"[lessons] Lazy quiz generation failed: {e}")
            raise HTTPException(status_code=500, detail="Failed to generate quiz")
    
    # Build response
    question_responses = []
    for question in quiz_questions:
        question_dict = {
            "id": question.id,
            "module_id": question.module_id,
            "question_order": question.question_order,
            "question": question.question,
            "options": question.options,
            "correct_answer": question.correct_answer,
            "explanation": question.explanation
        }
        question_responses.append(question_dict)
    
    return {"questions": question_responses, "total": len(question_responses)}
