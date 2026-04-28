from datetime import datetime

from sqlalchemy.orm import Session, selectinload

from app.models import Anamnese
from app.schemas.schemas import AnamneseCreate, AnamneseUpdate
from app.services.audit_service import log_action
from app.services.rbac_service import apply_role_filter
from app.services.rich_text_service import normalize_anamnese_data


def create_anamnese(db: Session, clinic_id, user_id, anamnese_in: AnamneseCreate) -> Anamnese:
    anamnese = Anamnese(
        clinic_id=clinic_id,
        patient_id=anamnese_in.patient_id,
        data=normalize_anamnese_data(anamnese_in.data),
        created_by=user_id,
    )
    db.add(anamnese)
    db.commit()
    db.refresh(anamnese)
    log_action(db, clinic_id=clinic_id, user_id=user_id, action="create", entity="anamnese", entity_id=anamnese.id)
    return anamnese


def update_anamnese(db: Session, clinic_id, anamnese_id, anamnese_in: AnamneseUpdate, updated_by) -> Anamnese:
    anamnese = (
        db.query(Anamnese)
        .filter(Anamnese.id == anamnese_id, Anamnese.clinic_id == clinic_id, Anamnese.deleted_at.is_(None))
        .first()
    )
    if not anamnese:
        raise ValueError("Anamnese not found")
    anamnese.data = normalize_anamnese_data(anamnese_in.data)
    anamnese.updated_by = updated_by
    anamnese.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(anamnese)
    log_action(db, clinic_id=clinic_id, user_id=updated_by, action="update", entity="anamnese", entity_id=anamnese.id)
    return anamnese


def soft_delete_anamnese(db: Session, clinic_id, anamnese_id, deleted_by) -> None:
    anamnese = (
        db.query(Anamnese)
        .filter(Anamnese.id == anamnese_id, Anamnese.clinic_id == clinic_id, Anamnese.deleted_at.is_(None))
        .first()
    )
    if not anamnese:
        raise ValueError("Anamnese not found")
    anamnese.deleted_at = datetime.utcnow()
    anamnese.updated_by = deleted_by
    anamnese.updated_at = datetime.utcnow()
    db.commit()
    log_action(db, clinic_id=clinic_id, user_id=deleted_by, action="delete", entity="anamnese", entity_id=anamnese.id)


def list_anamneses(db: Session, user, page: int, limit: int, patient_id: str | None = None, show_deleted: bool = False):
    query = (
        db.query(Anamnese)
        .options(selectinload(Anamnese.patient))
        .filter(Anamnese.clinic_id == user.clinic_id)
    )
    if not show_deleted:
        query = query.filter(Anamnese.deleted_at.is_(None))
    if patient_id:
        query = query.filter(Anamnese.patient_id == patient_id)
    query = apply_role_filter(query, user, Anamnese)
    total = query.count()
    items = query.order_by(Anamnese.created_at.desc()).offset((page - 1) * limit).limit(limit).all()
    return items, total
