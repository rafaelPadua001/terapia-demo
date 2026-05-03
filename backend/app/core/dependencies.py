import logging

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.models import User
from app.schemas.schemas import TokenPayload

security = HTTPBearer()
logger = logging.getLogger("app.auth")


def normalize_role(role: str | None) -> str:
    if role == "reception":
        return "receptionist"
    return role or ""


def get_current_user(
    request: Request,
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    token = credentials.credentials
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
        token_data = TokenPayload(**payload)
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    user = db.query(User).filter(User.id == token_data.sub, User.deleted_at.is_(None)).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    if str(user.clinic_id) != str(token_data.clinic_id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid clinic")
    tenant_clinic = getattr(request.state, "clinic", None) or getattr(request.state, "tenant_clinic", None)
    if tenant_clinic and str(tenant_clinic.id) != str(user.clinic_id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid tenant context")

    user.role = normalize_role(user.role)
    return user


def require_role(*roles: str):
    def _role_guard(user: User = Depends(get_current_user)) -> User:
        allowed_roles = {normalize_role(role) for role in roles}
        if user.role not in allowed_roles:
            logger.warning(
                "Acesso negado",
                extra={
                    "user_id": str(user.id),
                    "role": user.role,
                    "allowed_roles": sorted(allowed_roles),
                },
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={
                    "error": "Forbidden",
                    "message": "Voce nao tem permissao para executar esta acao",
                },
            )
        return user

    return _role_guard
