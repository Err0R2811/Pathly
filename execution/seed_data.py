"""Seed data script for Pathly backend.

This script populates the database with initial data for development and testing.
Run with: python execution/seed_data.py
"""
import sys
import os

# Add backend to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'backend'))

from backend.app.database import SessionLocal, engine
from backend.app.models import Base, Roadmap, Module, ResearchSource, Badge
from backend.app.services.achievement import seed_default_badges
import uuid
from datetime import datetime, timezone


def seed_roadmaps(db):
    """Seed sample roadmaps."""
    if db.query(Roadmap).count() > 0:
        print("Roadmaps already exist, skipping...")
        return

    roadmaps = [
        {
            "id": str(uuid.uuid4()),
            "skill_name": "Python Programming",
            "domain_type": "technical",
            "verification_score": 85,
            "certification_info": {
                "available_certifications": ["Python Institute Certified Associate"],
                "recommended_certification": "Python Institute Certified Associate",
                "certification_body": "Python Institute"
            },
            "prerequisites": ["Basic computer literacy", "Understanding of basic math"],
            "learning_objectives": [
                "Master Python syntax and fundamentals",
                "Build real-world applications",
                "Understand object-oriented programming"
            ],
            "career_outcomes": ["Python Developer", "Data Analyst", "Backend Engineer"],
            "salary_range": "$60,000 - $120,000",
            "market_demand": "Very High"
        },
        {
            "id": str(uuid.uuid4()),
            "skill_name": "Web Development",
            "domain_type": "technical",
            "verification_score": 90,
            "certification_info": {
                "available_certifications": ["AWS Certified Developer", "Google Cloud Developer"],
                "recommended_certification": "AWS Certified Developer",
                "certification_body": "Amazon Web Services"
            },
            "prerequisites": ["Basic HTML/CSS knowledge", "Computer literacy"],
            "learning_objectives": [
                "Build responsive web applications",
                "Master modern JavaScript frameworks",
                "Deploy applications to cloud"
            ],
            "career_outcomes": ["Frontend Developer", "Full Stack Developer", "Web Engineer"],
            "salary_range": "$70,000 - $140,000",
            "market_demand": "High"
        }
    ]

    for roadmap_data in roadmaps:
        roadmap = Roadmap(**roadmap_data)
        db.add(roadmap)
        db.flush()

        # Add modules for each roadmap
        for i in range(3):
            module = Module(
                id=str(uuid.uuid4()),
                roadmap_id=roadmap.id,
                module_name=f"Module {i + 1}: {roadmap.skill_name} Fundamentals",
                level="Beginner" if i == 0 else "Intermediate" if i == 1 else "Advanced",
                difficulty_score=20 + (i * 30),
                verification_alignment_score=80,
                estimated_hours=10 + (i * 10),
                pedagogical_basis="Project-based learning",
                learning_objectives=[f"Objective {j + 1}" for j in range(3)],
                skills_gained=[f"Skill {j + 1}" for j in range(3)],
                projects=[f"Project {i + 1}"],
                assessment_criteria="Pass practical assessment"
            )
            db.add(module)

    db.commit()
    print(f"Seeded {len(roadmaps)} roadmaps with modules")


def seed_badges(db):
    """Seed default badges using the achievement service."""
    seed_default_badges(db)
    print("Seeded default badges")


def main():
    """Main seeding function."""
    print("Starting data seeding...")
    
    # Create tables
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    try:
        seed_roadmaps(db)
        seed_badges(db)
        print("Data seeding completed successfully!")
    except Exception as e:
        print(f"Error seeding data: {e}")
        db.rollback()
        sys.exit(1)
    finally:
        db.close()


if __name__ == "__main__":
    main()
