import logging
from datetime import datetime, timedelta
from typing import Any

from jose import jwt
from passlib.context import CryptContext

from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
logger = logging.getLogger(__name__)

BCRYPT_MAX_PASSWORD_BYTES = 72


class PasswordValidationError(ValueError):
    pass


def _password_length_bytes(password: str) -> int:
    return len(password.encode("utf-8"))


def validate_bcrypt_password(password: str) -> None:
    password_bytes = _password_length_bytes(password)
    if password_bytes > BCRYPT_MAX_PASSWORD_BYTES:
        logger.warning(
            "Rejected password due to bcrypt byte limit: %s bytes received",
            password_bytes,
        )
        raise PasswordValidationError(
            f"Password cannot be longer than {BCRYPT_MAX_PASSWORD_BYTES} bytes"
        )


def _looks_like_bcrypt_hash(value: str) -> bool:
    return value.startswith("$2a$") or value.startswith("$2b$") or value.startswith("$2y$")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    validate_bcrypt_password(plain_password)

    if _looks_like_bcrypt_hash(plain_password):
        logger.warning(
            "Suspicious login input detected: plaintext password looks like a bcrypt hash (length=%s)",
            len(plain_password),
        )

    try:
        return pwd_context.verify(plain_password, hashed_password)
    except ValueError:
        logger.exception(
            "Password verification failed unexpectedly (password_bytes=%s, hash_length=%s)",
            _password_length_bytes(plain_password),
            len(hashed_password or ""),
        )
        raise


def get_password_hash(password: str) -> str:
    validate_bcrypt_password(password)
    return pwd_context.hash(password)


def create_access_token(subject: str, clinic_id: str, role: str, expires_delta: int | None = None) -> str:
    if expires_delta is None:
        expires_delta = settings.access_token_expire_minutes
    expire = datetime.utcnow() + timedelta(minutes=expires_delta)
    to_encode: dict[str, Any] = {
        "exp": expire,
        "sub": subject,
        "clinic_id": clinic_id,
        "role": role,
    }
    return jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)
