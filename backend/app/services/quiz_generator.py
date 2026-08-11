# ruff: noqa: E501
"""Quiz content generator service for module-level practice quizzes.

Generates 3-5 question practice quizzes for each module to test
understanding of the module's learning objectives and key concepts.
"""

from __future__ import annotations

import json
import os

import httpx

NVIDIA_API_KEY = os.getenv("NVIDIA_API_KEY", "")
NVIDIA_MODEL = os.getenv("NVIDIA_MODEL", "gpt-oss-120b")
NVIDIA_BASE_URL = os.getenv("NVIDIA_BASE_URL", "https://integrate.api.nvidia.com/v1")

_QUIZ_SYSTEM_PROMPT = (
    "You are an expert educator and assessment designer. "
    "You create thoughtful, challenging multiple-choice questions that test "
    "deep understanding rather than memorization. "
    "You always respond with valid JSON only — no markdown, no extra text."
)

_QUIZ_USER_PROMPT = """\
Generate a practice quiz for the module: "{module_name}" in the skill: "{skill_name}".

Module context:
- Difficulty level: {difficulty}
- Learning objectives: {learning_objectives}
- Skills gained: {skills_gained}

Return ONLY a valid JSON object with this exact structure:
{{
  "questions": [
    {{
      "question": "thoughtful question that tests understanding",
      "options": ["option A", "option B", "option C", "option D"],
      "correct_answer": "B",
      "explanation": "detailed explanation of why this answer is correct and why others are not"
    }}
  ]
}}

Rules:
- Generate {num_questions} questions
- Questions should progress from basic to advanced
- Each question must have exactly 4 options (A, B, C, D)
- Correct answer should be one of the options (A, B, C, or D)
- Explanations should be educational and help students learn from mistakes
- Questions should test understanding, not memorization
- Include questions that require applying concepts, not just recalling facts
- Adjust difficulty based on the module's difficulty level
"""


async def generate_module_quiz(
    module_name: str,
    skill_name: str,
    difficulty: str = "beginner",
    learning_objectives: list[str] = None,
    skills_gained: list[str] = None,
    num_questions: int = 4,
) -> list[dict]:
    """Generate a practice quiz for a specific module.

    Args:
        module_name: Name of the module
        skill_name: Overall skill being learned
        difficulty: Difficulty level (beginner, intermediate, advanced)
        learning_objectives: List of module learning objectives
        skills_gained: List of skills students will gain
        num_questions: Number of questions to generate (3-5 recommended)

    Returns:
        List of question dictionaries with question, options, correct_answer, explanation
    """
    if learning_objectives is None:
        learning_objectives = []
    if skills_gained is None:
        skills_gained = []

    if not NVIDIA_API_KEY:
        print("[quiz_generator] NVIDIA_API_KEY not set, using fallback.")
        return _static_quiz_fallback(module_name, skill_name, num_questions)

    headers = {
        "Authorization": f"Bearer {NVIDIA_API_KEY}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": NVIDIA_MODEL,
        "messages": [
            {"role": "system", "content": _QUIZ_SYSTEM_PROMPT},
            {
                "role": "user",
                "content": _QUIZ_USER_PROMPT.format(
                    module_name=module_name,
                    skill_name=skill_name,
                    difficulty=difficulty,
                    learning_objectives=json.dumps(learning_objectives),
                    skills_gained=json.dumps(skills_gained),
                    num_questions=num_questions,
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
            quiz_data = json.loads(content)

            questions = quiz_data.get("questions", [])
            # Add question_order to each question
            for i, question in enumerate(questions):
                question["question_order"] = i + 1

            return questions

    except Exception as e:
        print(f"[quiz_generator] Generation failed: {e}, using fallback")
        return _static_quiz_fallback(module_name, skill_name, num_questions)


def _static_quiz_fallback(module_name: str, skill_name: str, num_questions: int) -> list[dict]:
    """Fallback quiz questions when AI generation fails."""

    base_questions = [
        {
            "question": f"What is the primary purpose of learning {module_name}?",
            "options": [
                "To memorize facts",
                f"To build foundational skills for {skill_name}",
                "To get certified",
                "To complete a course requirement",
            ],
            "correct_answer": "B",
            "explanation": f"{module_name} provides essential foundational skills that support advanced learning in {skill_name}.",
        },
        {
            "question": f"Which of the following best describes the relationship between {module_name} and {skill_name}?",
            "options": [
                "They are unrelated concepts",
                f"{module_name} is a subset of {skill_name}",
                f"{skill_name} is a prerequisite for {module_name}",
                "They are the same thing",
            ],
            "correct_answer": "B",
            "explanation": f"{module_name} represents a specific area within the broader skill of {skill_name}.",
        },
        {
            "question": f"When applying {module_name} concepts, what is the most important factor?",
            "options": [
                "Speed of execution",
                "Understanding the underlying principles",
                "Using the most complex tools",
                "Following a strict template",
            ],
            "correct_answer": "B",
            "explanation": "Understanding underlying principles is crucial for effective application and problem-solving.",
        },
        {
            "question": f"What is a common misconception about {module_name}?",
            "options": [
                "It requires practice to master",
                "It can be learned without any prerequisites",
                "It has real-world applications",
                "It builds on fundamental concepts",
            ],
            "correct_answer": "B",
            "explanation": f"{module_name} typically requires some foundational knowledge and cannot be learned in isolation.",
        },
        {
            "question": f"How would you evaluate your understanding of {module_name}?",
            "options": [
                "By memorizing definitions",
                "By explaining concepts to others",
                "By completing exercises quickly",
                "By reading about it",
            ],
            "correct_answer": "B",
            "explanation": "Being able to explain concepts to others demonstrates deep understanding and mastery.",
        },
    ]

    return base_questions[:num_questions]
