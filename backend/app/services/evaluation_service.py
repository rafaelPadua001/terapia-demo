from datetime import datetime

from fpdf import FPDF
from sqlalchemy.orm import Session, joinedload

from app.models import Evaluation, Patient, Validation
from app.schemas.schemas import EvaluationCreate, EvaluationUpdate
from app.services.audit_service import log_action
from app.services.rbac_service import apply_role_filter


def _normalize_result(value):
    if isinstance(value, dict):
        return value
    if value is None:
        return {"value": ""}
    return {"value": str(value)}


def _result_to_text(value) -> str:
    if isinstance(value, dict):
        if "value" in value:
            return str(value.get("value") or "")
        if "raw" in value:
            return str(value.get("raw") or "")
        return str(value)
    return str(value)


def _get_accessible_evaluation(db: Session, user, evaluation_id: str) -> Evaluation | None:
    query = (
        db.query(Evaluation)
        .options(joinedload(Evaluation.patient))
        .filter(Evaluation.id == evaluation_id, Evaluation.clinic_id == user.clinic_id, Evaluation.deleted_at.is_(None))
    )
    query = apply_role_filter(query, user, Evaluation)
    return query.first()


def create_evaluation(db: Session, clinic_id, user_id, evaluation_in: EvaluationCreate) -> Evaluation:
    evaluation = Evaluation(
        clinic_id=clinic_id,
        patient_id=evaluation_in.patient_id,
        type=evaluation_in.type,
        result=_normalize_result(evaluation_in.result),
        status="pending",
        created_by=user_id,
    )
    db.add(evaluation)
    db.commit()
    db.refresh(evaluation)
    log_action(db, clinic_id=clinic_id, user_id=user_id, action="create", entity="evaluation", entity_id=evaluation.id)
    return evaluation


def update_evaluation(db: Session, clinic_id, evaluation_id, evaluation_in: EvaluationUpdate, updated_by) -> Evaluation:
    evaluation = (
        db.query(Evaluation)
        .filter(Evaluation.id == evaluation_id, Evaluation.clinic_id == clinic_id, Evaluation.deleted_at.is_(None))
        .first()
    )
    if not evaluation:
        raise ValueError("Evaluation not found")

    for field, value in evaluation_in.model_dump(exclude_unset=True).items():
        if field == "result":
            value = _normalize_result(value)
        setattr(evaluation, field, value)

    evaluation.updated_by = updated_by
    evaluation.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(evaluation)
    log_action(db, clinic_id=clinic_id, user_id=updated_by, action="update", entity="evaluation", entity_id=evaluation.id)
    return evaluation


def soft_delete_evaluation(db: Session, clinic_id, evaluation_id, deleted_by) -> None:
    evaluation = (
        db.query(Evaluation)
        .filter(Evaluation.id == evaluation_id, Evaluation.clinic_id == clinic_id, Evaluation.deleted_at.is_(None))
        .first()
    )
    if not evaluation:
        raise ValueError("Evaluation not found")
    evaluation.deleted_at = datetime.utcnow()
    evaluation.updated_by = deleted_by
    evaluation.updated_at = datetime.utcnow()
    db.commit()
    log_action(db, clinic_id=clinic_id, user_id=deleted_by, action="delete", entity="evaluation", entity_id=evaluation.id)


def validate_evaluation(db: Session, clinic_id, user_id, evaluation_id, status: str, notes: str | None) -> Validation:
    evaluation = (
        db.query(Evaluation)
        .filter(Evaluation.id == evaluation_id, Evaluation.clinic_id == clinic_id, Evaluation.deleted_at.is_(None))
        .first()
    )
    if not evaluation:
        raise ValueError("Evaluation not found")

    evaluation.status = status
    evaluation.updated_by = user_id
    evaluation.updated_at = datetime.utcnow()
    validation = Validation(
        clinic_id=clinic_id,
        evaluation_id=evaluation.id,
        validated_by=user_id,
        status=status,
        notes=notes,
    )
    db.add(validation)
    db.commit()
    db.refresh(validation)
    log_action(
        db,
        clinic_id=clinic_id,
        user_id=user_id,
        action="validate",
        entity="evaluation",
        entity_id=evaluation.id,
        metadata={"status": status},
    )
    return validation


def generate_evaluation_pdf(db: Session, clinic_id, evaluation_id) -> bytes:
    class _PdfUser:
        def __init__(self, clinic_id_value):
            self.clinic_id = clinic_id_value
            self.role = "admin"
            self.patient_id = None
            self.guardian_id = None
            self.email = None

    evaluation = _get_accessible_evaluation(db, _PdfUser(clinic_id), evaluation_id)
    if not evaluation:
        raise ValueError("Evaluation not found")

    patient = (
        db.query(Patient)
        .filter(Patient.id == evaluation.patient_id, Patient.clinic_id == clinic_id, Patient.deleted_at.is_(None))
        .first()
    )

    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", size=14)
    pdf.cell(0, 10, "Relatorio de Avaliacao", ln=True)
    pdf.set_font("Arial", size=12)
    pdf.cell(0, 10, f"Paciente: {patient.name if patient else 'N/A'}", ln=True)
    pdf.cell(0, 10, f"Diagnostico: {patient.diagnosis if patient else 'N/A'}", ln=True)
    pdf.cell(0, 10, f"Tipo: {evaluation.type}", ln=True)
    pdf.multi_cell(0, 8, f"Resultado: {_result_to_text(evaluation.result)}")
    pdf.cell(0, 10, f"Status: {evaluation.status}", ln=True)
    pdf.cell(0, 10, f"Data: {evaluation.created_at.strftime('%Y-%m-%d')}", ln=True)

    return bytes(pdf.output(dest="S"))


def generate_evaluation_pdf_for_user(db: Session, user, evaluation_id: str) -> bytes:
    evaluation = _get_accessible_evaluation(db, user, evaluation_id)
    if not evaluation:
        raise ValueError("Evaluation not found")

    patient = evaluation.patient
    if patient is None:
        patient = (
            db.query(Patient)
            .filter(Patient.id == evaluation.patient_id, Patient.clinic_id == user.clinic_id, Patient.deleted_at.is_(None))
            .first()
        )

    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", size=14)
    pdf.cell(0, 10, "Relatorio de Avaliacao", ln=True)
    pdf.set_font("Arial", size=12)
    pdf.cell(0, 10, f"Paciente: {patient.name if patient else 'N/A'}", ln=True)
    pdf.cell(0, 10, f"Diagnostico: {patient.diagnosis if patient else 'N/A'}", ln=True)
    pdf.cell(0, 10, f"Tipo: {evaluation.type}", ln=True)
    pdf.multi_cell(0, 8, f"Resultado: {_result_to_text(evaluation.result)}")
    pdf.cell(0, 10, f"Status: {evaluation.status}", ln=True)
    pdf.cell(0, 10, f"Data: {evaluation.created_at.strftime('%Y-%m-%d')}", ln=True)

    return bytes(pdf.output(dest="S"))


def list_evaluations(
    db: Session,
    user,
    page: int,
    limit: int,
    search: str | None = None,
    status: str | None = None,
    patient_id: str | None = None,
    show_deleted: bool = False,
):
    query = (
        db.query(Evaluation)
        .options(joinedload(Evaluation.patient))
        .filter(Evaluation.clinic_id == user.clinic_id)
    )
    if not show_deleted:
        query = query.filter(Evaluation.deleted_at.is_(None))
    if search:
        query = query.filter(Evaluation.type.ilike(f"%{search}%"))
    if status:
        query = query.filter(Evaluation.status == status)
    if patient_id:
        query = query.filter(Evaluation.patient_id == patient_id)
    query = apply_role_filter(query, user, Evaluation)
    total = query.count()
    items = query.order_by(Evaluation.created_at.desc()).offset((page - 1) * limit).limit(limit).all()
    return items, total
