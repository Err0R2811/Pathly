"""OpenAI-powered reviewer service.

Scores the generated roadmap for pedagogical quality and citation alignment.
Retries externally if score < 85. Falls back to default scoring if API unavailable.
"""
from __future__ import annotations
import os
import json
import httpx
from copy import deepcopy

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "")
OPENAI_MODEL = os.getenv("OPENROUTER_MODEL", "google/gemini-2.0-flash-001")
OPENAI_BASE_URL = os.getenv("OPENROUTER_BASE_URL", "https://openrouter.ai/api/v1")

_SYSTEM_PROMPT = (
    "You are a strict academic curriculum reviewer. "
    "You always respond with valid JSON only — no markdown, no extra text."
)

_REVIEWER_PROMPT = """\
Review this learning roadmap and score it for pedagogical quality, citation quality, and progression logic.

Roadmap JSON:
{roadmap_json}

Return ONLY a valid JSON object:
{{
  "overall_alignment_score": 0-100,
  "feedback": "brief overall feedback",
  "module_scores": [
    {{
      "module_name": "exact module name from roadmap",
      "alignment_score": 0-100,
      "feedback": "brief feedback"
    }}
  ]
}}

Scoring: 90-100 Excellent, 75-89 Good, 60-74 Fair, <60 Poor.
"""


async def review_roadmap(roadmap: dict, max_retries: int = 3) -> dict:
    """Score the roadmap and attach alignment scores."""
    reviewed = deepcopy(roadmap)

    if not OPENROUTER_API_KEY:
        print("[reviewer] OPENROUTER_API_KEY not set, using fallback scoring.")
        return _apply_fallback_scores(reviewed)

    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://pathly.app",
        "X-Title": "Pathly Curriculum Reviewer",
    }
    payload = {
        "model": OPENAI_MODEL,
        "messages": [
            {"role": "system", "content": _SYSTEM_PROMPT},
            {
                "role": "user",
                "content": _REVIEWER_PROMPT.format(
                    roadmap_json=json.dumps(roadmap, indent=2)
                ),
            },
        ],
        "temperature": 0.3,
        "response_format": {"type": "json_object"},
    }

    try:
        async with httpx.AsyncClient(timeout=90.0) as client:
            response = await client.post(
                f"{OPENAI_BASE_URL}/chat/completions",
                headers=headers,
                json=payload,
            )
            response.raise_for_status()
            content = response.json()["choices"][0]["message"]["content"]
            review_data = json.loads(content)

            reviewed["verification_score"] = review_data.get("overall_alignment_score", 72)
            module_scores = {
                ms["module_name"]: ms.get("alignment_score", 72)
                for ms in review_data.get("module_scores", [])
            }
            for module in reviewed.get("modules", []):
                module["verification_alignment_score"] = module_scores.get(
                    module["module_name"], 72
                )
            return reviewed

    except Exception as exc:
        print(f"[reviewer] OpenRouter call failed ({exc}), using fallback scoring.")
        return _apply_fallback_scores(reviewed)


def _apply_fallback_scores(roadmap: dict) -> dict:
    roadmap["verification_score"] = 72
    for module in roadmap.get("modules", []):
        module.setdefault("verification_alignment_score", 72)
    return roadmap
