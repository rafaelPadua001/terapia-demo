import uuid

from app.services import user_service


def test_login_success(client, monkeypatch):
    class DummyUser:
        id = uuid.uuid4()
        clinic_id = uuid.uuid4()
        role = "admin"

    monkeypatch.setattr(user_service, "authenticate", lambda db, email, password: DummyUser())
    response = client.post("/api/auth/login", json={"email": "a@b.com", "password": "12345678"})
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
