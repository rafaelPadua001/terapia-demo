from datetime import datetime

import os

import requests
from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.guardian_patient import GuardianPatient
from app.models.user import User
from app.modules.financial import repository
from app.modules.financial.models import FinancialAccount, FinancialTransaction
from app.modules.financial.schemas import (
    FINANCIAL_ACCOUNT_TYPES,
    PAYMENT_METHODS,
    TRANSACTION_STATUSES,
    FinancialAccountCreate,
    FinancialAccountUpdate,
    FinancialTransactionCreate,
)
from app.modules.notifications.service import create_notification
from app.services.rbac_service import resolve_guardian_patient_ids, resolve_patient_id

STAFF_ROLES = {"admin", "therapist", "receptionist"}
PATIENT_ROLES = {"patient", "guardian"}


def _normalize_role(role: str | None) -> str:
    return (role or "").strip().lower()


def _validate_account_type(value: str) -> str:
    normalized = value.strip().lower()
    if normalized not in FINANCIAL_ACCOUNT_TYPES:
        raise HTTPException(status_code=400, detail="Invalid account type")
    return normalized


def _validate_transaction_status(value: str) -> str:
    normalized = value.strip().lower()
    if normalized not in TRANSACTION_STATUSES:
        raise HTTPException(status_code=400, detail="Invalid transaction status")
    return normalized


def _validate_payment_method(value: str) -> str:
    normalized = value.strip().lower()
    if normalized not in PAYMENT_METHODS:
        raise HTTPException(status_code=400, detail="Invalid payment method")
    return normalized


def _normalize_metadata(metadata: dict | None) -> dict | None:
    if metadata is None:
        return None
    if not isinstance(metadata, dict):
        raise HTTPException(status_code=400, detail="Invalid metadata")
    return metadata


def _staff_or_readonly_guard(user) -> None:
    role = _normalize_role(user.role)
    if role not in STAFF_ROLES and role not in PATIENT_ROLES:
        raise HTTPException(status_code=403, detail="Financial access denied")


def _require_staff(user) -> None:
    role = _normalize_role(user.role)
    if role not in STAFF_ROLES:
        raise HTTPException(status_code=403, detail="Staff role required")


def _resolve_notification_user_ids(db: Session, *, clinic_id, patient_id):
    if not patient_id:
        return []

    ids = set()

    patient_user_ids = (
        db.query(User.id)
        .filter(
            User.clinic_id == clinic_id,
            User.patient_id == patient_id,
            User.deleted_at.is_(None),
        )
        .all()
    )
    ids.update(item[0] for item in patient_user_ids)

    guardian_ids = (
        db.query(GuardianPatient.guardian_id)
        .filter(GuardianPatient.patient_id == patient_id)
        .all()
    )
    guardian_ids = [item[0] for item in guardian_ids]

    if guardian_ids:
        guardian_user_ids = (
            db.query(User.id)
            .filter(
                User.clinic_id == clinic_id,
                User.guardian_id.in_(guardian_ids),
                User.deleted_at.is_(None),
            )
            .all()
        )
        ids.update(item[0] for item in guardian_user_ids)

    return list(ids)


def create_financial_account(db: Session, *, user, payload: FinancialAccountCreate) -> FinancialAccount:
    _require_staff(user)
    metadata = _normalize_metadata(payload.metadata)
    account = FinancialAccount(
        clinic_id=user.clinic_id,
        name=payload.name.strip(),
        type=_validate_account_type(payload.type),
        is_active=payload.is_active,
        meta=metadata,
    )
    repository.create_account(db, account)
    db.commit()
    db.refresh(account)
    return account


def update_financial_account(db: Session, *, user, account_id, payload: FinancialAccountUpdate) -> FinancialAccount:
    _require_staff(user)
    account = repository.get_account_by_id(db, clinic_id=user.clinic_id, account_id=account_id)
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")

    if payload.name is not None:
        account.name = payload.name.strip()
    if payload.type is not None:
        account.type = _validate_account_type(payload.type)
    if payload.is_active is not None:
        account.is_active = payload.is_active

    if payload.metadata is not None:
        account.meta = _normalize_metadata(payload.metadata)

    repository.update_account(db, account)
    db.commit()
    db.refresh(account)
    return account


def delete_financial_account(db: Session, *, user, account_id) -> None:
    _require_staff(user)
    account = repository.get_account_by_id(db, clinic_id=user.clinic_id, account_id=account_id)
    if not account:
        raise HTTPException(status_code=404, detail="Conta nao encontrada")

    try:
        repository.delete_account(db, account)
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail="Conta possui transacoes vinculadas")


def list_financial_accounts(db: Session, *, user):
    _staff_or_readonly_guard(user)
    return repository.list_accounts(db, clinic_id=user.clinic_id)


def create_billing_transaction(db: Session, *, user, payload: FinancialTransactionCreate) -> FinancialTransaction:
    _require_staff(user)
    account = repository.get_account_by_id(db, clinic_id=user.clinic_id, account_id=payload.account_id)
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")

    account_metadata = account.meta or {}
    if account.type == "mercadopago":
        access_token = str(account_metadata.get("access_token", "")).strip()
        public_key = str(account_metadata.get("public_key", "")).strip()
        notification_url = str(account_metadata.get("notification_url", "")).strip()
        environment = str(account_metadata.get("environment", "sandbox")).strip().lower() or "sandbox"
        _ = {
            "access_token": access_token,
            "public_key": public_key,
            "notification_url": notification_url,
            "environment": environment,
        }

    transaction = FinancialTransaction(
        clinic_id=user.clinic_id,
        patient_id=payload.patient_id,
        guardian_id=payload.guardian_id,
        description=payload.description.strip(),
        amount=payload.amount,
        status=_validate_transaction_status(payload.status),
        due_date=payload.due_date,
        payment_method=_validate_payment_method(payload.payment_method),
        account_id=payload.account_id,
        external_id=payload.external_id,
    )
    repository.create_transaction(db, transaction)

    notification_user_ids = _resolve_notification_user_ids(db, clinic_id=user.clinic_id, patient_id=transaction.patient_id)
    for notification_user_id in notification_user_ids:
        create_notification(
            db,
            user_id=notification_user_id,
            title="Nova cobranca",
            message=f"Voce possui uma nova cobranca de R$ {transaction.amount}",
        )

    db.commit()
    db.refresh(transaction)
    notify_patient(transaction)
    return transaction


def list_transactions(
    db: Session,
    *,
    user,
    page: int,
    limit: int,
    patient_id=None,
    status: str | None = None,
):
    _staff_or_readonly_guard(user)
    query = repository.build_transactions_query(db, clinic_id=user.clinic_id)

    role = _normalize_role(user.role)
    if role == "patient":
        my_patient_id = resolve_patient_id(db, user)
        if not my_patient_id:
            return [], 0
        query = query.filter(FinancialTransaction.patient_id == my_patient_id)
    elif role == "guardian":
        guardian_patient_ids = resolve_guardian_patient_ids(db, user)
        if not guardian_patient_ids:
            return [], 0
        query = query.filter(FinancialTransaction.patient_id.in_(guardian_patient_ids))
    elif patient_id:
        query = query.filter(FinancialTransaction.patient_id == patient_id)

    if status:
        query = query.filter(FinancialTransaction.status == _validate_transaction_status(status))

    total = query.count()
    items = query.order_by(FinancialTransaction.due_date.desc()).offset((page - 1) * limit).limit(limit).all()
    return items, total


def mark_transaction_as_paid(db: Session, *, user, transaction_id, payment_method: str) -> FinancialTransaction:
    _require_staff(user)
    transaction = repository.get_transaction_by_id(db, clinic_id=user.clinic_id, transaction_id=transaction_id)
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")

    transaction.status = "paid"
    transaction.payment_method = _validate_payment_method(payment_method)
    transaction.paid_at = datetime.utcnow()

    notification_user_ids = _resolve_notification_user_ids(db, clinic_id=user.clinic_id, patient_id=transaction.patient_id)
    for notification_user_id in notification_user_ids:
        create_notification(
            db,
            user_id=notification_user_id,
            title="Pagamento confirmado",
            message=f"Pagamento de R$ {transaction.amount} confirmado",
        )

    notify_patient_payment(transaction)
    db.commit()
    db.refresh(transaction)
    return transaction


def delete_financial_transaction(db: Session, *, user, transaction_id) -> None:
    _require_staff(user)
    transaction = repository.get_transaction_by_id(db, clinic_id=user.clinic_id, transaction_id=transaction_id)
    if not transaction:
        raise HTTPException(status_code=404, detail="Transacao nao encontrada")

    repository.delete_transaction(db, transaction)
    db.commit()


def _create_mercadopago_preference(db: Session, transaction: FinancialTransaction, account: FinancialAccount) -> str:
    account_metadata = account.meta or {}
    access_token = str(account_metadata.get("access_token", "")).strip()
    if not access_token:
        raise HTTPException(status_code=400, detail="Conta Mercado Pago sem access_token configurado")

    environment = str(account_metadata.get("environment", "sandbox")).strip().lower() or "sandbox"

    url = "https://api.mercadopago.com/checkout/preferences"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
    }
    payload = {
        "items": [
            {
                "title": transaction.description or "Sessao terapeutica",
                "quantity": 1,
                "unit_price": float(transaction.amount),
            }
        ],
        "external_reference": str(transaction.id),
    }

    frontend_base_url = str(settings.frontend_url or "").strip().rstrip("/")
    if not frontend_base_url:
        raise HTTPException(status_code=500, detail="FRONTEND_URL nao configurada")
    payload["back_urls"] = {
        "success": f"{frontend_base_url}/payment/success",
        "failure": f"{frontend_base_url}/payment/failure",
        "pending": f"{frontend_base_url}/payment/pending",
    }
    payload["auto_return"] = "approved"

    patient_user = (
        db.query(User)
        .filter(
            User.patient_id == transaction.patient_id,
            User.clinic_id == transaction.clinic_id,
            User.deleted_at.is_(None),
        )
        .first()
    )
    if patient_user and patient_user.email:
        payload["payer"] = {"email": patient_user.email}

    notification_url = str(account_metadata.get("notification_url", "")).strip()
    if notification_url:
        payload["notification_url"] = notification_url

    try:
        print("MP ENV:", environment)
        print("MP PAYLOAD:", payload)
        print("MP PAYLOAD FINAL:", payload)
        response = requests.post(url, json=payload, headers=headers, timeout=20)
    except requests.RequestException:
        raise HTTPException(status_code=502, detail="Falha ao comunicar com Mercado Pago")

    print("MP RESPONSE:", response.status_code, response.text)

    if response.status_code not in (200, 201):
        raise HTTPException(status_code=502, detail="Erro ao criar pagamento Mercado Pago")

    data = response.json()
    if environment == "production":
        payment_link = data.get("init_point")
    else:
        payment_link = data.get("sandbox_init_point")
    if not payment_link:
        raise HTTPException(status_code=502, detail="Link de pagamento nao retornado pelo Mercado Pago")
    return payment_link


def generate_payment_link(db: Session, *, user, transaction_id: str) -> dict:
    _staff_or_readonly_guard(user)
    transaction = repository.get_transaction_by_id(db, clinic_id=user.clinic_id, transaction_id=transaction_id)
    if not transaction:
        raise HTTPException(status_code=404, detail="Transacao nao encontrada")

    role = _normalize_role(user.role)
    if role == "patient":
        my_patient_id = resolve_patient_id(db, user)
        if not my_patient_id or transaction.patient_id != my_patient_id:
            raise HTTPException(status_code=403, detail="Acesso negado a esta cobranca")
    elif role == "guardian":
        guardian_patient_ids = resolve_guardian_patient_ids(db, user)
        if not guardian_patient_ids or transaction.patient_id not in guardian_patient_ids:
            raise HTTPException(status_code=403, detail="Acesso negado a esta cobranca")

    account = repository.get_account_by_id(db, clinic_id=user.clinic_id, account_id=transaction.account_id)
    if not account:
        raise HTTPException(status_code=404, detail="Conta nao encontrada")
    if account.type != "mercadopago":
        raise HTTPException(status_code=400, detail="Conta nao e Mercado Pago")

    payment_link = _create_mercadopago_preference(db, transaction, account)
    transaction.external_id = payment_link
    db.commit()
    db.refresh(transaction)
    return {"payment_link": payment_link, "external_id": transaction.external_id}


def notify_patient(transaction: FinancialTransaction) -> None:
    message = (
        f"Nova cobranca gerada:\n\n"
        f"Valor: R$ {transaction.amount}\n"
        f"Vencimento: {transaction.due_date}\n\n"
        f"Acesse o sistema para visualizar."
    )
    print("NOTIFICACAO:", message)


def notify_patient_payment(transaction: FinancialTransaction) -> None:
    print(
        "Pagamento confirmado!\n\n"
        f"Paciente ID: {transaction.patient_id}\n"
        f"Valor: {transaction.amount}"
    )


def list_my_transactions(db: Session, *, user, page: int, limit: int):
    role = _normalize_role(user.role)
    if role not in {"patient", "guardian"}:
        raise HTTPException(status_code=403, detail="Only patient/guardian can use this endpoint")
    return list_transactions(db, user=user, page=page, limit=limit)
