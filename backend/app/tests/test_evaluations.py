import uuid
from datetime import UTC, datetime

from app.core.dependencies import get_current_user
from app.main import app
from app.api.routes import evaluations as evaluations_route
from app.services import evaluation_service


def test_validate_evaluation(client, monkeypatch):
    class DummyValidation:
        id = uuid.uuid4()
        clinic_id = uuid.uuid4()
        evaluation_id = uuid.uuid4()
        validated_by = uuid.uuid4()
        status = "approved"
        notes = None
        created_at = datetime.now(UTC)
        deleted_at = None

    monkeypatch.setattr(evaluations_route, "validate_evaluation", lambda *args, **kwargs: DummyValidation())
    response = client.post(f"/api/evaluations/{uuid.uuid4()}/validate", json={"status": "approved"})
    assert response.status_code == 200
    assert response.json()["status"] == "approved"


def test_receptionist_cannot_validate_evaluation(client):
    class ReceptionUser:
        id = uuid.uuid4()
        clinic_id = uuid.uuid4()
        role = "receptionist"

    app.dependency_overrides[get_current_user] = lambda: ReceptionUser()
    response = client.post(f"/api/evaluations/{uuid.uuid4()}/validate", json={"status": "approved"})
    assert response.status_code == 403
    body = response.json()
    assert body["error"] == "Forbidden"
