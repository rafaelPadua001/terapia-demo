from itsdangerous import BadSignature, SignatureExpired, URLSafeTimedSerializer

from app.core.config import settings


serializer = URLSafeTimedSerializer(settings.secret_key)


def generate_email_token(email: str) -> str:
    return serializer.dumps(email, salt="email-confirm")


def confirm_email_token(token: str, expiration: int = 86400) -> str:
    try:
        return serializer.loads(token, salt="email-confirm", max_age=expiration)
    except (BadSignature, SignatureExpired) as exc:
        raise ValueError("Token inválido ou expirado") from exc
