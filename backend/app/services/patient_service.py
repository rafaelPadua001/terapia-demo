from datetime import datetime

from sqlalchemy import text
from sqlalchemy.orm import Session, selectinload

from app.models import Guardian, GuardianPatient, Patient
from app.schemas.schemas import PatientCreate, PatientUpdate
from app.services.audit_service import log_action
from app.services.email_service import send_confirmation_email_async
from app.services.rbac_service import apply_role_filter, resolve_guardian_patient_ids, resolve_patient_id
from app.services.user_service import ensure_linked_user


def _normalize_cpf(value: str | None) -> str | None:
    if not value:
        return None
    digits = "".join(char for char in value if char.isdigit())
    return digits or None



def _normalize_phone(value: str | None) -> str | None:
    if not value:
        return None
    digits = "".join(char for char in value if char.isdigit())
    return digits or None



def _next_patient_code(db: Session) -> str:
    next_value = db.execute(text("SELECT nextval('patient_code_seq')")).scalar_one()
    return f"PAC-{next_value:06d}"



def _sync_patient_guardian_links(db: Session, clinic_id, patient_id, guardian_ids: list | None) -> None:
    normalized_ids = [guardian_id for guardian_id in dict.fromkeys(guardian_ids or []) if guardian_id]
    db.query(GuardianPatient).filter(GuardianPatient.patient_id == patient_id).delete(synchronize_session=False)

    if not normalized_ids:
        return

    guardians = (
        db.query(Guardian)
        .filter(Guardian.id.in_(normalized_ids), Guardian.clinic_id == clinic_id, Guardian.deleted_at.is_(None))
        .all()
    )
    for guardian in guardians:
        db.add(GuardianPatient(guardian_id=guardian.id, patient_id=patient_id))



def get_patient_with_guardians(db: Session, user, patient_id):
    query = (
        db.query(Patient)
        .options(selectinload(Patient.guardians))
        .filter(Patient.clinic_id == user.clinic_id, Patient.id == patient_id, Patient.deleted_at.is_(None))
    )
    query = apply_role_filter(query, user, Patient)
    patient = query.first()
    if not patient:
        raise ValueError("Patient not found")
    return patient



def get_guardian_patients(db: Session, user_id):
    return (
        db.query(Patient)
        .join(GuardianPatient, GuardianPatient.patient_id == Patient.id)
        .filter(GuardianPatient.guardian_id == user_id, Patient.deleted_at.is_(None))
        .options(selectinload(Patient.guardians))
        .order_by(Patient.name.asc())
        .all()
    )



def list_patients(db: Session, user, page: int, limit: int, search: str | None = None, show_deleted: bool = False):
    query = db.query(Patient).options(selectinload(Patient.guardians)).filter(Patient.clinic_id == user.clinic_id)
    if not show_deleted:
        query = query.filter(Patient.deleted_at.is_(None))
    if search:
        query = query.filter(Patient.name.ilike(f"%{search}%"))
    if user.role == "patient":
        patient_id = resolve_patient_id(db, user)
        if not patient_id:
            return [], 0
        query = query.filter(Patient.id == patient_id)
    elif user.role == "guardian":
        patient_ids = resolve_guardian_patient_ids(db, user)
        if not patient_ids:
            return [], 0
        query = query.filter(Patient.id.in_(patient_ids))
    query = apply_role_filter(query, user, Patient)
    total = query.count()
    items = query.order_by(Patient.created_at.desc()).offset((page - 1) * limit).limit(limit).all()
    return items, total



def get_patient_by_id(db: Session, user, patient_id):
    return get_patient_with_guardians(db, user, patient_id)



def create_patient(db: Session, clinic_id, created_by, patient_in: PatientCreate) -> Patient:
    patient = Patient(
        clinic_id=clinic_id,
        created_by=created_by,
        name=patient_in.name,
        patient_code=_next_patient_code(db),
        birth_date=patient_in.birth_date,
        diagnosis=patient_in.diagnosis,
        notes=patient_in.notes,
        cpf=_normalize_cpf(patient_in.cpf),
        email=patient_in.email.lower().strip() if patient_in.email else None,
        phone=_normalize_phone(patient_in.phone),
    )
    db.add(patient)
    db.flush()

    patient_user = ensure_linked_user(
        db,
        name=patient_in.name,
        email=patient_in.email,
        password=patient_in.password,
        role="patient",
        clinic_id=clinic_id,
        patient_id=patient.id,
    )

    guardian_users = []
    linked_guardian_ids = list(patient_in.guardian_ids)
    for guardian_in in patient_in.guardians:
        guardian = Guardian(
            clinic_id=clinic_id,
            name=guardian_in.name,
            phone=_normalize_phone(guardian_in.phone),
            email=guardian_in.email.lower().strip() if guardian_in.email else None,
            relationship_type=guardian_in.relationship_type,
        )
        db.add(guardian)
        db.flush()
        guardian_user = ensure_linked_user(
            db,
            name=guardian_in.name,
            email=guardian_in.email,
            password=guardian_in.password,
            role="guardian",
            clinic_id=clinic_id,
            guardian_id=guardian.id,
        )
        guardian_users.append(guardian_user)
        linked_guardian_ids.append(guardian.id)

    if patient_in.new_guardian:
        guardian = Guardian(
            clinic_id=clinic_id,
            name=patient_in.new_guardian.name,
            phone=_normalize_phone(patient_in.new_guardian.phone),
            email=patient_in.new_guardian.email.lower().strip() if patient_in.new_guardian.email else None,
            relationship_type=patient_in.new_guardian.relationship_type,
        )
        db.add(guardian)
        db.flush()
        guardian_user = ensure_linked_user(
            db,
            name=patient_in.new_guardian.name,
            email=patient_in.new_guardian.email,
            password=patient_in.new_guardian.password,
            role="guardian",
            clinic_id=clinic_id,
            guardian_id=guardian.id,
        )
        guardian_users.append(guardian_user)
        linked_guardian_ids.append(guardian.id)

    _sync_patient_guardian_links(db, clinic_id, patient.id, linked_guardian_ids)

    db.commit()
    patient = (
        db.query(Patient)
        .options(selectinload(Patient.guardians))
        .filter(Patient.id == patient.id)
        .first()
    )
    send_confirmation_email_async(
        patient_user.email if patient_user else None,
        patient_user.name if patient_user else patient.name,
        email_is_confirmed=patient_user.email_is_confirmed if patient_user else False,
    )
    for guardian_user in guardian_users:
        if guardian_user:
            send_confirmation_email_async(
                guardian_user.email,
                guardian_user.name,
                email_is_confirmed=guardian_user.email_is_confirmed,
            )
    log_action(db, clinic_id=clinic_id, user_id=created_by, action="create", entity="patient", entity_id=patient.id)
    return patient



def update_patient(db: Session, clinic_id, patient_id, patient_in: PatientUpdate, updated_by) -> Patient:
    patient = (
        db.query(Patient)
        .filter(Patient.id == patient_id, Patient.clinic_id == clinic_id, Patient.deleted_at.is_(None))
        .first()
    )
    if not patient:
        raise ValueError("Patient not found")

    payload = patient_in.model_dump(exclude_unset=True)
    guardian_ids = payload.pop("guardian_ids", None)
    new_guardian = payload.pop("new_guardian", None)
    if "cpf" in payload:
        payload["cpf"] = _normalize_cpf(payload.get("cpf"))
    if "phone" in payload:
        payload["phone"] = _normalize_phone(payload.get("phone"))
    if "email" in payload and payload.get("email"):
        payload["email"] = payload["email"].lower().strip()
    for field, value in payload.items():
        if field == "password":
            continue
        setattr(patient, field, value)

    linked_user = ensure_linked_user(
        db,
        name=payload.get("name", patient.name),
        email=payload.get("email", patient.email),
        password=payload.get("password"),
        role="patient",
        clinic_id=clinic_id,
        patient_id=patient.id,
    )

    patient.updated_by = updated_by
    patient.updated_at = datetime.utcnow()

    if guardian_ids is not None:
        _sync_patient_guardian_links(db, clinic_id, patient.id, guardian_ids)
    if new_guardian:
        guardian = Guardian(
            clinic_id=clinic_id,
            name=new_guardian["name"],
            phone=_normalize_phone(new_guardian.get("phone")),
            email=new_guardian.get("email").lower().strip() if new_guardian.get("email") else None,
            relationship_type=new_guardian.get("relationship_type"),
        )
        db.add(guardian)
        db.flush()
        ensure_linked_user(
            db,
            name=new_guardian["name"],
            email=new_guardian.get("email"),
            password=new_guardian.get("password"),
            role="guardian",
            clinic_id=clinic_id,
            guardian_id=guardian.id,
        )
        existing_ids = list(guardian_ids or [item.id for item in patient.guardians])
        existing_ids.append(guardian.id)
        _sync_patient_guardian_links(db, clinic_id, patient.id, existing_ids)

    db.commit()
    patient = (
        db.query(Patient)
        .options(selectinload(Patient.guardians))
        .filter(Patient.id == patient.id)
        .first()
    )
    if payload.get("email"):
        send_confirmation_email_async(
            linked_user.email if linked_user else payload.get("email"),
            linked_user.name if linked_user else payload.get("name", patient.name),
            email_is_confirmed=linked_user.email_is_confirmed if linked_user else False,
        )
    log_action(db, clinic_id=clinic_id, user_id=updated_by, action="update", entity="patient", entity_id=patient.id)
    return patient



def soft_delete_patient(db: Session, clinic_id, patient_id, deleted_by) -> None:
    patient = (
        db.query(Patient)
        .filter(Patient.id == patient_id, Patient.clinic_id == clinic_id, Patient.deleted_at.is_(None))
        .first()
    )
    if not patient:
        raise ValueError("Patient not found")
    patient.deleted_at = datetime.utcnow()
    patient.updated_by = deleted_by
    patient.updated_at = datetime.utcnow()
    db.query(GuardianPatient).filter(GuardianPatient.patient_id == patient.id).delete(synchronize_session=False)
    db.commit()
    log_action(db, clinic_id=clinic_id, user_id=deleted_by, action="delete", entity="patient", entity_id=patient.id)
