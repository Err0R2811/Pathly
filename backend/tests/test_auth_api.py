"""Tests for Authentication API endpoints."""

import httpx


def test_register_new_user(client: httpx.Client):
    """Test user registration."""
    import time

    email = f"test{int(time.time())}@example.com"
    response = client.post("/auth/register", json={"name": "Test User", "email": email, "password": "testpass123"})

    # Debug: print response if not 201
    if response.status_code != 201:
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")

    assert response.status_code == 201
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["user"]["email"] == email
    assert data["user"]["name"] == "Test User"


def test_register_duplicate_email(client: httpx.Client):
    """Test registration with duplicate email fails."""
    import time

    email = f"duplicate{int(time.time())}@example.com"
    # First registration
    client.post("/auth/register", json={"name": "User 1", "email": email, "password": "pass123"})

    # Duplicate registration
    response = client.post("/auth/register", json={"name": "User 2", "email": email, "password": "pass456"})

    assert response.status_code == 409


def test_login_valid_credentials(client: httpx.Client):
    """Test login with valid credentials."""
    import time

    email = f"login{int(time.time())}@example.com"
    # Register first
    client.post("/auth/register", json={"name": "Login User", "email": email, "password": "loginpass123"})

    # Login
    response = client.post("/auth/login", json={"email": email, "password": "loginpass123"})

    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["user"]["email"] == email


def test_login_invalid_credentials(client: httpx.Client):
    """Test login with invalid credentials fails."""
    response = client.post("/auth/login", json={"email": "nonexistent@example.com", "password": "wrongpass"})

    assert response.status_code == 401


def test_get_current_user_with_token(client: httpx.Client):
    """Test getting current user profile with valid token."""
    import time

    email = f"profile{int(time.time())}@example.com"
    # Register and login
    register_response = client.post(
        "/auth/register", json={"name": "Profile User", "email": email, "password": "profilepass123"}
    )
    token = register_response.json()["access_token"]

    # Get current user
    response = client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})

    assert response.status_code == 200
    data = response.json()
    assert data["email"] == email
    assert data["name"] == "Profile User"


def test_get_current_user_without_token(client: httpx.Client):
    """Test getting current user without token fails."""
    response = client.get("/auth/me")

    assert response.status_code == 401


def test_refresh_token(client: httpx.Client):
    """Test token refresh."""
    import time

    # Register
    register_response = client.post(
        "/auth/register",
        json={"name": "Refresh User", "email": f"refresh{int(time.time())}@example.com", "password": "refreshpass123"},
    )
    refresh_token = register_response.json()["refresh_token"]

    # Refresh
    response = client.post("/auth/refresh", json={"refresh_token": refresh_token})

    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
