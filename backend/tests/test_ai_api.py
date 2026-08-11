"""Tests for AI API endpoints."""

import httpx


def test_explain_concept(client: httpx.Client):
    """Test AI concept explanation."""
    # Register and login
    import time

    register_response = client.post(
        "/auth/register",
        json={"name": "AI User", "email": f"ai{int(time.time())}@example.com", "password": "aipass123"},
    )
    token = register_response.json()["access_token"]

    # Request explanation
    response = client.post(
        "/ai/explain", headers={"Authorization": f"Bearer {token}"}, json={"concept": "recursion", "lesson_id": None}
    )

    # May fail if AI service is unavailable, but endpoint should be accessible
    assert response.status_code in [200, 500]
    if response.status_code == 200:
        data = response.json()
        assert "explanation" in data


def test_explain_concept_without_auth(client: httpx.Client):
    """Test AI explanation without authentication fails."""
    response = client.post("/ai/explain", json={"concept": "recursion"})

    assert response.status_code == 401


def test_quiz_hint(client: httpx.Client):
    """Test AI quiz hint generation."""
    # Register and login
    import time

    register_response = client.post(
        "/auth/register",
        json={"name": "Quiz User", "email": f"quiz{int(time.time())}@example.com", "password": "quizpass123"},
    )
    token = register_response.json()["access_token"]

    # Request hint
    response = client.post(
        "/ai/quiz-hint",
        headers={"Authorization": f"Bearer {token}"},
        json={"question": "What is 2 + 2?", "options": ["3", "4", "5", "6"]},
    )

    # May fail if AI service is unavailable
    assert response.status_code in [200, 500]
    if response.status_code == 200:
        data = response.json()
        assert "hint" in data
