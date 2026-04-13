import uuid

from app.api.routes import auth as auth_route


def test_login_success(client, monkeypatch):
    class DummyUser:
        id = uuid.uuid4()
        clinic_id = uuid.uuid4()
        role = "admin"

    monkeypatch.setattr(auth_route, "authenticate", lambda db, email, password: DummyUser())
    response = client.post("/api/auth/login", json={"email": "a@b.com", "password": "12345678"})
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
