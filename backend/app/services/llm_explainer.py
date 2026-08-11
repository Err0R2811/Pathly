# ruff: noqa: E501
"""LLM lesson explainer service — RAG-based concept explanations."""

from __future__ import annotations

import os

import httpx

# Configuration
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "")
MODEL_NAME = os.getenv("OPENROUTER_MODEL", "gpt-oss-120b")
OPENAI_BASE_URL = os.getenv("OPENROUTER_BASE_URL", "https://openrouter.ai/api/v1")


async def call_openrouter_api(messages: list, model: str = MODEL_NAME) -> dict:
    """Call OpenRouter API for LLM responses."""
    if not OPENROUTER_API_KEY:
        return {"content": "AI service unavailable - API key not configured"}

    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://pathly.app",
        "X-Title": "Pathly AI Explainer",
    }
    payload = {
        "model": model,
        "messages": messages,
        "temperature": 0.7,
    }

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"{OPENAI_BASE_URL}/chat/completions",
                headers=headers,
                json=payload,
            )
            response.raise_for_status()
            return response.json()["choices"][0]["message"]
    except Exception:
        return {"content": "AI service temporarily unavailable"}


async def explain_concept(concept: str, lesson_context: str | None = None, user_level: str = "beginner") -> str:
    """Generate an explanation for a concept using RAG and LLM."""

    # Build the prompt
    system_prompt = f"""You are a helpful educational assistant for Pathly, a learning platform.
Explain concepts clearly and concisely for a {user_level} level learner.
Use examples and analogies when helpful. Keep explanations under 200 words."""

    user_prompt = f"Explain the concept: {concept}"

    if lesson_context:
        user_prompt += f"\n\nContext from the lesson: {lesson_context}"

    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt},
    ]

    try:
        response = await call_openrouter_api(messages, model=MODEL_NAME)
        return response.get("content", "Sorry, I couldn't generate an explanation at this time.")
    except Exception:
        return "Sorry, the AI explainer is currently unavailable. Please try again later."


async def generate_quiz_hint(question: str, options: list) -> str:
    """Generate a hint for a quiz question without giving away the answer."""

    system_prompt = """You are a helpful educational assistant. Provide a subtle hint for a quiz question that guides the learner without revealing the answer directly. Keep hints under 50 words."""

    user_prompt = f"Question: {question}\nOptions: {', '.join(options)}\nProvide a hint."

    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt},
    ]

    try:
        response = await call_openrouter_api(messages, model=MODEL_NAME)
        return response.get("content", "Think about the key concepts involved.")
    except Exception:
        return "Think about the key concepts involved."
