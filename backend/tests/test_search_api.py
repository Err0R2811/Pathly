"""Tests for Search API endpoints."""

import httpx


def test_search_content(client: httpx.Client):
    """Test semantic search over content."""
    # Register and login
    import time

    register_response = client.post(
        "/auth/register",
        json={"name": "Search User", "email": f"search{int(time.time())}@example.com", "password": "searchpass123"},
    )
    token = register_response.json()["access_token"]

    # Search
    response = client.get("/search/?q=python&limit=10", headers={"Authorization": f"Bearer {token}"})

    assert response.status_code == 200
    data = response.json()
    assert "query" in data
    assert "results" in data
    assert "search_type" in data


def test_search_without_auth(client: httpx.Client):
    """Test search without authentication fails."""
    response = client.get("/search/?q=python")

    assert response.status_code == 401


def test_search_with_content_type_filter(client: httpx.Client):
    """Test search with content type filter."""
    # Register and login
    import time

    register_response = client.post(
        "/auth/register",
        json={
            "name": "Filter Search User",
            "email": f"filtersearch{int(time.time())}@example.com",
            "password": "filtersearchpass123",
        },
    )
    token = register_response.json()["access_token"]

    # Search with filter
    response = client.get(
        "/search/?q=python&content_type=roadmap&limit=10", headers={"Authorization": f"Bearer {token}"}
    )

    assert response.status_code == 200
    data = response.json()
    assert "query" in data
