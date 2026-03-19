from sqlalchemy.orm import Session

from app.core.security import get_password_hash, verify_password
from app.models import User

DEFAULT_PORTAL_PASSWORD = "Brasil2026"


def authenticate(db: Session, email: str, password: str) -> User | None:
    user = db.query(User).filter(User.email == email, User.deleted_at.is_(None)).first()
    if not user:
        return None
    if not verify_password(password, user.password_hash):
        return None
    return user


def create_user(
    db: Session,
    *,
    name: str,
    email: str,
    password: str,
    role: str,
    clinic_id,
    patient_id=None,
    guardian_id=None,
    email_is_confirmed: bool = False,
):
    existing = db.query(User).filter(User.email == email).first()
    if existing:
        return existing
    user = User(
        name=name,
        email=email,
        password_hash=get_password_hash(password),
        role=role,
        clinic_id=clinic_id,
        email_is_confirmed=email_is_confirmed,
        patient_id=patient_id,
        guardian_id=guardian_id,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def ensure_linked_user(
    db: Session,
    *,
    name: str,
    email: str | None,
    role: str,
    clinic_id,
    password: str | None = None,
    patient_id=None,
    guardian_id=None,
) -> User | None:
    if not email:
        return None

    normalized_email = email.strip().lower()
    if not normalized_email:
        return None

    linked_user = None
    if patient_id is not None:
        linked_user = db.query(User).filter(User.patient_id == patient_id).first()
    elif guardian_id is not None:
        linked_user = db.query(User).filter(User.guardian_id == guardian_id).first()

    email_user = db.query(User).filter(User.email == normalized_email).first()

    if linked_user and email_user and linked_user.id != email_user.id:
        print(f"Skipping linked user sync for {normalized_email}: email already belongs to another user")
        return linked_user

    user = linked_user or email_user

    if user is None:
        user = User(
            name=name,
            email=normalized_email,
            password_hash=get_password_hash(password or DEFAULT_PORTAL_PASSWORD),
            role=role,
            clinic_id=clinic_id,
            email_is_confirmed=False,
            patient_id=patient_id,
            guardian_id=guardian_id,
        )
        db.add(user)
        db.flush()
        return user

    if email_user and linked_user is None:
        if role == "patient" and user.patient_id not in (None, patient_id):
            print(f"Skipping patient user sync for {normalized_email}: already linked to another patient")
            return user
        if role == "guardian" and user.guardian_id not in (None, guardian_id):
            print(f"Skipping guardian user sync for {normalized_email}: already linked to another guardian")
            return user
        if user.role not in {role, "patient", "guardian"}:
            print(f"Skipping role update for {normalized_email}: existing role is {user.role}")
            return user

    user.name = name
    user.email = normalized_email
    user.role = role
    user.clinic_id = clinic_id
    user.deleted_at = None
    if patient_id is not None:
        user.patient_id = patient_id
    if guardian_id is not None:
        user.guardian_id = guardian_id
    if password:
        user.password_hash = get_password_hash(password)
    elif not user.password_hash:
        user.password_hash = get_password_hash(DEFAULT_PORTAL_PASSWORD)

    db.flush()
    return user
