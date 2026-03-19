from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models import Evolution
from app.schemas.schemas import EvolutionCreate, EvolutionOut, EvolutionUpdate, EvolutionsPage
from app.services.evolution_service import create_evolution, list_evolutions, soft_delete_evolution, update_evolution

router = APIRouter(prefix="/evolutions", tags=["evolutions"])


@router.post("", response_model=EvolutionOut, dependencies=[Depends(require_role("admin", "therapist"))])
def create(data: EvolutionCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    return create_evolution(db, clinic_id=user.clinic_id, user_id=user.id, evolution_in=data)


@router.get(
    "",
    response_model=EvolutionsPage,
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
    items, total = list_evolutions(db, user, page, limit, patient_id=patient_id, show_deleted=show_deleted)
    return EvolutionsPage(items=items, total=total, page=page, limit=limit)


@router.put("/{evolution_id}", response_model=EvolutionOut, dependencies=[Depends(require_role("admin", "therapist"))])
def update(evolution_id: str, data: EvolutionUpdate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        return update_evolution(db, clinic_id=user.clinic_id, evolution_id=evolution_id, evolution_in=data, updated_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.delete("/{evolution_id}", status_code=status.HTTP_204_NO_CONTENT, dependencies=[Depends(require_role("admin", "therapist"))])
def delete(evolution_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        soft_delete_evolution(db, clinic_id=user.clinic_id, evolution_id=evolution_id, deleted_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))
