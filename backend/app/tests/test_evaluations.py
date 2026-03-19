import uuid
from datetime import datetime

from app.services import evaluation_service


def test_validate_evaluation(client, monkeypatch):
    class DummyValidation:
        id = uuid.uuid4()
        clinic_id = uuid.uuid4()
        evaluation_id = uuid.uuid4()
        validated_by = uuid.uuid4()
        status = "approved"
        notes = None
        created_at = datetime.utcnow()
        deleted_at = None

    monkeypatch.setattr(evaluation_service, "validate_evaluation", lambda *args, **kwargs: DummyValidation())
    response = client.post(f"/api/evaluations/{uuid.uuid4()}/validate", json={"status": "approved"})
    assert response.status_code == 200
    assert response.json()["status"] == "approved"
