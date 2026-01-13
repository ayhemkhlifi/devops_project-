import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    """Test health endpoint returns 200"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_get_items_empty():
    """Test getting items when none exist"""
    response = client.get("/items")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_create_item():
    """Test creating a valid item"""
    item_data = {
        "name": "Test Item",
        "description": "A test item",
        "price": 29.99
    }
    response = client.post("/items", json=item_data)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test Item"
    assert data["price"] == 29.99
    assert "id" in data

def test_create_item_invalid_price():
    """Test validation for negative price"""
    item_data = {
        "name": "Invalid Item",
        "price": -10
    }
    response = client.post("/items", json=item_data)
    assert response.status_code == 422

def test_metrics_endpoint():
    """Test Prometheus metrics endpoint"""
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "api_requests_total" in response.text

def test_trace_id_header():
    """Test that trace ID is present in response headers"""
    response = client.get("/health")
    assert "X-Trace-ID" in response.headers
