"""Migration to add last_activity_date column to users table."""
import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "pathly.db"

def migrate():
    """Add last_activity_date column to users table."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    try:
        # Check if column exists
        cursor.execute("PRAGMA table_info(users)")
        columns = [col[1] for col in cursor.fetchall()]
        
        if 'last_activity_date' not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN last_activity_date TEXT")
            conn.commit()
            print("Migration completed successfully! Added last_activity_date column.")
        else:
            print("Column last_activity_date already exists, skipping migration.")
        
    except sqlite3.OperationalError as e:
        print(f"Migration error: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    migrate()
