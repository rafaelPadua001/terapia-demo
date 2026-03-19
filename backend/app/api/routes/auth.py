from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import create_access_token
from app.models import User
from app.schemas.schemas import LoginRequest, Token
from app.services.auth_service import confirm_email_token
from app.services.user_service import authenticate

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login", response_model=Token)
def login(data: LoginRequest, db: Session = Depends(get_db)):
    user = authenticate(db, data.email, data.password)
    if not user:
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    if data.role and user.role != data.role:
        raise HTTPException(status_code=403, detail="Invalid role")

    access_token = create_access_token(subject=str(user.id), clinic_id=str(user.clinic_id), role=user.role)
    return Token(access_token=access_token)


@router.get("/confirm-email")
def confirm_email(token: str, db: Session = Depends(get_db)):
    try:
        email = confirm_email_token(token)
    except ValueError:
        raise HTTPException(status_code=400, detail="Token inválido ou expirado")

    user = db.query(User).filter(User.email == email, User.deleted_at.is_(None)).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")

    if not user.email_is_confirmed:
        user.email_is_confirmed = True
        db.commit()

    return {"message": "Email confirmado com sucesso"}
