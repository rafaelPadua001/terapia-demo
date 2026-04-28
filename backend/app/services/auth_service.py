import hashlib
import secrets
from datetime import datetime, timedelta

from itsdangerous import BadSignature, SignatureExpired, URLSafeTimedSerializer
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.security import get_password_hash
from app.models import User


serializer = URLSafeTimedSerializer(settings.secret_key)


def generate_email_token(email: str) -> str:
    return serializer.dumps(email, salt="email-confirm")


def confirm_email_token(token: str, expiration: int = 86400) -> str:
    try:
        return serializer.loads(token, salt="email-confirm", max_age=expiration)
    except (BadSignature, SignatureExpired) as exc:
        raise ValueError("Token invalido ou expirado") from exc


def _hash_reset_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def create_password_reset_token(db: Session, user: User) -> str:
    token = secrets.token_urlsafe(48)
    user.reset_token_hash = _hash_reset_token(token)
    user.reset_token_expiration = datetime.utcnow() + timedelta(hours=1)
    db.flush()
    return token


def get_user_by_reset_token(db: Session, token: str) -> User | None:
    token_hash = _hash_reset_token(token)
    return (
        db.query(User)
        .filter(
            User.reset_token_hash == token_hash,
            User.reset_token_expiration.is_not(None),
            User.reset_token_expiration >= datetime.utcnow(),
            User.deleted_at.is_(None),
        )
        .first()
    )


def clear_password_reset_token(user: User) -> None:
    user.reset_token_hash = None
    user.reset_token_expiration = None


def reset_user_password(user: User, new_password: str) -> None:
    user.password_hash = get_password_hash(new_password)
    user.first_login = False
    clear_password_reset_token(user)
