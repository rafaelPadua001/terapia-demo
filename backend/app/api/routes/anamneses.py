from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models import Anamnese
from app.schemas.schemas import AnamneseCreate, AnamneseOut, AnamneseUpdate, AnamnesesPage
from app.services.anamnese_service import create_anamnese, list_anamneses, soft_delete_anamnese, update_anamnese

router = APIRouter(prefix="/anamneses", tags=["anamneses"])


@router.post("", response_model=AnamneseOut, dependencies=[Depends(require_role("admin", "therapist"))])
def create(data: AnamneseCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    return create_anamnese(db, clinic_id=user.clinic_id, user_id=user.id, anamnese_in=data)


@router.get(
    "",
    response_model=AnamnesesPage,
    dependencies=[Depends(require_role("admin", "therapist", "receptionist", "patient", "guardian"))],
)
def list_all(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    patient_id: str | None = None,
    show_deleted: bool = False,
):
    items, total = list_anamneses(db, user, page, limit, patient_id=patient_id, show_deleted=show_deleted)
    return AnamnesesPage(items=items, total=total, page=page, limit=limit)


@router.put("/{anamnese_id}", response_model=AnamneseOut, dependencies=[Depends(require_role("admin", "therapist"))])
def update(anamnese_id: str, data: AnamneseUpdate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        return update_anamnese(db, clinic_id=user.clinic_id, anamnese_id=anamnese_id, anamnese_in=data, updated_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.delete("/{anamnese_id}", status_code=status.HTTP_204_NO_CONTENT, dependencies=[Depends(require_role("admin", "therapist"))])
def delete(anamnese_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        soft_delete_anamnese(db, clinic_id=user.clinic_id, anamnese_id=anamnese_id, deleted_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))
