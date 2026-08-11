"""Migration to add lesson and lesson_step tables to existing database."""

import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "pathly.db"


def migrate():
    """Add lessons and lesson_steps tables to the database."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    try:
        # Create lessons table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS lessons (
                id TEXT PRIMARY KEY,
                module_id TEXT NOT NULL,
                lesson_title TEXT NOT NULL,
                lesson_order INTEGER DEFAULT 0,
                difficulty_level TEXT DEFAULT 'beginner',
                estimated_minutes INTEGER DEFAULT 30,
                learning_objectives TEXT,
                skills_gained TEXT,
                prerequisites TEXT,
                FOREIGN KEY (module_id) REFERENCES modules(id)
            )
        """)

        # Create lesson_steps table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS lesson_steps (
                id TEXT PRIMARY KEY,
                lesson_id TEXT NOT NULL,
                step_order INTEGER DEFAULT 0,
                step_type TEXT NOT NULL,
                title TEXT NOT NULL,
                content TEXT,
                quiz_options TEXT,
                correct_answer TEXT,
                video_url TEXT,
                video_duration INTEGER,
                FOREIGN KEY (lesson_id) REFERENCES lessons(id)
            )
        """)

        # Create indexes for better query performance
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_lessons_module_id ON lessons(module_id)")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_lesson_steps_lesson_id ON lesson_steps(lesson_id)")

        # Update user_progress table to reference lessons table
        # First check if the column exists and update if needed
        cursor.execute("PRAGMA table_info(user_progress)")
        columns = [col[1] for col in cursor.fetchall()]

        if "lesson_id" in columns:
            # Check if it's already a foreign key (SQLite doesn't enforce FKs by default, but we should update the schema)
            print("lesson_id column exists in user_progress, ensuring it can reference lessons table")
        else:
            cursor.execute("ALTER TABLE user_progress ADD COLUMN lesson_id TEXT")

        conn.commit()
        print("Migration completed successfully! Added lessons and lesson_steps tables.")

    except sqlite3.OperationalError as e:
        print(f"Migration error: {e}")
        conn.rollback()
    finally:
        conn.close()


if __name__ == "__main__":
    migrate()
