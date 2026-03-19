from datetime import datetime

from sqlalchemy.orm import Session, selectinload

from app.models import Guardian, GuardianPatient, Patient
from app.schemas.schemas import GuardianCreate, GuardianUpdate
from app.services.audit_service import log_action
from app.services.email_service import send_confirmation_email_async
from app.services.patient_service import _normalize_phone
from app.services.user_service import ensure_linked_user


def _normalize_patient_ids(guardian_in: GuardianCreate | GuardianUpdate) -> list:
    patient_ids = list(getattr(guardian_in, "patient_ids", None) or [])
    if getattr(guardian_in, "patient_id", None):
        patient_ids.append(guardian_in.patient_id)
    return [patient_id for patient_id in dict.fromkeys(patient_ids) if patient_id]


def _sync_guardian_patient_links(db: Session, clinic_id, guardian: Guardian, patient_ids: list | None) -> None:
    normalized_ids = [patient_id for patient_id in dict.fromkeys(patient_ids or []) if patient_id]
    db.query(GuardianPatient).filter(GuardianPatient.guardian_id == guardian.id).delete(synchronize_session=False)
    if not normalized_ids:
        return

    patients = (
        db.query(Patient)
        .filter(Patient.id.in_(normalized_ids), Patient.clinic_id == clinic_id, Patient.deleted_at.is_(None))
        .all()
    )
    for patient in patients:
        db.add(GuardianPatient(guardian_id=guardian.id, patient_id=patient.id))


def create_guardian(db: Session, clinic_id, user_id, guardian_in: GuardianCreate) -> Guardian:
    guardian = Guardian(
        clinic_id=clinic_id,
        name=guardian_in.name,
        phone=_normalize_phone(guardian_in.phone),
        email=guardian_in.email.lower().strip() if guardian_in.email else None,
        relationship_type=guardian_in.relationship_type,
    )
    db.add(guardian)
    db.flush()

    _sync_guardian_patient_links(db, clinic_id, guardian, _normalize_patient_ids(guardian_in))

    linked_user = ensure_linked_user(
        db,
        name=guardian_in.name,
        email=guardian_in.email,
        password=guardian_in.password,
        role="guardian",
        clinic_id=clinic_id,
        guardian_id=guardian.id,
    )

    db.commit()
    guardian = (
        db.query(Guardian)
        .options(selectinload(Guardian.patients))
        .filter(Guardian.id == guardian.id)
        .first()
    )
    send_confirmation_email_async(
        linked_user.email if linked_user else guardian.email,
        linked_user.name if linked_user else guardian.name,
        email_is_confirmed=linked_user.email_is_confirmed if linked_user else False,
    )
    log_action(db, clinic_id=clinic_id, user_id=user_id, action="create", entity="guardian", entity_id=guardian.id)
    return guardian


def update_guardian(db: Session, clinic_id, guardian_id, guardian_in: GuardianUpdate, updated_by) -> Guardian:
    guardian = (
        db.query(Guardian)
        .filter(Guardian.id == guardian_id, Guardian.clinic_id == clinic_id, Guardian.deleted_at.is_(None))
        .first()
    )
    if not guardian:
        raise ValueError("Guardian not found")

    payload = guardian_in.model_dump(exclude_unset=True, by_alias=False)
    patient_ids = payload.pop("patient_ids", None)
    patient_id = payload.pop("patient_id", None)
    if patient_id:
        patient_ids = [*(patient_ids or []), patient_id]
    if "phone" in payload:
        payload["phone"] = _normalize_phone(payload.get("phone"))
    if "email" in payload and payload.get("email"):
        payload["email"] = payload["email"].lower().strip()

    for field, value in payload.items():
        if field == "password":
            continue
        setattr(guardian, field, value)

    if patient_ids is not None:
        _sync_guardian_patient_links(db, clinic_id, guardian, patient_ids)

    linked_user = ensure_linked_user(
        db,
        name=payload.get("name", guardian.name),
        email=payload.get("email", guardian.email),
        password=payload.get("password"),
        role="guardian",
        clinic_id=clinic_id,
        guardian_id=guardian.id,
    )

    db.commit()
    guardian = (
        db.query(Guardian)
        .options(selectinload(Guardian.patients))
        .filter(Guardian.id == guardian.id)
        .first()
    )
    if payload.get("email"):
        send_confirmation_email_async(
            linked_user.email if linked_user else payload.get("email"),
            linked_user.name if linked_user else payload.get("name", guardian.name),
            email_is_confirmed=linked_user.email_is_confirmed if linked_user else False,
        )
    log_action(db, clinic_id=clinic_id, user_id=updated_by, action="update", entity="guardian", entity_id=guardian.id)
    return guardian


def soft_delete_guardian(db: Session, clinic_id, guardian_id, deleted_by) -> None:
    guardian = (
        db.query(Guardian)
        .filter(Guardian.id == guardian_id, Guardian.clinic_id == clinic_id, Guardian.deleted_at.is_(None))
        .first()
    )
    if not guardian:
        raise ValueError("Guardian not found")
    guardian.deleted_at = datetime.utcnow()
    db.query(GuardianPatient).filter(GuardianPatient.guardian_id == guardian.id).delete(synchronize_session=False)
    db.commit()
    log_action(db, clinic_id=clinic_id, user_id=deleted_by, action="delete", entity="guardian", entity_id=guardian.id)
