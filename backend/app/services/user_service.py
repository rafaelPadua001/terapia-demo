import re
from datetime import datetime

from sqlalchemy.orm import Session

from app.core.security import get_password_hash, verify_password
from app.models import User

DEFAULT_PORTAL_PASSWORD = "Brasil2026"
CPF_RE = re.compile(r"^\d{11}$")
REGISTRATION_RULES = {
    "CRP": re.compile(r"^\d{2,6}$"),
    "CRM": re.compile(r"^\d{4,6}$"),
    "CREFONO": re.compile(r"^\d{4,6}$"),
    "CFFA": re.compile(r"^\d{4,6}$"),
    "CREFITO": re.compile(r"^\d{4,6}$"),
    "MEC": re.compile(r"^[A-Za-z0-9/\\-]{1,20}$"),
    "ABPP": re.compile(r"^[A-Za-z0-9/\\-]{1,20}$"),
    "CFP": re.compile(r"^[A-Za-z0-9/\\-]{1,20}$"),
}
SPECIALTY_TO_REGISTRATION = {
    "psicologa": {"CRP"},
    "pedagoga": {"MEC"},
    "psicopedagoga": {"ABPP"},
    "neuropsicologo": {"CFP"},
    "terapeuta aba": {"CRP", "CREFONO", "CREFITO"},
    "fonoaudiologa": {"CREFONO", "CFFA"},
    "psiquiatra": {"CRM"},
}


def _normalize_cpf(value: str | None) -> str | None:
    if value is None:
        return None
    digits = "".join(ch for ch in value if ch.isdigit())
    return digits or None


def _is_valid_cpf_digits(value: str) -> bool:
    if not CPF_RE.fullmatch(value):
        return False
    if value == value[0] * 11:
        return False

    def _digit(base: str) -> str:
        total = sum(int(ch) * weight for ch, weight in zip(base, range(len(base) + 1, 1, -1)))
        remainder = total % 11
        return "0" if remainder < 2 else str(11 - remainder)

    first = _digit(value[:9])
    second = _digit(value[:9] + first)
    return value == f"{value[:9]}{first}{second}"


def _normalize_registration_type(value: str | None) -> str | None:
    if value is None:
        return None
    normalized = value.strip().upper()
    return normalized or None


def _normalize_professional_registration(value: str | None) -> str | None:
    if value is None:
        return None
    normalized = value.strip().upper()
    return normalized or None


def _validate_therapist_fields(
    *,
    cpf: str | None,
    specialty: str | None,
    registration_type: str | None,
    professional_registration: str | None,
) -> None:
    if not cpf:
        raise ValueError("CPF is required")
    if not _is_valid_cpf_digits(cpf):
        raise ValueError("Invalid CPF")

    normalized_specialty = (specialty or "").strip().lower()
    if not normalized_specialty:
        raise ValueError("Specialty is required")

    if not registration_type:
        raise ValueError("registration_type is required")
    if registration_type not in REGISTRATION_RULES:
        raise ValueError("Invalid registration_type")

    if not professional_registration:
        raise ValueError("professional_registration is required")
    if not REGISTRATION_RULES[registration_type].fullmatch(professional_registration):
        raise ValueError("Invalid professional_registration format")

    allowed = SPECIALTY_TO_REGISTRATION.get(normalized_specialty)
    if allowed and registration_type not in allowed:
        raise ValueError("registration_type is not compatible with specialty")


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
    cpf: str | None = None,
    registration_type: str | None = None,
    professional_registration: str | None = None,
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
        cpf=cpf,
        registration_type=registration_type,
        professional_registration=professional_registration,
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
    cpf: str,
    phone: str | None = None,
    specialty: str | None = None,
    registration_type: str | None = None,
    professional_registration: str | None = None,
    password: str | None = None,
) -> User:
    normalized_password = password.strip() if password else ""
    effective_password = normalized_password or DEFAULT_PORTAL_PASSWORD
    normalized_cpf = _normalize_cpf(cpf)
    normalized_specialty = specialty.strip() if specialty else None
    normalized_registration_type = _normalize_registration_type(registration_type)
    normalized_professional_registration = _normalize_professional_registration(professional_registration)

    _validate_therapist_fields(
        cpf=normalized_cpf,
        specialty=normalized_specialty,
        registration_type=normalized_registration_type,
        professional_registration=normalized_professional_registration,
    )

    return create_user(
        db,
        name=name,
        email=email.strip().lower(),
        phone=phone.strip() if phone else None,
        specialty=normalized_specialty,
        cpf=normalized_cpf,
        registration_type=normalized_registration_type,
        professional_registration=normalized_professional_registration,
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
    if "cpf" in update_data:
        therapist.cpf = _normalize_cpf(update_data["cpf"])
    if "registration_type" in update_data:
        therapist.registration_type = _normalize_registration_type(update_data["registration_type"])
    if "professional_registration" in update_data:
        therapist.professional_registration = _normalize_professional_registration(update_data["professional_registration"])

    _validate_therapist_fields(
        cpf=therapist.cpf,
        specialty=therapist.specialty,
        registration_type=therapist.registration_type,
        professional_registration=therapist.professional_registration,
    )

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
            return user
        if role == "guardian" and user.guardian_id not in (None, guardian_id):
            return user
        if user.role not in {role, "patient", "guardian"}:
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
