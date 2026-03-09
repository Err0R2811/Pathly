import pytest
from sqlalchemy import create_engine, inspect
from app.models import Base

# Use a temporary SQLite DB for test purposes
engine = create_engine("sqlite:///:memory:")
Base.metadata.create_all(engine)


def test_roadmaps_table_exists():
    inspector = inspect(engine)
    assert "roadmaps" in inspector.get_table_names()
