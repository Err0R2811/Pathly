# ruff: noqa: E501
"""NVIDIA NIM-powered curriculum generator with YouTube integration.

Uses NVIDIA NIM API for fast, efficient curriculum generation.
Falls back to a rich static roadmap if the API call fails.
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

_SYSTEM_PROMPT = (
    "You are a master curriculum architect and expert educator. "
    "You design deep, highly structured, intuitive, and industry-aligned learning roadmaps. "
    "Your curriculums break complex topics down into clear, progressive mental models with rich explanations, "
    "practical projects, and rigorous assessment criteria. "
    "You always respond with valid JSON only — no markdown formatting, no unescaped quotes, no additional text."
)

_USER_PROMPT = """\
Generate an in-depth, industry-certified, and highly structured learning roadmap for the skill: "{skill_name}".

Target specifications:
- Difficulty level: {difficulty}
- Target completion time: {deadline_weeks} weeks
- Focus areas: {difficulty_focus}
- Target total study volume: ~{total_hours} hours

Return ONLY a valid JSON object with this exact structure:
{{
  "skill_name": "{skill_name}",
  "domain_type": "technical|creative|soft-skill",
  "certification_info": {{
    "available_certifications": ["list of recognized industry certifications"],
    "recommended_certification": "most valuable certification for career growth",
    "certification_body": "official organization offering the certification"
  }},
  "prerequisites": ["list of foundational concepts or prerequisites"],
  "learning_objectives": ["key overall high-level learning outcomes"],
  "modules": [
    {{
      "module_name": "clear, engaging module title",
      "level": "Beginner|Intermediate|Advanced|Expert",
      "difficulty_score": 1-100,
      "estimated_hours": integer,
      "learning_objectives": ["3-5 clear, specific, actionable module learning objectives"],
      "skills_gained": ["concrete practical skills acquired upon module completion"],
      "pedagogical_basis": "pedagogical strategy (e.g. Scaffolding, Bloom's Taxonomy, Project-Based Learning)",
      "projects": ["1-2 hands-on, real-world practical capstone projects"],
      "assessment_criteria": "clear criteria to evaluate mastery before proceeding",
      "sources": [
        {{
          "title": "reputable reference material title",
          "type": "book|course|article|documentation|video",
          "doi": "DOI string or null",
          "url": "URL string or null",
          "author": "author, instructor, or institution",
          "abstract": "concise, informative 1-2 sentence overview of why this resource is valuable",
          "relevance_score": 1-10
        }}
      ]
    }}
  ],
  "career_outcomes": ["concrete target job roles enabled by mastering this skill"],
  "salary_range": "realistic expected salary range",
  "market_demand": "High|Very High|Growing|Niche"
}}

Rules:
- Include 5-7 distinct modules building logically from foundational mechanics to advanced mastery.
- Each module MUST include at least 3 high-quality sources (documentation, top books, courses, or peer-reviewed materials).
- Module difficulty scores must scale logically (Beginner: 10-25, Intermediate: 30-55, Advanced: 60-80, Expert: 85-95).
- Provide realistic hour estimates that sum up to approximately {total_hours} total hours across {deadline_weeks} weeks.
- Ensure all descriptions are written in clear, structured, and easily digestible language.
"""


async def generate_roadmap(skill_name: str, difficulty: str = "beginner", deadline_weeks: int = 4) -> dict:
    """Call NVIDIA API / OpenAI-compatible client to generate a curriculum roadmap with YouTube integration.
    Falls back to static data on error."""

    # Calculate difficulty-specific parameters
    difficulty_focus_map = {
        "beginner": "foundational concepts, gentle learning curve, hands-on basics",
        "intermediate": "practical application, real-world projects, deeper understanding",
        "advanced": "complex topics, optimization, best practices, architecture",
    }

    hours_per_week_map = {"beginner": 5, "intermediate": 8, "advanced": 12}

    difficulty_focus = difficulty_focus_map.get(difficulty, difficulty_focus_map["beginner"])
    hours_per_week = hours_per_week_map.get(difficulty, hours_per_week_map["beginner"])
    total_hours = deadline_weeks * hours_per_week

    if not NVIDIA_API_KEY:
        print("[generator] NVIDIA_API_KEY not set, using fallback.")
        return await _static_fallback(skill_name)

    headers = {
        "Authorization": f"Bearer {NVIDIA_API_KEY}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": NVIDIA_MODEL,
        "messages": [
            {"role": "system", "content": _SYSTEM_PROMPT},
            {
                "role": "user",
                "content": _USER_PROMPT.format(
                    skill_name=skill_name,
                    difficulty=difficulty,
                    deadline_weeks=deadline_weeks,
                    difficulty_focus=difficulty_focus,
                    total_hours=total_hours,
                ),
            },
        ],
        "temperature": 0.7,
        "response_format": {"type": "json_object"},
    }

    try:
        async with httpx.AsyncClient(timeout=90.0) as client:
            response = await client.post(
                f"{NVIDIA_BASE_URL}/chat/completions",
                headers=headers,
                json=payload,
            )
            response.raise_for_status()
            content = response.json()["choices"][0]["message"]["content"]
            roadmap = json.loads(content)
            roadmap.setdefault("verification_score", 0)

            # Enhance with YouTube videos for each module (parallelized)
            async def enrich_module_with_videos(module):
                module_name = module.get("module_name", "")
                search_query = f"{skill_name} {module_name} tutorial course"
                videos = await search_youtube_videos(search_query, max_results=3)

                # Add videos as additional sources
                for video in videos:
                    module["sources"].append(
                        {
                            "title": video["title"],
                            "type": "video",
                            "url": video["url"],
                            "author": video["channel"],
                            "abstract": f"Video tutorial ({video['duration_formatted']})",
                            "relevance_score": 8,
                            "video_duration": video["duration"],
                            "thumbnail": video["thumbnail"],
                        }
                    )
                return module

            # Process modules in parallel with concurrency limit
            semaphore = asyncio.Semaphore(5)  # Limit concurrent YouTube API calls

            async def enrich_with_semaphore(module):
                async with semaphore:
                    return await enrich_module_with_videos(module)

            enriched_modules = await asyncio.gather(
                *[enrich_with_semaphore(module) for module in roadmap.get("modules", [])], return_exceptions=True
            )

            # Replace modules with enriched versions (filter out exceptions)
            valid_modules = [m for m in enriched_modules if not isinstance(m, Exception)]
            for idx, mod in enumerate(valid_modules, start=1):
                mod.setdefault("id", f"mod-{idx}")
                mod.setdefault("verification_alignment_score", 0)
                mod.setdefault("sources", [])
            roadmap["modules"] = valid_modules

            return roadmap
    except Exception as exc:
        print(f"[generator] OpenRouter/NVIDIA call failed ({exc}), using fallback.")
        return await _static_fallback(skill_name)


async def _static_fallback(skill_name: str) -> dict:
    """Rich static roadmap used when API is unavailable with YouTube integration."""
    roadmap = {
        "skill_name": skill_name,
        "domain_type": "technical",
        "verification_score": 0,
        "certification_info": {
            "available_certifications": [f"Certified {skill_name} Professional", f"Advanced {skill_name} Specialist"],
            "recommended_certification": f"Certified {skill_name} Professional",
            "certification_body": "International Skill Certification Board",
        },
        "prerequisites": [
            "Basic computer literacy",
            "Internet access for research",
            "Willingness to practice regularly",
        ],
        "learning_objectives": [
            f"Master fundamental concepts of {skill_name}",
            "Apply {skill_name} techniques in real-world scenarios",
            "Develop problem-solving skills in {skill_name}",
        ],
        "modules": [
            {
                "module_name": f"Foundations of {skill_name}",
                "level": "Beginner",
                "difficulty_score": 15,
                "estimated_hours": 15,
                "learning_objectives": [
                    f"Understand core concepts of {skill_name}",
                    "Learn basic terminology and principles",
                    "Set up development environment for {skill_name}",
                ],
                "skills_gained": ["Fundamental knowledge", "Basic tool usage", "Problem-solving mindset"],
                "pedagogical_basis": "Bloom's Taxonomy — knowledge and comprehension",
                "projects": [f"Build a simple {skill_name} project", "Complete beginner exercises"],
                "assessment_criteria": "Pass basic knowledge quiz and complete first project",
                "sources": [
                    {
                        "title": f"Introduction to {skill_name}",
                        "type": "article",
                        "doi": None,
                        "url": f"https://en.wikipedia.org/wiki/{skill_name.replace(' ', '_')}",
                        "author": "Wikipedia Contributors",
                        "abstract": f"A comprehensive introduction to {skill_name}.",
                        "relevance_score": 7,
                    },
                    {
                        "title": "Learning How to Learn",
                        "type": "course",
                        "doi": "10.1016/j.lindif.2014.08.010",
                        "url": "https://www.coursera.org/learn/learning-how-to-learn",
                        "author": "Dr. Barbara Oakley",
                        "abstract": "Evidence-based strategies for effective learning and memory retention.",
                        "relevance_score": 9,
                    },
                    {
                        "title": f"{skill_name} Fundamentals",
                        "type": "documentation",
                        "doi": None,
                        "url": "https://docs.google.com",
                        "author": "Official Documentation",
                        "abstract": f"Official documentation for {skill_name} basics.",
                        "relevance_score": 8,
                    },
                ],
            },
            {
                "module_name": f"Core Techniques in {skill_name}",
                "level": "Intermediate",
                "difficulty_score": 45,
                "estimated_hours": 30,
                "learning_objectives": [
                    f"Master intermediate {skill_name} techniques",
                    "Apply best practices and patterns",
                    "Build medium-complexity projects",
                ],
                "skills_gained": ["Intermediate techniques", "Best practices", "Project development"],
                "pedagogical_basis": "Project-based learning with deliberate practice",
                "projects": [f"Build a complete {skill_name} application", "Contribute to open-source projects"],
                "assessment_criteria": "Complete intermediate project and pass practical assessment",
                "sources": [
                    {
                        "title": "Deliberate Practice and Performance",
                        "type": "article",
                        "doi": "10.1037/0033-295X.100.3.363",
                        "url": None,
                        "author": "K. Anders Ericsson",
                        "abstract": "Ericsson's foundational research on expert skill acquisition.",
                        "relevance_score": 9,
                    },
                    {
                        "title": f"Mastering {skill_name}: A Practical Guide",
                        "type": "course",
                        "doi": None,
                        "url": f"https://www.khanacademy.org/search?search_again=1&page_search_query={skill_name}",
                        "author": "Khan Academy",
                        "abstract": f"Hands-on exercises for building proficiency in {skill_name}.",
                        "relevance_score": 8,
                    },
                    {
                        "title": f"{skill_name} Best Practices",
                        "type": "documentation",
                        "doi": None,
                        "url": "https://stackoverflow.com",
                        "author": "Community",
                        "abstract": "Community-driven best practices and solutions.",
                        "relevance_score": 7,
                    },
                ],
            },
            {
                "module_name": f"Advanced Applications of {skill_name}",
                "level": "Advanced",
                "difficulty_score": 75,
                "estimated_hours": 50,
                "learning_objectives": [
                    f"Master advanced {skill_name} concepts",
                    "Optimize performance and scalability",
                    "Architect complex systems",
                ],
                "skills_gained": ["Advanced techniques", "Performance optimization", "System architecture"],
                "pedagogical_basis": "Constructivism — building complex mental models",
                "projects": [f"Build enterprise-level {skill_name} system", "Optimize existing applications"],
                "assessment_criteria": "Complete advanced project and pass technical interview",
                "sources": [
                    {
                        "title": "Cognitive Load Theory in Instructional Design",
                        "type": "article",
                        "doi": "10.1007/BF01428364",
                        "url": None,
                        "author": "John Sweller",
                        "abstract": "Sweller's theory on managing cognitive load for complex skill acquisition.",
                        "relevance_score": 8,
                    },
                    {
                        "title": f"Expert Performance in {skill_name}",
                        "type": "article",
                        "doi": None,
                        "url": "https://scholar.google.com",
                        "author": "Research Community",
                        "abstract": f"Research on expert-level {skill_name} performance patterns.",
                        "relevance_score": 7,
                    },
                    {
                        "title": f"{skill_name} Architecture Patterns",
                        "type": "book",
                        "doi": None,
                        "url": "https://www.oreilly.com",
                        "author": "Industry Experts",
                        "abstract": "Comprehensive guide to architectural patterns.",
                        "relevance_score": 9,
                    },
                ],
            },
            {
                "module_name": f"Expert Mastery in {skill_name}",
                "level": "Expert",
                "difficulty_score": 90,
                "estimated_hours": 70,
                "learning_objectives": [
                    f"Become a recognized expert in {skill_name}",
                    "Contribute to the field",
                    "Mentor others",
                ],
                "skills_gained": ["Expert-level knowledge", "Leadership skills", "Mentoring ability"],
                "pedagogical_basis": "Social learning theory and mentorship",
                "projects": [
                    f"Create innovative {skill_name} solutions",
                    "Publish research or tutorials",
                    "Mentor junior developers",
                ],
                "assessment_criteria": "Demonstrate expertise through portfolio and community contribution",
                "sources": [
                    {
                        "title": f"The Art of {skill_name}",
                        "type": "book",
                        "doi": None,
                        "url": "https://www.amazon.com",
                        "author": "Industry Leaders",
                        "abstract": "Master-level insights from industry experts.",
                        "relevance_score": 9,
                    },
                    {
                        "title": f"{skill_name} Research Papers",
                        "type": "article",
                        "doi": None,
                        "url": "https://arxiv.org",
                        "author": "Academic Community",
                        "abstract": "Latest research and developments in {skill_name}.",
                        "relevance_score": 8,
                    },
                    {
                        "title": f"{skill_name} Conference Proceedings",
                        "type": "documentation",
                        "doi": None,
                        "url": "https://youtube.com",
                        "author": "Conference Organizers",
                        "abstract": "Conference talks and presentations from experts.",
                        "relevance_score": 8,
                    },
                ],
            },
        ],
        "career_outcomes": [
            f"{skill_name} Developer",
            f"{skill_name} Consultant",
            f"{skill_name} Architect",
            f"{skill_name} Specialist",
        ],
        "salary_range": "$60,000 - $150,000+ depending on experience and location",
        "market_demand": "High demand across multiple industries",
    }

    # Add YouTube videos and default fields to each module
    for idx, module in enumerate(roadmap["modules"], start=1):
        module.setdefault("id", f"mod-{idx}")
        module.setdefault("verification_alignment_score", 0)
        module_name = module.get("module_name", "")
        search_query = f"{skill_name} {module_name} tutorial course"
        videos = await search_youtube_videos(search_query, max_results=2)

        for video in videos:
            module["sources"].append(
                {
                    "title": video["title"],
                    "type": "video",
                    "url": video["url"],
                    "author": video["channel"],
                    "abstract": f"Video tutorial ({video['duration_formatted']})",
                    "relevance_score": 8,
                    "video_duration": video["duration"],
                    "thumbnail": video["thumbnail"],
                }
            )

    return roadmap
