import uuid

from app.core.dependencies import get_current_user
from app.main import app


def test_patient_cannot_delete_evolution(client):
    class PatientUser:
        id = uuid.uuid4()
        clinic_id = uuid.uuid4()
        role = "patient"

    app.dependency_overrides[get_current_user] = lambda: PatientUser()
    response = client.delete(f"/api/evolutions/{uuid.uuid4()}")
    assert response.status_code == 403
    body = response.json()
    assert body["error"] == "Forbidden"


def test_reception_cannot_delete_evolution(client):
    class ReceptionUser:
        id = uuid.uuid4()
        clinic_id = uuid.uuid4()
        role = "reception"

    app.dependency_overrides[get_current_user] = lambda: ReceptionUser()
    response = client.delete(f"/api/evolutions/{uuid.uuid4()}")
    assert response.status_code == 403
    body = response.json()
    assert body["error"] == "Forbidden"
