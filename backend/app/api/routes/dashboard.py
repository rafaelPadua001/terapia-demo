from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models import Evaluation, Evolution, Patient
from app.schemas.schemas import DashboardOut

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("", response_model=DashboardOut, dependencies=[Depends(require_role("admin", "therapist"))])
def get_dashboard(db: Session = Depends(get_db), user=Depends(get_current_user)):
    total_patients = (
        db.query(func.count(Patient.id))
        .filter(Patient.clinic_id == user.clinic_id, Patient.deleted_at.is_(None))
        .scalar()
    )
    evaluations_pending = (
        db.query(func.count(Evaluation.id))
        .filter(
            Evaluation.clinic_id == user.clinic_id,
            Evaluation.deleted_at.is_(None),
            Evaluation.status == "pending",
        )
        .scalar()
    )
    evaluations_approved = (
        db.query(func.count(Evaluation.id))
        .filter(
            Evaluation.clinic_id == user.clinic_id,
            Evaluation.deleted_at.is_(None),
            Evaluation.status == "approved",
        )
        .scalar()
    )
    evolutions = (
        db.query(Evolution)
        .filter(Evolution.clinic_id == user.clinic_id, Evolution.deleted_at.is_(None))
        .order_by(Evolution.created_at.desc())
        .limit(5)
        .all()
    )

    last_evolutions = [
        {
            "id": str(ev.id),
            "patient_id": str(ev.patient_id),
            "description": ev.description,
            "created_at": ev.created_at.isoformat(),
        }
        for ev in evolutions
    ]

    return DashboardOut(
        total_patients=total_patients or 0,
        evaluations_pending=evaluations_pending or 0,
        evaluations_approved=evaluations_approved or 0,
        last_evolutions=last_evolutions,
    )
