import re

from sqlalchemy.orm import Session

from app.core.security import get_password_hash
from app.models import Clinic, User
from app.schemas.schemas import ClinicCreate, UserCreate


def normalize_subdomain(value: str | None) -> str:
    normalized = (value or "").lower().strip()
    normalized = re.sub(r"[^a-z0-9-]", "", normalized)
    return normalized


def resolve_clinic_subdomain(name: str, subdomain: str | None = None) -> str | None:
    normalized = normalize_subdomain(subdomain)
    if normalized:
        return normalized

    fallback = normalize_subdomain((name or "").replace(" ", ""))
    return fallback or None


def get_or_create_clinic(
    db: Session,
    *,
    clinic_name: str,
    logo_url: str | None = None,
    subdomain: str | None = None,
) -> Clinic:
    clinic_subdomain = resolve_clinic_subdomain(clinic_name, subdomain)
    existing = None

    print("CLINIC DEBUG:")
    print("incoming:", clinic_name, logo_url, clinic_subdomain)

    if clinic_subdomain:
        existing = db.query(Clinic).filter(Clinic.subdomain == clinic_subdomain).first()

    if not existing:
        legacy_matches = db.query(Clinic).filter(Clinic.name.ilike(clinic_name)).all()
        if len(legacy_matches) == 1 and not legacy_matches[0].subdomain:
            candidate = legacy_matches[0]
            conflict = None
            if clinic_subdomain:
                conflict = (
                    db.query(Clinic)
                    .filter(Clinic.subdomain == clinic_subdomain, Clinic.id != candidate.id)
                    .first()
                )

            if not conflict:
                candidate.subdomain = clinic_subdomain
                if logo_url is not None and candidate.logo_url != logo_url:
                    candidate.logo_url = logo_url
                db.flush()
                existing = candidate

    if existing:
        print("existing:", existing)
        updated = False

        if clinic_name and existing.name != clinic_name:
            existing.name = clinic_name
            updated = True

        if logo_url is not None and existing.logo_url != logo_url:
            existing.logo_url = logo_url
            updated = True

        if clinic_subdomain and not existing.subdomain:
            existing.subdomain = clinic_subdomain
            updated = True

        if updated:
            db.flush()

        return existing

    clinic = Clinic(
        name=clinic_name,
        logo_url=logo_url,
        subdomain=clinic_subdomain,
    )
    db.add(clinic)
    db.flush()
    return clinic


def create_clinic_with_admin(db: Session, clinic_in: ClinicCreate, admin_in: UserCreate) -> Clinic:
    clinic = get_or_create_clinic(
        db,
        clinic_name=clinic_in.name,
        logo_url=clinic_in.logo_url,
        subdomain=clinic_in.subdomain,
    )

    existing_admin = db.query(User).filter(User.email == admin_in.email).first()
    if existing_admin:
        existing_admin.clinic_id = clinic.id
        existing_admin.name = admin_in.name
        existing_admin.role = admin_in.role
        existing_admin.email_is_confirmed = True
        if not existing_admin.password_hash:
            existing_admin.password_hash = get_password_hash(admin_in.password)
    else:
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
