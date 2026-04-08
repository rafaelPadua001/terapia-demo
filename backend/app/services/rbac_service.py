from fastapi import HTTPException, status
from sqlalchemy import false

from app.models import Evaluation, Guardian, GuardianPatient, Patient, Validation
from app.core.dependencies import normalize_role


def can_remove(role: str | None) -> bool:
    normalized_role = normalize_role(role)
    return normalized_role not in {"receptionist", "patient"}


def ensure_role_allowed(user, allowed_roles: list[str], action: str) -> None:
    normalized_role = normalize_role(user.role)
    normalized_allowed_roles = {normalize_role(role) for role in allowed_roles}
    if normalized_role in normalized_allowed_roles:
        return
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail={
            "error": "Forbidden",
            "message": "Voce nao tem permissao para executar esta acao",
            "action": action,
        },
    )


def resolve_patient_id(session, user):
    if user.patient_id:
        patient = (
            session.query(Patient)
            .filter(Patient.id == user.patient_id, Patient.clinic_id == user.clinic_id, Patient.deleted_at.is_(None))
            .first()
        )
        if patient:
            return patient.id
        user.patient_id = None
        session.commit()
    if not user.email:
        return None

    patient = (
        session.query(Patient)
        .filter(Patient.clinic_id == user.clinic_id, Patient.email == user.email, Patient.deleted_at.is_(None))
        .first()
    )
    if not patient:
        return None

    user.patient_id = patient.id
    session.commit()
    return patient.id


def resolve_guardian_id(session, user):
    if user.guardian_id:
        guardian = (
            session.query(Guardian)
            .filter(Guardian.id == user.guardian_id, Guardian.clinic_id == user.clinic_id, Guardian.deleted_at.is_(None))
            .first()
        )
        if guardian:
            return guardian.id
        user.guardian_id = None
        session.commit()
    if not user.email:
        return None

    guardian = (
        session.query(Guardian)
        .filter(Guardian.clinic_id == user.clinic_id, Guardian.email == user.email, Guardian.deleted_at.is_(None))
        .first()
    )
    if not guardian:
        return None

    user.guardian_id = guardian.id
    session.commit()
    return guardian.id


def resolve_guardian_patient_ids(session, user):
    guardian_id = resolve_guardian_id(session, user)
    if not guardian_id:
        return []

    patient_ids = {
        patient_id
        for (patient_id,) in session.query(GuardianPatient.patient_id)
        .filter(GuardianPatient.guardian_id == guardian_id)
        .all()
    }

    active_ids = {
        patient_id
        for (patient_id,) in session.query(Patient.id)
        .filter(Patient.id.in_(patient_ids), Patient.clinic_id == user.clinic_id, Patient.deleted_at.is_(None))
        .all()
    }
    return list(active_ids)


def apply_role_filter(query, user, model):
    role = normalize_role(user.role)
    if role in {"admin", "therapist"}:
        return query
    if role == "receptionist":
        return query

    if role == "patient":
        patient_id = resolve_patient_id(query.session, user)
        if not patient_id:
            return query.filter(false())
        if model is Patient:
            return query.filter(Patient.id == patient_id)
        if hasattr(model, "patient_id"):
            return query.filter(model.patient_id == patient_id)
        if model is Validation:
            return query.join(Evaluation, Evaluation.id == Validation.evaluation_id).filter(
                Evaluation.patient_id == patient_id
            )
        return query.filter(false())

    if role == "guardian":
        patient_ids = resolve_guardian_patient_ids(query.session, user)
        if not patient_ids:
            return query.filter(false())
        if model is Patient:
            return query.filter(Patient.id.in_(patient_ids))
        if hasattr(model, "patient_id"):
            return query.filter(model.patient_id.in_(patient_ids))
        if model is Validation:
            return (
                query.join(Evaluation, Evaluation.id == Validation.evaluation_id)
                .filter(Evaluation.patient_id.in_(patient_ids))
            )
        return query.filter(false())

    return query.filter(false())
