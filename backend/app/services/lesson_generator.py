# ruff: noqa: E501
"""Lesson content generator service.

Generates detailed lesson content for each module in a curriculum,
including step-by-step learning materials and YouTube video integration.
Quiz content is generated separately at the module level.
"""

from __future__ import annotations

import asyncio
import json
import os

import httpx

from .youtube_search import search_youtube_videos

NVIDIA_API_KEY = os.getenv("NVIDIA_API_KEY", "")
NVIDIA_MODEL = os.getenv("NVIDIA_MODEL", "gpt-oss-120b")
NVIDIA_BASE_URL = os.getenv("NVIDIA_BASE_URL", "https://integrate.api.nvidia.com/v1")

_LESSON_SYSTEM_PROMPT = (
    "You are a world-class educator and master instructional designer. "
    "You create deep, highly structured, intuitive, and engaging lesson materials. "
    "You explain complex concepts using clear mental models, real-world analogies, step-by-step breakdowns, "
    "concrete practical examples, common pitfalls, and guided hands-on exercises. "
    "You always respond with valid JSON only — no markdown formatting outside JSON values, no extra text."
)

_LESSON_USER_PROMPT = """\
Create an in-depth, structured, and easy-to-understand lesson for the topic: "{topic}" within the skill: "{skill_name}".

Module context: {module_name}
Difficulty level: {difficulty}
Estimated duration: {estimated_minutes} minutes

Return ONLY a valid JSON object with this exact structure:
{{
  "lesson_title": "engaging and descriptive lesson title",
  "learning_objectives": ["specific, clear learning goals for this lesson"],
  "skills_gained": ["practical skills students will acquire"],
  "prerequisites": ["foundational concepts needed before starting"],
  "steps": [
    {{
      "step_order": 1,
      "step_type": "text",
      "title": "Core Concept & Intuition: {topic}",
      "content": {{
        "explanation": "rich, detailed, and intuitive explanation (5-7 clear sentences breaking down what the concept is and why it matters)",
        "examples": ["concrete real-world analogy or practical code example 1", "practical example 2"],
        "key_points": ["takeaway 1", "takeaway 2", "takeaway 3"]
      }}
    }},
    {{
      "step_order": 2,
      "step_type": "text",
      "title": "Deep Dive & How It Works",
      "content": {{
        "explanation": "step-by-step breakdown of how {topic} operates under the hood, key mechanisms, and best practices",
        "examples": ["detailed walkthrough example", "real-world application scenario"],
        "key_points": ["mechanism 1", "best practice 1", "common pitfall to avoid"]
      }}
    }},
    {{
      "step_order": 3,
      "step_type": "video",
      "title": "Watch: {topic} Visual Breakdown",
      "content": {{
        "video_url": "YouTube video URL (filled automatically)",
        "video_duration": 300,
        "description": "overview of what this video demonstrates",
        "key_takeaways": ["key visual takeaway 1", "key visual takeaway 2"]
      }}
    }},
    {{
      "step_order": 4,
      "step_type": "text",
      "title": "Common Pitfalls & Pro Tips",
      "content": {{
        "explanation": "explanation of frequent mistakes learners make with {topic} and how top industry practitioners avoid them",
        "examples": ["anti-pattern vs recommended approach example 1", "pro tip example 2"],
        "key_points": ["pitfall 1 to avoid", "pro tip 1 for efficiency"]
      }}
    }},
    {{
      "step_order": 5,
      "step_type": "text",
      "title": "Guided Hands-on Practice",
      "content": {{
        "explanation": "clear, step-by-step instructions for a hands-on exercise",
        "exercise": "specific, practical task for students to build or solve",
        "solution": "comprehensive expected solution and explanation of why it works"
      }}
    }}
  ]
}}

Rules:
- Create 5-7 steps in logical pedagogical sequence.
- Ensure text explanations are thorough, intuitive, and free of fluff.
- Provide concrete examples for every text step.
- Ensure hands-on steps have actionable exercises and clear solutions.
- Do NOT include quiz steps (quizzes are generated separately).
"""


async def generate_lesson_content(
    topic: str, skill_name: str, module_name: str, difficulty: str = "beginner", estimated_minutes: int = 30
) -> dict:
    """Generate detailed lesson content for a specific topic.

    Args:
        topic: The specific topic for this lesson
        skill_name: The overall skill being learned
        module_name: The module this lesson belongs to
        difficulty: Difficulty level (beginner, intermediate, advanced)
        estimated_minutes: Expected duration in minutes

    Returns:
        Dictionary with lesson content including steps
    """

    if not NVIDIA_API_KEY:
        print("[lesson_generator] NVIDIA_API_KEY not set, using fallback.")
        return await _static_lesson_fallback(topic, skill_name, module_name, difficulty)

    headers = {
        "Authorization": f"Bearer {NVIDIA_API_KEY}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": NVIDIA_MODEL,
        "messages": [
            {"role": "system", "content": _LESSON_SYSTEM_PROMPT},
            {
                "role": "user",
                "content": _LESSON_USER_PROMPT.format(
                    topic=topic,
                    skill_name=skill_name,
                    module_name=module_name,
                    difficulty=difficulty,
                    estimated_minutes=estimated_minutes,
                ),
            },
        ],
        "temperature": 0.7,
        "response_format": {"type": "json_object"},
    }

    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                f"{NVIDIA_BASE_URL}/chat/completions",
                headers=headers,
                json=payload,
            )
            response.raise_for_status()
            content = response.json()["choices"][0]["message"]["content"]
            lesson = json.loads(content)

            # Enhance with YouTube videos for video steps
            for step in lesson.get("steps", []):
                if step.get("step_type") == "video":
                    search_query = f"{skill_name} {topic} tutorial"
                    videos = await search_youtube_videos(search_query, max_results=1)
                    if videos:
                        step["content"]["video_url"] = videos[0]["url"]
                        step["content"]["video_duration"] = videos[0]["duration"]
                        step["content"]["thumbnail"] = videos[0].get("thumbnail", "")

            return lesson

    except Exception as e:
        print(f"[lesson_generator] Generation failed: {e}, using fallback")
        return await _static_lesson_fallback(topic, skill_name, module_name, difficulty)


async def generate_module_lessons(
    module_name: str, skill_name: str, difficulty: str = "beginner", estimated_hours: int = 20
) -> list[dict]:
    """Generate multiple lessons for a complete module (parallelized).

    Args:
        module_name: Name of the module
        skill_name: Overall skill being learned
        difficulty: Difficulty level
        estimated_hours: Total hours for the module

    Returns:
        List of lesson dictionaries
    """
    # Calculate number of lessons based on estimated hours
    num_lessons = max(3, min(6, estimated_hours // 3))
    minutes_per_lesson = (estimated_hours * 60) // num_lessons

    # Generate lesson topics based on module
    lesson_topics = await _generate_lesson_topics(module_name, skill_name, num_lessons)

    # Generate lessons in parallel with concurrency limit
    semaphore = asyncio.Semaphore(3)  # Limit concurrent LLM calls

    async def generate_lesson_with_semaphore(topic, index):
        async with semaphore:
            lesson = await generate_lesson_content(
                topic=topic,
                skill_name=skill_name,
                module_name=module_name,
                difficulty=difficulty,
                estimated_minutes=minutes_per_lesson,
            )
            lesson["lesson_order"] = index + 1
            lesson["estimated_minutes"] = minutes_per_lesson
            lesson["difficulty_level"] = difficulty
            return lesson

    lessons = await asyncio.gather(
        *[generate_lesson_with_semaphore(topic, i) for i, topic in enumerate(lesson_topics)], return_exceptions=True
    )

    # Filter out exceptions and return valid lessons
    return [lesson for lesson in lessons if not isinstance(lesson, Exception)]


async def _generate_lesson_topics(module_name: str, skill_name: str, num_lessons: int) -> list[str]:
    """Generate lesson topics for a module using AI or fallback."""

    if not NVIDIA_API_KEY:
        return _static_lesson_topics(module_name, num_lessons)

    prompt = f"""Generate {num_lessons} clear, structured lesson topics for the module "{module_name}" in learning {skill_name}.

Return ONLY a valid JSON array of topic strings:
["topic 1", "topic 2", "topic 3", ...]

Topics should:
- Progress logically from core mental models to advanced practical execution
- Cover key concepts in the module thoroughly
- Be specific, intuitive, and actionable
- Build on each other"""

    try:
        headers = {
            "Authorization": f"Bearer {NVIDIA_API_KEY}",
            "Content-Type": "application/json",
        }

        payload = {
            "model": NVIDIA_MODEL,
            "messages": [
                {"role": "system", "content": "You respond with valid JSON only."},
                {"role": "user", "content": prompt},
            ],
            "temperature": 0.7,
            "response_format": {"type": "json_object"},
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"{NVIDIA_BASE_URL}/chat/completions",
                headers=headers,
                json=payload,
            )
            response.raise_for_status()
            content = response.json()["choices"][0]["message"]["content"]
            topics = json.loads(content)
            return topics.get("topics", _static_lesson_topics(module_name, num_lessons))

    except Exception as e:
        print(f"[lesson_generator] Topic generation failed: {e}, using fallback")
        return _static_lesson_topics(module_name, num_lessons)


def _static_lesson_topics(module_name: str, num_lessons: int) -> list[str]:
    """Fallback lesson topics when AI generation fails."""
    base_topics = [
        f"Introduction to {module_name}",
        f"Core Concepts of {module_name}",
        f"Practical Applications of {module_name}",
        f"Advanced Techniques in {module_name}",
        f"Best Practices for {module_name}",
        f"Real-world Projects with {module_name}",
    ]
    return base_topics[:num_lessons]


async def _static_lesson_fallback(topic: str, skill_name: str, module_name: str, difficulty: str) -> dict:
    """Fallback lesson content when AI generation fails."""
    search_query = f"{skill_name} {topic} tutorial"
    videos = await search_youtube_videos(search_query, max_results=1)
    video_url = (
        videos[0]["url"] if videos else f"https://www.youtube.com/results?search_query={'+'.join(search_query.split())}"
    )
    video_duration = videos[0].get("duration", 0) if videos else 0
    video_thumbnail = videos[0].get("thumbnail", "") if videos else ""

    return {
        "lesson_title": f"Learning {topic}",
        "summary": f"This lesson covers {topic} as part of {module_name} in {skill_name}. By the end, you will understand the core ideas, see practical examples, and get hands-on practice.",
        "learning_objectives": [
            f"Understand the fundamentals of {topic}",
            f"Apply {topic} concepts in practical scenarios",
            f"Build confidence with {topic} techniques",
            f"Identify common patterns and best practices in {topic}",
        ],
        "skills_gained": [f"{topic} fundamentals", "Practical application", "Problem-solving", "Critical thinking"],
        "prerequisites": [f"Basic familiarity with {skill_name}", f"Willingness to practice {topic} concepts"],
        "steps": [
            {
                "step_order": 1,
                "step_type": "text",
                "title": f"Core Concept & Intuition: {topic}",
                "content": {
                    "explanation": f"{topic} is a foundational concept within {module_name} for {skill_name}. It helps you organize, reason about, and solve real problems. At its core, {topic} is about applying structured thinking and practical techniques to achieve a clear outcome.",
                    "examples": [
                        f"Example 1: A beginner scenario where {topic} is used to solve a simple {skill_name} problem.",
                        f"Example 2: A more advanced use of {topic} to improve efficiency or quality in {module_name}.",
                    ],
                    "key_points": [
                        f"{topic} is a core building block of {module_name}",
                        f"It connects directly to practical {skill_name} work",
                        "Mastery comes from understanding principles first, then applying them",
                    ],
                },
            },
            {
                "step_order": 2,
                "step_type": "text",
                "title": f"Key Principles of {topic}",
                "content": {
                    "explanation": f"To use {topic} effectively, focus on the key principles: understand the goal, break the work into clear steps, apply the right technique at the right time, and validate the result. These principles are universal and apply to many situations in {skill_name}.",
                    "examples": [
                        f"Principle in action: How a small {skill_name} project benefits from {topic}.",
                        f"Common mistake: Applying {topic} without a clear goal, leading to wasted effort.",
                    ],
                    "key_points": [
                        "Start with a clear goal",
                        "Break the problem into smaller, manageable pieces",
                        "Validate and iterate on your work",
                    ],
                },
            },
            {
                "step_order": 3,
                "step_type": "video",
                "title": f"Watch: {topic} Visual Breakdown",
                "content": {
                    "video_url": video_url,
                    "video_duration": video_duration,
                    "thumbnail": video_thumbnail,
                    "description": f"Watch this video to see {topic} explained with examples and demonstrations.",
                    "key_takeaways": [
                        f"Main concept of {topic}",
                        f"Practical techniques for {topic}",
                        f"Common pitfalls to avoid when learning {topic}",
                    ],
                },
            },
            {
                "step_order": 4,
                "step_type": "text",
                "title": f"Practical {topic} Examples & Pro Tips",
                "content": {
                    "explanation": f"Let's look at practical examples of {topic} in {skill_name}. Each example walks through a real situation, the thought process, and the final result.",
                    "examples": [
                        f"Example A: Solving a simple {skill_name} task using {topic}.",
                        f"Example B: Combining {topic} with other {module_name} concepts for a stronger solution.",
                        f"Example C: A real-world scenario where {topic} saves time or prevents errors.",
                    ],
                    "key_points": [
                        "Examples make abstract concepts concrete",
                        "Look for patterns you can reuse in your own work",
                        "Practice with varied examples to build flexibility",
                    ],
                },
            },
            {
                "step_order": 5,
                "step_type": "text",
                "title": "Guided Hands-on Practice",
                "content": {
                    "explanation": f"Now it's time to practice {topic}. Completing this exercise will help you remember what you've learned and build confidence.",
                    "exercise": f"Create a small, self-contained project that demonstrates {topic}. Start with a simple version, then add one improvement or challenge.",
                    "solution": f"Your solution should clearly show how {topic} is used, the steps you took, and the final result. Compare your solution to the examples and note any differences.",
                },
            },
        ],
    }
