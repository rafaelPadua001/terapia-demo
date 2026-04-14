from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.modules.notifications.schemas import NotificationOut
from app.modules.notifications.service import list_notifications, mark_notification_as_read

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", response_model=list[NotificationOut])
def get_notifications(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
    limit: int = Query(50, ge=1, le=200),
):
    return list_notifications(db, user_id=user.id, limit=limit)


@router.patch("/{notification_id}/read")
def read_notification(
    notification_id: str,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    notification = mark_notification_as_read(db, notification_id=notification_id, user_id=user.id)
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    db.commit()
    return {"success": True}
