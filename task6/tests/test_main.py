import pytest
import sys
import os

# Add the parent directory to the path so we can import main
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app

@pytest.fixture
def client():
    """Create a test client for the Flask application."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_hello_endpoint(client):
    """Test the hello endpoint returns correct message."""
    response = client.get('/')
    assert response.status_code == 200
    assert b'Hello, rs World!' in response.data

def test_hello_endpoint_content_type(client):
    """Test the hello endpoint returns correct content type."""
    response = client.get('/')
    assert response.content_type == 'text/html; charset=utf-8'

def test_app_is_running():
    """Test that the Flask app is properly configured."""
    assert app is not None
    assert app.config['TESTING'] == True