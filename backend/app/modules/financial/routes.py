from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from uuid import UUID

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.modules.financial.schemas import (
    FinancialAccountCreate,
    FinancialAccountOut,
    FinancialAccountUpdate,
    FinancialTransactionCreate,
    FinancialTransactionOut,
    FinancialTransactionPayRequest,
    FinancialTransactionsPage,
)
from app.modules.financial.service import (
    create_billing_transaction,
    create_financial_account,
    delete_financial_account,
    delete_financial_transaction,
    generate_payment_link,
    list_financial_accounts,
    list_my_transactions,
    list_transactions,
    mark_transaction_as_paid,
    update_financial_account,
)
from app.modules.notifications.schemas import NotificationOut
from app.modules.notifications.service import list_notifications, mark_notification_as_read

router = APIRouter(prefix="/financial", tags=["financial"])


@router.post(
    "/accounts",
    response_model=FinancialAccountOut,
    dependencies=[Depends(require_role("admin", "therapist", "receptionist"))],
)
def create_account(
    payload: FinancialAccountCreate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    return create_financial_account(db, user=user, payload=payload)


@router.get(
    "/accounts",
    response_model=list[FinancialAccountOut],
    dependencies=[Depends(require_role("admin", "therapist", "receptionist"))],
)
def get_accounts(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    return list_financial_accounts(db, user=user)


@router.patch(
    "/accounts/{account_id}",
    response_model=FinancialAccountOut,
    dependencies=[Depends(require_role("admin", "therapist", "receptionist"))],
)
def patch_account(
    account_id: str,
    payload: FinancialAccountUpdate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    return update_financial_account(db, user=user, account_id=account_id, payload=payload)


@router.delete(
    "/accounts/{account_id}",
    dependencies=[Depends(require_role("admin", "therapist", "receptionist"))],
)
def remove_account(
    account_id: str,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    delete_financial_account(db, user=user, account_id=account_id)
    return {"success": True}


@router.post(
    "/transactions",
    response_model=FinancialTransactionOut,
    dependencies=[Depends(require_role("admin", "therapist", "receptionist"))],
)
def create_transaction(
    payload: FinancialTransactionCreate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    return create_billing_transaction(db, user=user, payload=payload)


@router.get(
    "/transactions",
    response_model=FinancialTransactionsPage,
    dependencies=[Depends(require_role("admin", "therapist", "receptionist", "patient", "guardian"))],
)
def get_transactions(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    patient_id: UUID | None = None,
    status: str | None = None,
):
    items, total = list_transactions(db, user=user, page=page, limit=limit, patient_id=patient_id, status=status)
    return FinancialTransactionsPage(items=items, total=total, page=page, limit=limit)


@router.patch(
    "/transactions/{transaction_id}/pay",
    response_model=FinancialTransactionOut,
    dependencies=[Depends(require_role("admin", "therapist", "receptionist"))],
)
def pay_transaction(
    transaction_id: str,
    payload: FinancialTransactionPayRequest | None = None,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    payment_method = payload.payment_method if payload else "pix"
    return mark_transaction_as_paid(db, user=user, transaction_id=transaction_id, payment_method=payment_method)


@router.delete(
    "/transactions/{transaction_id}",
    dependencies=[Depends(require_role("admin", "therapist", "receptionist"))],
)
def remove_transaction(
    transaction_id: str,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    delete_financial_transaction(db, user=user, transaction_id=transaction_id)
    return {"success": True}


@router.post(
    "/transactions/{transaction_id}/generate-payment",
    dependencies=[Depends(require_role("admin", "therapist", "receptionist", "patient", "guardian"))],
)
def create_payment_link(
    transaction_id: str,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    return generate_payment_link(db, user=user, transaction_id=transaction_id)


@router.get(
    "/my-transactions",
    response_model=FinancialTransactionsPage,
    dependencies=[Depends(require_role("patient", "guardian"))],
)
def get_my_transactions(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
):
    items, total = list_my_transactions(db, user=user, page=page, limit=limit)
    return FinancialTransactionsPage(items=items, total=total, page=page, limit=limit)


@router.get(
    "/notifications",
    response_model=list[NotificationOut],
    dependencies=[Depends(require_role("patient", "guardian", "admin", "therapist", "receptionist"))],
)
def get_financial_notifications(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
    limit: int = Query(50, ge=1, le=200),
):
    return list_notifications(db, user_id=user.id, limit=limit)


@router.patch(
    "/notifications/{notification_id}/read",
    dependencies=[Depends(require_role("patient", "guardian", "admin", "therapist", "receptionist"))],
)
def mark_financial_notification_as_read(
    notification_id: str,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    notification = mark_notification_as_read(db, notification_id=notification_id, user_id=user.id)
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    db.commit()
    return {"success": True}

