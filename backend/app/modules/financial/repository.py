from sqlalchemy.orm import Query, Session
from sqlalchemy.orm import joinedload

from app.modules.financial.models import FinancialAccount, FinancialTransaction


def create_account(db: Session, account: FinancialAccount) -> FinancialAccount:
    db.add(account)
    db.flush()
    return account


def list_accounts(db: Session, *, clinic_id):
    return (
        db.query(FinancialAccount)
        .filter(FinancialAccount.clinic_id == clinic_id)
        .order_by(FinancialAccount.created_at.desc())
        .all()
    )


def get_account_by_id(db: Session, *, clinic_id, account_id):
    return (
        db.query(FinancialAccount)
        .filter(FinancialAccount.id == account_id, FinancialAccount.clinic_id == clinic_id)
        .first()
    )


def update_account(db: Session, account: FinancialAccount) -> FinancialAccount:
    db.add(account)
    db.flush()
    return account


def delete_account(db: Session, account: FinancialAccount) -> None:
    db.delete(account)
    db.flush()


def build_transactions_query(db: Session, *, clinic_id) -> Query:
    return (
        db.query(FinancialTransaction)
        .options(joinedload(FinancialTransaction.patient))
        .filter(FinancialTransaction.clinic_id == clinic_id)
    )


def create_transaction(db: Session, transaction: FinancialTransaction) -> FinancialTransaction:
    db.add(transaction)
    db.flush()
    return transaction


def get_transaction_by_id(db: Session, *, clinic_id, transaction_id):
    return (
        db.query(FinancialTransaction)
        .filter(FinancialTransaction.id == transaction_id, FinancialTransaction.clinic_id == clinic_id)
        .first()
    )


def update_transaction(db: Session, transaction: FinancialTransaction) -> FinancialTransaction:
    db.add(transaction)
    db.flush()
    return transaction


def delete_transaction(db: Session, transaction: FinancialTransaction) -> None:
    db.delete(transaction)
    db.flush()
