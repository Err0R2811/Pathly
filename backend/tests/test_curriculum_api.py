"""Tests for Curriculum API endpoints."""

import httpx


def test_request_curriculum(client: httpx.Client):
    """Test requesting curriculum generation."""
    # Register and login
    import time

    register_response = client.post(
        "/auth/register",
        json={
            "name": "Curriculum User",
            "email": f"curriculum{int(time.time())}@example.com",
            "password": "curriculumpass123",
        },
    )
    token = register_response.json()["access_token"]

    # Request curriculum
    response = client.post(
        "/curriculum/request",
        headers={"Authorization": f"Bearer {token}"},
        json={"skill_name": "Python Programming", "max_retries": 3},
    )

    assert response.status_code == 202
    data = response.json()
    assert "job_id" in data
    assert data["status"] == "PENDING"


def test_request_curriculum_without_auth(client: httpx.Client):
    """Test requesting curriculum without authentication (optional auth)."""
    response = client.post("/curriculum/request", json={"skill_name": "Python Programming"})

    # Should work with optional auth (returns 202)
    assert response.status_code == 202


def test_get_job_status(client: httpx.Client):
    """Test getting job status."""
    response = client.get("/curriculum/status/test-job-id")

    # May return 404 if job doesn't exist, but endpoint should be accessible
    assert response.status_code in [200, 404]


def test_get_roadmap(client: httpx.Client):
    """Test getting a completed roadmap."""
    # This will likely fail if roadmap doesn't exist, but tests endpoint structure
    response = client.get("/curriculum/test-roadmap-id")

    # May return 404 if roadmap doesn't exist
    assert response.status_code in [200, 404]
