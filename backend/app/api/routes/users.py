from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models import User
from app.schemas.schemas import TherapistCreate, TherapistOut, TherapistUpdate, UserOut
from app.services.user_service import create_therapist, soft_delete_therapist, update_therapist

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserOut)
def get_me(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    current_user = (
        db.query(User)
        .filter(User.id == user.id, User.clinic_id == user.clinic_id, User.deleted_at.is_(None))
        .first()
    )
    if current_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return current_user


@router.get("", response_model=list[UserOut], dependencies=[Depends(require_role("admin", "therapist", "receptionist"))])
def list_all(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
    role: str | None = Query(default=None),
):
    query = db.query(User).filter(User.clinic_id == user.clinic_id, User.deleted_at.is_(None))
    if role:
        query = query.filter(User.role == role)
    return query.order_by(User.name.asc()).all()


@router.post("/therapists", response_model=TherapistOut, dependencies=[Depends(require_role("admin"))])
def create_therapist_route(
    payload: TherapistCreate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    try:
        return create_therapist(
            db,
            clinic_id=user.clinic_id,
            name=payload.name,
            email=payload.email,
            cpf=payload.cpf,
            phone=payload.phone,
            specialty=payload.specialty,
            registration_type=payload.registration_type,
            professional_registration=payload.professional_registration,
            password=payload.password,
        )
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))


@router.put("/therapists/{therapist_id}", response_model=TherapistOut, dependencies=[Depends(require_role("admin"))])
def update_therapist_route(
    therapist_id: str,
    payload: TherapistUpdate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    try:
        return update_therapist(db, clinic_id=user.clinic_id, therapist_id=therapist_id, payload=payload)
    except ValueError as exc:
        status_code = 404 if str(exc) == "Therapist not found" else 400
        raise HTTPException(status_code=status_code, detail=str(exc))


@router.delete(
    "/therapists/{therapist_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    dependencies=[Depends(require_role("admin"))],
)
def delete_therapist_route(
    therapist_id: str,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    try:
        soft_delete_therapist(db, clinic_id=user.clinic_id, therapist_id=therapist_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))
