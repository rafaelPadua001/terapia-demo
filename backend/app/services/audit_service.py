from sqlalchemy.orm import Session

from app.models import AuditLog


def log_action(db: Session, *, clinic_id, user_id, action: str, entity: str, entity_id: str, metadata: dict | None = None):
    audit = AuditLog(
        clinic_id=clinic_id,
        user_id=user_id,
        action=action,
        entity=entity,
        entity_id=str(entity_id),
        meta=metadata or {},
    )
    db.add(audit)
    db.commit()
    db.refresh(audit)
    return audit
