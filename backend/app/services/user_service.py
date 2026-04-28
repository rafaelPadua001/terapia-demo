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
    phone: str | None = None,
    specialty: str | None = None,
    patient_id=None,
    guardian_id=None,
    email_is_confirmed: bool = False,
    first_login: bool = True,
    has_seen_tutorial: bool = False,
):
    existing = db.query(User).filter(User.email == email).first()
    if existing:
        return existing
    user = User(
        name=name,
        email=email,
        phone=phone,
        specialty=specialty,
        password_hash=get_password_hash(password),
        role=role,
        clinic_id=clinic_id,
        email_is_confirmed=email_is_confirmed,
        first_login=first_login,
        has_seen_tutorial=has_seen_tutorial,
        patient_id=patient_id,
        guardian_id=guardian_id,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def create_therapist(
    db: Session,
    *,
    clinic_id,
    name: str,
    email: str,
    phone: str | None = None,
    specialty: str | None = None,
    password: str | None = None,
) -> User:
    normalized_password = password.strip() if password else ""
    effective_password = normalized_password or DEFAULT_PORTAL_PASSWORD
    return create_user(
        db,
        name=name,
        email=email.strip().lower(),
        phone=phone.strip() if phone else None,
        specialty=specialty.strip() if specialty else None,
        password=effective_password,
        role="therapist",
        clinic_id=clinic_id,
        email_is_confirmed=True,
    )


def update_therapist(
    db: Session,
    *,
    clinic_id,
    therapist_id,
    payload,
) -> User:
    therapist = (
        db.query(User)
        .filter(
            User.id == therapist_id,
            User.clinic_id == clinic_id,
            User.role == "therapist",
            User.deleted_at.is_(None),
        )
        .first()
    )
    if therapist is None:
        raise ValueError("Therapist not found")

    update_data = payload.model_dump(exclude_unset=True)
    if "name" in update_data and update_data["name"] is not None:
        therapist.name = update_data["name"].strip()
    if "email" in update_data and update_data["email"] is not None:
        therapist.email = update_data["email"].strip().lower()
    if "phone" in update_data:
        therapist.phone = update_data["phone"].strip() if update_data["phone"] else None
    if "specialty" in update_data:
        therapist.specialty = update_data["specialty"].strip() if update_data["specialty"] else None

    password = update_data.get("password")
    if password is not None:
        normalized_password = password.strip()
        therapist.password_hash = get_password_hash(normalized_password or DEFAULT_PORTAL_PASSWORD)

    db.commit()
    db.refresh(therapist)
    return therapist


def soft_delete_therapist(db: Session, *, clinic_id, therapist_id) -> None:
    therapist = (
        db.query(User)
        .filter(
            User.id == therapist_id,
            User.clinic_id == clinic_id,
            User.role == "therapist",
            User.deleted_at.is_(None),
        )
        .first()
    )
    if therapist is None:
        raise ValueError("Therapist not found")

    from datetime import datetime

    therapist.deleted_at = datetime.utcnow()
    db.commit()


def change_password(db: Session, *, user: User, new_password: str) -> User:
    user.password_hash = get_password_hash(new_password)
    user.first_login = False
    user.reset_token_hash = None
    user.reset_token_expiration = None
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
