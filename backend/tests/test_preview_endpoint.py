import pytest
from fastapi.testclient import TestClient
from app.main import app

def test_preview_endpoint_returns_preview():
    client = TestClient(app)
    resp = client.get("/curriculum/preview?skill_name=Python")
    assert resp.status_code == 200
    data = resp.json()
    assert "modules" in data
    assert isinstance(data["modules"], list)
    assert len(data["modules"]) > 0
    # Verify the first module matches the stub structure
    module = data["modules"][0]
    assert "module_name" in module
    assert "level" in module
