"""Tests for Lessons API endpoints (consolidated from content.py)."""
import pytest
import httpx


def test_get_module_lessons(client: httpx.Client):
    """Test getting lessons for a module."""
    # Register and login
    import time
    register_response = client.post("/auth/register", json={
        "name": "Content User",
        "email": f"content{int(time.time())}@example.com",
        "password": "contentpass123"
    })
    token = register_response.json()["access_token"]
    
    # Get module lessons
    response = client.get("/lessons/module/test-module-id",
        headers={"Authorization": f"Bearer {token}"}
    )
    
    # May return 404 if module doesn't exist
    assert response.status_code in [200, 404]


def test_get_lesson(client: httpx.Client):
    """Test getting a specific lesson."""
    # Register and login
    import time
    register_response = client.post("/auth/register", json={
        "name": "Lesson User",
        "email": f"lesson{int(time.time())}@example.com",
        "password": "lessonpass123"
    })
    token = register_response.json()["access_token"]
    
    # Get lesson
    response = client.get("/lessons/test-lesson-id",
        headers={"Authorization": f"Bearer {token}"}
    )
    
    # May return 404 if lesson doesn't exist
    assert response.status_code in [200, 404]


def test_get_lesson_without_auth(client: httpx.Client):
    """Test getting lessons without authentication (should work with optional auth)."""
    response = client.get("/lessons/module/test-module-id")
    
    # Should work without auth (optional auth dependency)
    assert response.status_code in [200, 404]
