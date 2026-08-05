"""Tests for Badges API endpoints."""
import pytest
import httpx


def test_get_all_badges(client: httpx.Client):
    """Test getting all available badges."""
    # Register and login
    import time
    register_response = client.post("/auth/register", json={
        "name": "Badges User",
        "email": f"badges{int(time.time())}@example.com",
        "password": "badgespass123"
    })
    token = register_response.json()["access_token"]
    
    # Get all badges
    response = client.get("/badges/",
        headers={"Authorization": f"Bearer {token}"}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)


def test_get_my_badges(client: httpx.Client):
    """Test getting user's earned badges."""
    # Register and login
    import time
    register_response = client.post("/auth/register", json={
        "name": "My Badges User",
        "email": f"mybadges{int(time.time())}@example.com",
        "password": "mybadgespass123"
    })
    token = register_response.json()["access_token"]
    
    # Get my badges
    response = client.get("/badges/my",
        headers={"Authorization": f"Bearer {token}"}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)


def test_seed_badges(client: httpx.Client):
    """Test seeding default badges."""
    response = client.post("/badges/seed")
    
    assert response.status_code == 200
    data = response.json()
    assert "message" in data


def test_get_badges_without_auth(client: httpx.Client):
    """Test getting badges without authentication fails."""
    response = client.get("/badges/")
    
    assert response.status_code == 401
