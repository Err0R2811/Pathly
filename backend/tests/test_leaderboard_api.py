"""Tests for Leaderboard API endpoints."""
import pytest
import httpx


def test_get_leaderboard(client: httpx.Client):
    """Test getting leaderboard entries."""
    response = client.get("/leaderboard/?leaderboard_type=all_time&limit=10")
    
    assert response.status_code == 200
    data = response.json()
    assert "leaderboard_type" in data
    assert "entries" in data
    assert "count" in data
    assert isinstance(data["entries"], list)


def test_get_my_rank(client: httpx.Client):
    """Test getting current user's rank."""
    # Register and login
    import time
    register_response = client.post("/auth/register", json={
        "name": "Leaderboard User",
        "email": f"leaderboard{int(time.time())}@example.com",
        "password": "leaderboardpass123"
    })
    token = register_response.json()["access_token"]
    
    # Get my rank
    response = client.get("/leaderboard/my-rank?leaderboard_type=all_time",
        headers={"Authorization": f"Bearer {token}"}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "user_id" in data
    assert "rank" in data


def test_get_my_rank_without_auth(client: httpx.Client):
    """Test getting rank without authentication fails."""
    response = client.get("/leaderboard/my-rank")
    
    assert response.status_code == 401


def test_get_weekly_leaderboard(client: httpx.Client):
    """Test getting weekly leaderboard."""
    response = client.get("/leaderboard/?leaderboard_type=weekly&limit=10")
    
    assert response.status_code == 200
    data = response.json()
    assert data["leaderboard_type"] == "weekly"


def test_get_monthly_leaderboard(client: httpx.Client):
    """Test getting monthly leaderboard."""
    response = client.get("/leaderboard/?leaderboard_type=monthly&limit=10")
    
    assert response.status_code == 200
    data = response.json()
    assert data["leaderboard_type"] == "monthly"
