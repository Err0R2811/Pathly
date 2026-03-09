"""OpenAI-powered curriculum generator.

Reads OPENAI_API_KEY from the environment. Falls back to a rich static roadmap
if the key is missing or the API call fails, so the app still works in offline mode.
"""
from __future__ import annotations
import os
import json
import re
import httpx

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "")
OPENAI_MODEL = os.getenv("OPENROUTER_MODEL", "google/gemini-2.0-flash-001")
OPENAI_BASE_URL = os.getenv("OPENROUTER_BASE_URL", "https://openrouter.ai/api/v1")

_SYSTEM_PROMPT = (
    "You are an expert curriculum designer with deep knowledge of pedagogy and learning science. "
    "You always respond with valid JSON only — no markdown, no extra text."
)

_USER_PROMPT = """\
Generate a structured learning roadmap for the skill: "{skill_name}".

Return ONLY a valid JSON object with this exact structure:
{{
  "skill_name": "{skill_name}",
  "domain_type": "technical|creative|soft-skill",
  "modules": [
    {{
      "module_name": "string",
      "level": "Beginner|Intermediate|Advanced",
      "difficulty_score": 1-100,
      "estimated_hours": integer,
      "pedagogical_basis": "string explaining the teaching method",
      "sources": [
        {{
          "title": "string",
          "doi": "DOI string or null",
          "url": "URL string or null",
          "abstract": "1-2 sentence summary"
        }}
      ]
    }}
  ]
}}

Rules:
- Include 4-6 modules in a logical progression from beginner to advanced.
- Each module MUST have at least 2 real, reputable sources.
- difficulty_score increases across modules.
"""


async def generate_roadmap(skill_name: str) -> dict:
    """Call OpenAI to generate a curriculum roadmap. Falls back to static data on error."""
    if not OPENROUTER_API_KEY:
        print("[generator] OPENROUTER_API_KEY not set, using fallback.")
        return _static_fallback(skill_name)

    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://pathly.app",
        "X-Title": "Pathly Curriculum Generator",
    }
    payload = {
        "model": OPENAI_MODEL,
        "messages": [
            {"role": "system", "content": _SYSTEM_PROMPT},
            {"role": "user", "content": _USER_PROMPT.format(skill_name=skill_name)},
        ],
        "temperature": 0.7,
        "response_format": {"type": "json_object"},
    }

    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                f"{OPENAI_BASE_URL}/chat/completions",
                headers=headers,
                json=payload,
            )
            response.raise_for_status()
            content = response.json()["choices"][0]["message"]["content"]
            roadmap = json.loads(content)
            roadmap.setdefault("verification_score", 0)
            return roadmap
    except Exception as exc:
        print(f"[generator] OpenRouter call failed ({exc}), using fallback.")
        return _static_fallback(skill_name)


def _static_fallback(skill_name: str) -> dict:
    """Rich static roadmap used when API is unavailable."""
    return {
        "skill_name": skill_name,
        "domain_type": "technical",
        "verification_score": 0,
        "modules": [
            {
                "module_name": f"Foundations of {skill_name}",
                "level": "Beginner",
                "difficulty_score": 15,
                "estimated_hours": 3,
                "pedagogical_basis": "Bloom's Taxonomy — knowledge and comprehension",
                "sources": [
                    {
                        "title": f"Introduction to {skill_name}",
                        "doi": None,
                        "url": f"https://en.wikipedia.org/wiki/{skill_name.replace(' ', '_')}",
                        "abstract": f"A comprehensive introduction to {skill_name}.",
                    },
                    {
                        "title": "Learning How to Learn",
                        "doi": "10.1016/j.lindif.2014.08.010",
                        "url": "https://www.coursera.org/learn/learning-how-to-learn",
                        "abstract": "Evidence-based strategies for effective learning and memory retention.",
                    },
                ],
            },
            {
                "module_name": f"Core Techniques in {skill_name}",
                "level": "Intermediate",
                "difficulty_score": 50,
                "estimated_hours": 6,
                "pedagogical_basis": "Project-based learning with deliberate practice",
                "sources": [
                    {
                        "title": "Deliberate Practice and Performance",
                        "doi": "10.1037/0033-295X.100.3.363",
                        "url": None,
                        "abstract": "Ericsson's foundational research on expert skill acquisition.",
                    },
                    {
                        "title": f"Mastering {skill_name}: A Practical Guide",
                        "doi": None,
                        "url": f"https://www.khanacademy.org/search?search_again=1&page_search_query={skill_name}",
                        "abstract": f"Hands-on exercises for building proficiency in {skill_name}.",
                    },
                ],
            },
            {
                "module_name": f"Advanced Applications of {skill_name}",
                "level": "Advanced",
                "difficulty_score": 85,
                "estimated_hours": 10,
                "pedagogical_basis": "Constructivism — building complex mental models",
                "sources": [
                    {
                        "title": "Cognitive Load Theory in Instructional Design",
                        "doi": "10.1007/BF01428364",
                        "url": None,
                        "abstract": "Sweller's theory on managing cognitive load for complex skill acquisition.",
                    },
                    {
                        "title": f"Expert Performance in {skill_name}",
                        "doi": None,
                        "url": "https://scholar.google.com",
                        "abstract": f"Research on expert-level {skill_name} performance patterns.",
                    },
                ],
            },
        ],
    }
