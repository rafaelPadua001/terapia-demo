from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session, joinedload

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models import Evaluation, Evolution, Patient, User
from app.schemas.schemas import DashboardOut
from app.services.evolution_service import serialize_evolution

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
        db.query(Evolution, User)
        .options(joinedload(Evolution.patient))
        .outerjoin(
            User,
            (User.patient_id == Evolution.patient_id)
            & (User.clinic_id == Evolution.clinic_id)
            & (User.deleted_at.is_(None)),
        )
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
            "patient_name": serialized["patient"]["name"] if serialized["patient"] else None,
            "patient_email": serialized["patient"]["email"] if serialized["patient"] else None,
            "patient_email_confirmed": serialized["patient"]["email_confirmed"] if serialized["patient"] else None,
            "patient_phone": serialized["patient"]["phone"] if serialized["patient"] else None,
            "patient": serialized["patient"],
        }
        for ev, patient_user in evolutions
        for serialized in [serialize_evolution(ev, patient_user)]
    ]

    return DashboardOut(
        total_patients=total_patients or 0,
        evaluations_pending=evaluations_pending or 0,
        evaluations_approved=evaluations_approved or 0,
        last_evolutions=last_evolutions,
    )
