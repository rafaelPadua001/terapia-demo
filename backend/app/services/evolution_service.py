from datetime import datetime

from sqlalchemy.orm import Session, joinedload

from app.models import Evolution, User
from app.schemas.schemas import EvolutionCreate, EvolutionUpdate
from app.services.audit_service import log_action
from app.services.rbac_service import apply_role_filter


def create_evolution(db: Session, clinic_id, user_id, evolution_in: EvolutionCreate) -> Evolution:
    evolution = Evolution(
        clinic_id=clinic_id,
        patient_id=evolution_in.patient_id,
        description=evolution_in.description,
        created_by=user_id,
    )
    db.add(evolution)
    db.commit()
    db.refresh(evolution)
    log_action(db, clinic_id=clinic_id, user_id=user_id, action="create", entity="evolution", entity_id=evolution.id)
    return evolution


def update_evolution(db: Session, clinic_id, evolution_id, evolution_in: EvolutionUpdate, updated_by) -> Evolution:
    evolution = (
        db.query(Evolution)
        .filter(Evolution.id == evolution_id, Evolution.clinic_id == clinic_id, Evolution.deleted_at.is_(None))
        .first()
    )
    if not evolution:
        raise ValueError("Evolution not found")

    for field, value in evolution_in.model_dump(exclude_unset=True).items():
        setattr(evolution, field, value)

    evolution.updated_by = updated_by
    evolution.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(evolution)
    log_action(db, clinic_id=clinic_id, user_id=updated_by, action="update", entity="evolution", entity_id=evolution.id)
    return evolution


def soft_delete_evolution(db: Session, clinic_id, evolution_id, deleted_by) -> None:
    evolution = (
        db.query(Evolution)
        .filter(Evolution.id == evolution_id, Evolution.clinic_id == clinic_id, Evolution.deleted_at.is_(None))
        .first()
    )
    if not evolution:
        raise ValueError("Evolution not found")
    evolution.deleted_at = datetime.utcnow()
    evolution.updated_by = deleted_by
    evolution.updated_at = datetime.utcnow()
    db.commit()
    log_action(db, clinic_id=clinic_id, user_id=deleted_by, action="delete", entity="evolution", entity_id=evolution.id)


def serialize_evolution(evolution: Evolution, patient_user: User | None = None) -> dict:
    patient = evolution.patient
    patient_payload = None

    if patient:
        patient_payload = {
            "id": patient.id,
            "name": patient.name,
            "patient_code": patient.patient_code,
            "cpf": patient.cpf,
            "birth_date": patient.birth_date,
            "email": patient_user.email if patient_user else None,
            "email_confirmed": patient_user.email_is_confirmed if patient_user else None,
            "phone": patient_user.phone if patient_user else None,
        }

    return {
        "id": evolution.id,
        "clinic_id": evolution.clinic_id,
        "patient_id": evolution.patient_id,
        "patient": patient_payload,
        "created_by": evolution.created_by,
        "updated_by": evolution.updated_by,
        "description": evolution.description,
        "created_at": evolution.created_at,
        "updated_at": evolution.updated_at,
        "deleted_at": evolution.deleted_at,
    }


def list_evolutions(db: Session, user, page: int, limit: int, patient_id: str | None = None, show_deleted: bool = False):
    query = (
        db.query(Evolution, User)
        .options(joinedload(Evolution.patient))
        .outerjoin(
            User,
            (User.patient_id == Evolution.patient_id)
            & (User.clinic_id == Evolution.clinic_id)
            & (User.deleted_at.is_(None)),
        )
        .filter(Evolution.clinic_id == user.clinic_id)
    )
    if not show_deleted:
        query = query.filter(Evolution.deleted_at.is_(None))
    if patient_id:
        query = query.filter(Evolution.patient_id == patient_id)
    query = apply_role_filter(query, user, Evolution)
    total = query.count()
    rows = query.order_by(Evolution.created_at.desc()).offset((page - 1) * limit).limit(limit).all()
    items = [serialize_evolution(evolution, patient_user) for evolution, patient_user in rows]
    return items, total
