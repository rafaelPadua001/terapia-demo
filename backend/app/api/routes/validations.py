from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.schemas.schemas import ValidationOut, ValidationUpdate
from app.services.validation_service import list_validations, update_validation

router = APIRouter(prefix="/validations", tags=["validations"])


@router.get(
    "",
    response_model=list[ValidationOut],
    dependencies=[Depends(require_role("admin", "therapist", "receptionist", "patient", "guardian"))],
)
def list_all(db: Session = Depends(get_db), user=Depends(get_current_user), show_deleted: bool = False):
    return list_validations(db, user, show_deleted=show_deleted)


@router.patch(
    "/{validation_id}",
    response_model=ValidationOut,
    dependencies=[Depends(require_role("admin", "therapist"))],
)
def update(
    validation_id: str,
    payload: ValidationUpdate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    if payload.status not in {"pending", "approved", "rejected"}:
        raise HTTPException(status_code=400, detail="Invalid status")
    try:
        return update_validation(
            db,
            clinic_id=user.clinic_id,
            validation_id=validation_id,
            user_id=user.id,
            validation_in=payload,
        )
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))
