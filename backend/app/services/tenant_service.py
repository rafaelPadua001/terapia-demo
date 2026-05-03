import re

from sqlalchemy.orm import Session

from app.core.config import settings
from app.models import Clinic

LOCAL_HOSTS = {"localhost", "127.0.0.1"}


def get_subdomain(host: str | None) -> str | None:
    if not host:
        return None
    host_name = host.split(":")[0].strip().lower()
    if host_name in LOCAL_HOSTS:
        return None
    if host_name == "localhost.tiangolo.com":
        return None
    localhost_test_suffix = ".localhost.tiangolo.com"
    if host_name.endswith(localhost_test_suffix):
        candidate = host_name[: -len(localhost_test_suffix)]
        return candidate or None
    if re.match(r"^\d+\.\d+\.\d+\.\d+$", host_name):
        return None

    base_domain = (settings.tenant_base_domain or "").strip().lower()
    if base_domain:
        suffix = f".{base_domain}"
        if not host_name.endswith(suffix):
            return None
        candidate = host_name[: -len(suffix)]
        if not candidate or "." in candidate:
            return None
        return candidate

    parts = host_name.split(".")
    if len(parts) < 3:
        return None
    return parts[0]


def extract_subdomain(host: str | None) -> str | None:
    return get_subdomain(host)


def get_clinic_by_subdomain(db: Session, subdomain: str | None) -> Clinic | None:
    if not subdomain:
        return None
    return db.query(Clinic).filter(Clinic.subdomain == subdomain).first()


def get_default_clinic(db: Session) -> Clinic | None:
    return db.query(Clinic).order_by(Clinic.created_at.asc()).first()
