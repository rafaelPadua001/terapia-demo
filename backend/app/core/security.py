from datetime import datetime, timedelta
from typing import Any

from jose import jwt
from passlib.context import CryptContext

from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
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
