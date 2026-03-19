from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models import User
from app.schemas.schemas import UserOut

router = APIRouter(prefix="/users", tags=["users"])


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
