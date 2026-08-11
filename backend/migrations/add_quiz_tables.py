"""Migration to add quiz_questions table to existing database."""

import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "pathly.db"


def migrate():
    """Add quiz_questions table to the database."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    try:
        # Create quiz_questions table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS quiz_questions (
                id TEXT PRIMARY KEY,
                module_id TEXT NOT NULL,
                question_order INTEGER DEFAULT 0,
                question TEXT NOT NULL,
                options TEXT,
                correct_answer TEXT NOT NULL,
                explanation TEXT,
                FOREIGN KEY (module_id) REFERENCES modules(id)
            )
        """)

        # Create indexes for better query performance
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_quiz_questions_module_id ON quiz_questions(module_id)")

        conn.commit()
        print("Migration completed successfully! Added quiz_questions table.")

    except sqlite3.OperationalError as e:
        print(f"Migration error: {e}")
        conn.rollback()
    finally:
        conn.close()


if __name__ == "__main__":
    migrate()
