import logging

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import BCRYPT_MAX_PASSWORD_BYTES, PasswordValidationError, create_access_token
from app.models import User
from app.schemas.schemas import (
    ChangePasswordRequest,
    ForgotPasswordRequest,
    GenericMessageOut,
    LoginRequest,
    ResetPasswordRequest,
    ResetTokenValidationOut,
    Token,
)
from app.services.auth_service import (
    confirm_email_token,
    create_password_reset_token,
    get_user_by_reset_token,
    reset_user_password,
)
from app.services.email_service import send_password_reset_email_async
from app.services.user_service import authenticate, change_password
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/auth", tags=["auth"])
logger = logging.getLogger(__name__)


@router.post("/login", response_model=Token)
def login(data: LoginRequest, db: Session = Depends(get_db)):
    password_bytes = len(data.password.encode("utf-8"))
    logger.info("AUTH LOGIN password_bytes=%s", password_bytes)
    if password_bytes > BCRYPT_MAX_PASSWORD_BYTES:
        raise HTTPException(
            status_code=400,
            detail=f"Password cannot be longer than {BCRYPT_MAX_PASSWORD_BYTES} bytes",
        )

    try:
        user = authenticate(db, data.email, data.password)
    except PasswordValidationError as exc:
        raise HTTPException(status_code=400, detail=str(exc))

    if not user:
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    if data.role and user.role != data.role:
        raise HTTPException(status_code=403, detail="Invalid role")

    access_token = create_access_token(subject=str(user.id), clinic_id=str(user.clinic_id), role=user.role)
    return Token(
        access_token=access_token,
        first_login=user.first_login,
        has_seen_tutorial=user.has_seen_tutorial,
    )


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


@router.post("/forgot-password", response_model=GenericMessageOut)
def forgot_password(data: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email, User.deleted_at.is_(None)).first()
    if user:
        token = create_password_reset_token(db, user)
        db.commit()
        send_password_reset_email_async(user.email, user.name, token)
    return GenericMessageOut(message="Se o email existir, voce recebera um link")


@router.get("/validate-reset-token", response_model=ResetTokenValidationOut)
def validate_reset_token(token: str, db: Session = Depends(get_db)):
    user = get_user_by_reset_token(db, token)
    if not user:
        raise HTTPException(status_code=400, detail="Token invalido ou expirado")
    return ResetTokenValidationOut(valid=True)


@router.post("/reset-password", response_model=GenericMessageOut)
def reset_password(data: ResetPasswordRequest, db: Session = Depends(get_db)):
    password_bytes = len(data.new_password.encode("utf-8"))
    if password_bytes > BCRYPT_MAX_PASSWORD_BYTES:
        raise HTTPException(
            status_code=400,
            detail=f"Password cannot be longer than {BCRYPT_MAX_PASSWORD_BYTES} bytes",
        )

    user = get_user_by_reset_token(db, data.token)
    if not user:
        raise HTTPException(status_code=400, detail="Token invalido ou expirado")

    try:
        reset_user_password(user, data.new_password)
    except PasswordValidationError as exc:
        raise HTTPException(status_code=400, detail=str(exc))

    db.commit()
    return GenericMessageOut(message="Senha atualizada com sucesso")


@router.post("/change-password", response_model=GenericMessageOut)
def update_password(
    data: ChangePasswordRequest,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    current_user = (
        db.query(User)
        .filter(User.id == user.id, User.clinic_id == user.clinic_id, User.deleted_at.is_(None))
        .first()
    )
    if not current_user:
        raise HTTPException(status_code=404, detail="User not found")

    password_bytes = len(data.new_password.encode("utf-8"))
    if password_bytes > BCRYPT_MAX_PASSWORD_BYTES:
        raise HTTPException(
            status_code=400,
            detail=f"Password cannot be longer than {BCRYPT_MAX_PASSWORD_BYTES} bytes",
        )

    try:
        change_password(db, user=current_user, new_password=data.new_password)
    except PasswordValidationError as exc:
        raise HTTPException(status_code=400, detail=str(exc))

    return GenericMessageOut(message="Senha atualizada com sucesso")


@router.post("/tutorial-complete", response_model=GenericMessageOut)
def tutorial_complete(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    current_user = (
        db.query(User)
        .filter(User.id == user.id, User.clinic_id == user.clinic_id, User.deleted_at.is_(None))
        .first()
    )
    if not current_user:
        raise HTTPException(status_code=404, detail="User not found")

    current_user.has_seen_tutorial = True
    db.commit()
    return GenericMessageOut(message="Tutorial concluido")
