from sqlalchemy.orm import Session

from app.modules.notifications.models import Notification


def create_notification(db: Session, *, user_id, title: str, message: str) -> Notification:
    notification = Notification(user_id=user_id, title=title, message=message)
    db.add(notification)
    db.flush()
    return notification


def list_notifications(db: Session, *, user_id, limit: int = 50):
    return (
        db.query(Notification)
        .filter(Notification.user_id == user_id)
        .order_by(Notification.created_at.desc())
        .limit(limit)
        .all()
    )


def mark_notification_as_read(db: Session, *, notification_id, user_id):
    notification = (
        db.query(Notification)
        .filter(Notification.id == notification_id, Notification.user_id == user_id)
        .first()
    )
    if not notification:
        return None
    notification.is_read = True
    db.add(notification)
    db.flush()
    return notification
