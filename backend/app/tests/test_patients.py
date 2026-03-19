import uuid
from datetime import date, datetime

from app.services import patient_service


def test_create_patient(client, monkeypatch):
    class DummyPatient:
        id = uuid.uuid4()
        clinic_id = uuid.uuid4()
        created_by = uuid.uuid4()
        updated_by = None
        name = "Ana"
        patient_code = "PAC-000001"
        cpf = None
        phone = None
        birth_date = date(2020, 1, 1)
        diagnosis = None
        notes = None
        created_at = datetime.utcnow()
        updated_at = None
        deleted_at = None
        guardians = []

    monkeypatch.setattr(patient_service, "create_patient", lambda *args, **kwargs: DummyPatient())
    payload = {"name": "Ana", "birth_date": "2020-01-01", "diagnosis": None, "notes": None, "guardians": []}
    response = client.post("/api/patients", json=payload)
    assert response.status_code == 200
    assert response.json()["name"] == "Ana"
