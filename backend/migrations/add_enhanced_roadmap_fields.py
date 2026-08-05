"""Migration to add enhanced roadmap fields to existing database."""
import sqlite3
import json
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "pathly.db"

def migrate():
    """Add new columns to roadmaps, modules, and research_sources tables."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    try:
        # Add columns to roadmaps table
        cursor.execute("ALTER TABLE roadmaps ADD COLUMN certification_info TEXT")
        cursor.execute("ALTER TABLE roadmaps ADD COLUMN prerequisites TEXT")
        cursor.execute("ALTER TABLE roadmaps ADD COLUMN learning_objectives TEXT")
        cursor.execute("ALTER TABLE roadmaps ADD COLUMN career_outcomes TEXT")
        cursor.execute("ALTER TABLE roadmaps ADD COLUMN salary_range TEXT")
        cursor.execute("ALTER TABLE roadmaps ADD COLUMN market_demand TEXT")
        
        # Add columns to modules table
        cursor.execute("ALTER TABLE modules ADD COLUMN learning_objectives TEXT")
        cursor.execute("ALTER TABLE modules ADD COLUMN skills_gained TEXT")
        cursor.execute("ALTER TABLE modules ADD COLUMN projects TEXT")
        cursor.execute("ALTER TABLE modules ADD COLUMN assessment_criteria TEXT")
        
        # Add columns to research_sources table
        cursor.execute("ALTER TABLE research_sources ADD COLUMN source_type TEXT")
        cursor.execute("ALTER TABLE research_sources ADD COLUMN author TEXT")
        cursor.execute("ALTER TABLE research_sources ADD COLUMN relevance_score INTEGER")
        cursor.execute("ALTER TABLE research_sources ADD COLUMN video_duration INTEGER")
        cursor.execute("ALTER TABLE research_sources ADD COLUMN thumbnail TEXT")
        
        conn.commit()
        print("Migration completed successfully!")
        
    except sqlite3.OperationalError as e:
        if "duplicate column name" in str(e):
            print("Columns already exist, skipping migration.")
        else:
            print(f"Migration error: {e}")
            conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    migrate()
