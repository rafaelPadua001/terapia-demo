from datetime import datetime

import requests
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.modules.financial.models import FinancialAccount, FinancialTransaction
from app.modules.financial.service import _resolve_notification_user_ids
from app.modules.notifications.service import create_notification

router = APIRouter(prefix="/webhooks", tags=["webhooks"])


def _try_fetch_payment(payment_id: str, access_token: str) -> dict | None:
    url = f"https://api.mercadopago.com/v1/payments/{payment_id}"
    headers = {"Authorization": f"Bearer {access_token}"}
    try:
        resp = requests.get(url, headers=headers, timeout=20)
    except requests.RequestException:
        return None
    if resp.status_code != 200:
        return None
    try:
        return resp.json()
    except ValueError:
        return None


def _map_mp_status(status: str | None) -> str | None:
    normalized = str(status or "").strip().lower()
    mapping = {
        "approved": "paid",
        "pending": "pending",
        "rejected": "failed",
    }
    return mapping.get(normalized)


@router.post("/mercadopago")
async def mercadopago_webhook(request: Request, db: Session = Depends(get_db)):
    try:
        body = await request.json()
    except Exception:
        body = {}

    payment_id = None
    if isinstance(body, dict):
        payment_id = body.get("data", {}).get("id") or body.get("id")
        if body.get("type") and str(body.get("type")).strip().lower() != "payment":
            return {"status": "ok"}

    payment_id = payment_id or request.query_params.get("id") or request.query_params.get("data.id")

    if not payment_id:
        return {"status": "ok"}

    accounts = (
        db.query(FinancialAccount)
        .filter(FinancialAccount.type == "mercadopago", FinancialAccount.is_active.is_(True))
        .all()
    )

    payment_data = None
    for account in accounts:
        meta = account.meta or {}
        token = str(meta.get("access_token", "")).strip()
        if not token:
            continue
        payment_data = _try_fetch_payment(str(payment_id), token)
        if payment_data:
            break

    if not payment_data:
        return {"status": "ok"}

    external_reference = payment_data.get("external_reference")
    status = payment_data.get("status")
    mapped_status = _map_mp_status(status)

    if not external_reference:
        return {"status": "ok"}

    transaction = db.query(FinancialTransaction).filter(FinancialTransaction.id == external_reference).first()
    if not transaction:
        return {"status": "ok"}

    if mapped_status and transaction.status != mapped_status:
        transaction.status = mapped_status
        if mapped_status == "paid":
            transaction.paid_at = datetime.utcnow()

        title_by_status = {
            "paid": "Pagamento confirmado",
            "pending": "Pagamento pendente",
            "failed": "Pagamento recusado",
        }
        message_by_status = {
            "paid": f"Pagamento de R$ {transaction.amount} confirmado",
            "pending": f"Pagamento de R$ {transaction.amount} ainda pendente",
            "failed": f"Pagamento de R$ {transaction.amount} recusado",
        }

        notification_user_ids = _resolve_notification_user_ids(
            db,
            clinic_id=transaction.clinic_id,
            patient_id=transaction.patient_id,
        )
        for notification_user_id in notification_user_ids:
            create_notification(
                db,
                user_id=notification_user_id,
                title=title_by_status[mapped_status],
                message=message_by_status[mapped_status],
            )

        db.commit()

    return {"status": "ok"}
