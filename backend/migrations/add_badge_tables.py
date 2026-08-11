"""Migration to add badge and user_badge tables to existing database."""

import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "pathly.db"


def migrate():
    """Add badges and user_badges tables to the database."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    try:
        # Create badges table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS badges (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL UNIQUE,
                description TEXT,
                icon_url TEXT,
                category TEXT,
                requirement_type TEXT,
                requirement_value INTEGER,
                custom_rule TEXT,
                is_active INTEGER DEFAULT 1
            )
        """)

        # Create user_badges table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS user_badges (
                id TEXT PRIMARY KEY,
                user_id TEXT NOT NULL,
                badge_id TEXT NOT NULL,
                earned_at TEXT,
                FOREIGN KEY (user_id) REFERENCES users(id),
                FOREIGN KEY (badge_id) REFERENCES badges(id)
            )
        """)

        # Create indexes for better query performance
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_user_badges_user_id ON user_badges(user_id)")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_user_badges_badge_id ON user_badges(badge_id)")

        conn.commit()
        print("Migration completed successfully! Added badges and user_badges tables.")

    except sqlite3.OperationalError as e:
        print(f"Migration error: {e}")
        conn.rollback()
    finally:
        conn.close()


if __name__ == "__main__":
    migrate()
