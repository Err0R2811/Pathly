"""AI router — LLM-powered lesson explanations and hints."""

from __future__ import annotations

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Lesson, User
from ..services.llm_explainer import explain_concept, generate_quiz_hint
from .auth import get_current_user

router = APIRouter(prefix="/ai", tags=["ai"])


class ExplainRequest(BaseModel):
    concept: str
    lesson_id: str | None = None


class QuizHintRequest(BaseModel):
    question: str
    options: list


@router.post("/explain")
async def explain_concept_endpoint(
    request: ExplainRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    """Get an AI explanation for a concept."""
    lesson_context = None

    if request.lesson_id:
        lesson = db.query(Lesson).filter(Lesson.id == request.lesson_id).first()
        if lesson:
            lesson_context = f"Lesson: {lesson.lesson_title}. Objectives: {lesson.learning_objectives}"

    explanation = await explain_concept(request.concept, lesson_context, user_level=current_user.title.lower())

    return {
        "concept": request.concept,
        "explanation": explanation,
        "user_level": current_user.title,
    }


@router.post("/quiz-hint")
async def get_quiz_hint(request: QuizHintRequest, current_user: User = Depends(get_current_user)):
    """Get an AI hint for a quiz question."""
    hint = await generate_quiz_hint(request.question, request.options)

    return {
        "question": request.question,
        "hint": hint,
    }
