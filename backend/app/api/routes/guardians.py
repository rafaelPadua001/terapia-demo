from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session, selectinload

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models import Guardian, GuardianPatient
from app.services.rbac_service import resolve_guardian_patient_ids
from app.schemas.schemas import GuardianCreate, GuardianOut, GuardianUpdate
from app.services.guardian_service import create_guardian, soft_delete_guardian, update_guardian

router = APIRouter(prefix="/guardians", tags=["guardians"])


@router.post("", response_model=GuardianOut, dependencies=[Depends(require_role("admin", "therapist", "receptionist"))])
def create(data: GuardianCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    return create_guardian(db, clinic_id=user.clinic_id, user_id=user.id, guardian_in=data)


@router.get("", response_model=list[GuardianOut])
def list_all(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
    patient_id: str | None = None,
    patient_ids: list[str] | None = Query(default=None),
    show_deleted: bool = False,
):
    query = db.query(Guardian).options(selectinload(Guardian.patients)).filter(Guardian.clinic_id == user.clinic_id)
    if not show_deleted:
        query = query.filter(Guardian.deleted_at.is_(None))

    filtered_patient_ids: list[str] = []
    if patient_id:
        filtered_patient_ids.append(patient_id)
    if patient_ids:
        filtered_patient_ids.extend(patient_ids)

    if user.role == "patient":
        if not user.patient_id:
            return []
        filtered_patient_ids = [str(user.patient_id)]
    elif user.role == "guardian":
        allowed_patient_ids = resolve_guardian_patient_ids(db, user)
        if not allowed_patient_ids:
            return []
        if filtered_patient_ids:
            allowed_ids = {str(item) for item in allowed_patient_ids}
            filtered_patient_ids = [item for item in filtered_patient_ids if item in allowed_ids]
            if not filtered_patient_ids:
                return []
        else:
            filtered_patient_ids = [str(item) for item in allowed_patient_ids]

    filtered_patient_ids = list(dict.fromkeys(filtered_patient_ids))
    if filtered_patient_ids:
        query = query.join(GuardianPatient, GuardianPatient.guardian_id == Guardian.id).filter(
            GuardianPatient.patient_id.in_(filtered_patient_ids)
        )

    return query.distinct().order_by(Guardian.name.asc()).all()


@router.put("/{guardian_id}", response_model=GuardianOut, dependencies=[Depends(require_role("admin", "therapist", "receptionist"))])
def update(guardian_id: str, data: GuardianUpdate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        return update_guardian(db, clinic_id=user.clinic_id, guardian_id=guardian_id, guardian_in=data, updated_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.delete("/{guardian_id}", status_code=status.HTTP_204_NO_CONTENT, dependencies=[Depends(require_role("admin", "therapist", "receptionist"))])
def delete(guardian_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        soft_delete_guardian(db, clinic_id=user.clinic_id, guardian_id=guardian_id, deleted_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))
