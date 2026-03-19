from sqlalchemy.orm import Session, joinedload

from app.models import Evaluation, Validation
from app.schemas.schemas import ValidationCreate, ValidationUpdate
from app.services.rbac_service import apply_role_filter


def validate_evaluation(db: Session, clinic_id, user_id, validation_in: ValidationCreate) -> Validation:
    evaluation = (
        db.query(Evaluation)
        .filter(Evaluation.id == validation_in.evaluation_id, Evaluation.clinic_id == clinic_id)
        .first()
    )
    if not evaluation:
        raise ValueError("Evaluation not found")

    evaluation.status = validation_in.status
    validation = Validation(
        clinic_id=clinic_id,
        evaluation_id=evaluation.id,
        validated_by=user_id,
        status=validation_in.status,
        notes=validation_in.notes,
    )
    db.add(validation)
    db.commit()
    db.refresh(validation)
    return validation


def list_validations(db: Session, user, show_deleted: bool = False):
    query = (
        db.query(Validation)
        .options(joinedload(Validation.evaluation).joinedload(Evaluation.patient))
        .filter(Validation.clinic_id == user.clinic_id)
    )
    if not show_deleted:
        query = query.filter(Validation.deleted_at.is_(None))
    query = apply_role_filter(query, user, Validation)
    return query.order_by(Validation.created_at.desc()).all()


def update_validation(db: Session, clinic_id, validation_id, user_id, validation_in: ValidationUpdate) -> Validation:
    validation = (
        db.query(Validation)
        .join(Evaluation, Validation.evaluation_id == Evaluation.id)
        .filter(
            Validation.id == validation_id,
            Validation.clinic_id == clinic_id,
            Validation.deleted_at.is_(None),
            Evaluation.clinic_id == clinic_id,
        )
        .first()
    )
    if not validation:
        raise ValueError("Validation not found")

    validation.status = validation_in.status
    validation.notes = validation_in.notes
    validation.validated_by = user_id
    if validation.evaluation:
        validation.evaluation.status = validation_in.status

    db.commit()
    db.refresh(validation)
    return validation
