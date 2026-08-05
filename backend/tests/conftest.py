import sys
import os
import pytest
from fastapi.testclient import TestClient

# Add the backend directory to sys.path for test imports
backend_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(backend_path)

from app.main import app


@pytest.fixture(scope="function")
def client():
    """Test client for making API requests."""
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture(scope="function", autouse=True)
def reset_database():
    """Reset database before each test."""
    # Skip database reset for now - tests use unique emails
    yield

