from sqlalchemy.orm import Session

from app.core.security import get_password_hash
from app.models import Clinic, User
from app.schemas.schemas import ClinicCreate, UserCreate


def create_clinic_with_admin(db: Session, clinic_in: ClinicCreate, admin_in: UserCreate) -> Clinic:
    clinic = Clinic(name=clinic_in.name)
    db.add(clinic)
    db.flush()

    user = User(
        clinic_id=clinic.id,
        name=admin_in.name,
        email=admin_in.email,
        password_hash=get_password_hash(admin_in.password),
        role=admin_in.role,
        email_is_confirmed=True,
    )
    db.add(user)
    db.commit()
    db.refresh(clinic)
    return clinic
