from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models import Patient
from app.schemas.schemas import PatientCreate, PatientOut, PatientSearchOut, PatientUpdate, PatientsPage
from app.services.rbac_service import apply_role_filter, resolve_guardian_patient_ids, resolve_patient_id
from app.services.patient_service import create_patient, get_patient_by_id, list_patients, soft_delete_patient, update_patient

router = APIRouter(prefix="/patients", tags=["patients"])


@router.post("", response_model=PatientOut, dependencies=[Depends(require_role("admin", "therapist", "receptionist"))])
def create(data: PatientCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    return create_patient(db, clinic_id=user.clinic_id, created_by=user.id, patient_in=data)


@router.get("", response_model=PatientsPage)
def list_all(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    search: str | None = None,
    show_deleted: bool = False,
):
    items, total = list_patients(db, user, page, limit, search=search, show_deleted=show_deleted)
    return PatientsPage(items=items, total=total, page=page, limit=limit)


@router.get("/search", response_model=list[PatientSearchOut])
def search_patients(
    q: str = Query(..., min_length=1),
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    term = q.strip()
    if not term:
        return []
    digits = "".join(char for char in term if char.isdigit())
    filters = [Patient.name.ilike(f"%{term}%"), Patient.patient_code.ilike(f"%{term}%")]
    if digits:
        filters.append(Patient.cpf == digits)
    query = (
        db.query(Patient)
        .filter(Patient.clinic_id == user.clinic_id, Patient.deleted_at.is_(None))
        .filter(or_(*filters))
        .order_by(Patient.name.asc())
        .limit(20)
    )
    if user.role == "patient":
        patient_id = resolve_patient_id(db, user)
        if not patient_id:
            return []
        query = query.filter(Patient.id == patient_id)
    elif user.role == "guardian":
        patient_ids = resolve_guardian_patient_ids(db, user)
        if not patient_ids:
            return []
        query = query.filter(Patient.id.in_(patient_ids))
    query = apply_role_filter(query, user, Patient)
    return query.all()


@router.get("/{patient_id}", response_model=PatientOut)
def get_one(patient_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        return get_patient_by_id(db, user, patient_id)
    except ValueError as exc:
        raise HTTPException(status_code=403 if user.role in {"patient", "guardian"} else 404, detail=str(exc))


@router.put("/{patient_id}", response_model=PatientOut, dependencies=[Depends(require_role("admin", "therapist"))])
def update(patient_id: str, data: PatientUpdate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        return update_patient(db, clinic_id=user.clinic_id, patient_id=patient_id, patient_in=data, updated_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.patch("/{patient_id}", response_model=PatientOut, dependencies=[Depends(require_role("admin", "therapist"))])
def patch_update(patient_id: str, data: PatientUpdate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        return update_patient(db, clinic_id=user.clinic_id, patient_id=patient_id, patient_in=data, updated_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.delete("/{patient_id}", status_code=status.HTTP_204_NO_CONTENT, dependencies=[Depends(require_role("admin", "therapist"))])
def delete(patient_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        soft_delete_patient(db, clinic_id=user.clinic_id, patient_id=patient_id, deleted_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))
