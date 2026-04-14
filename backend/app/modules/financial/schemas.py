from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

FINANCIAL_ACCOUNT_TYPES = {"mercadopago", "bank", "cash"}
TRANSACTION_STATUSES = {"pending", "paid", "overdue", "canceled"}
PAYMENT_METHODS = {"pix", "cash", "card", "mercadopago"}


class FinancialAccountCreate(BaseModel):
    name: str = Field(min_length=2, max_length=255)
    type: str
    is_active: bool = True
    metadata: dict | None = None


class FinancialAccountUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=255)
    type: str | None = None
    is_active: bool | None = None
    metadata: dict | None = None


class FinancialAccountOut(BaseModel):
    id: UUID
    clinic_id: UUID
    name: str
    type: str
    is_active: bool
    metadata: dict | None = Field(default=None, alias="meta")
    created_at: datetime

    model_config = ConfigDict(from_attributes=True, populate_by_name=True)


class FinancialTransactionCreate(BaseModel):
    patient_id: UUID | None = None
    guardian_id: UUID | None = None
    description: str = Field(min_length=2, max_length=255)
    amount: float = Field(gt=0)
    status: str = "pending"
    due_date: datetime
    payment_method: str = "pix"
    account_id: UUID
    external_id: str | None = None


class PatientInfo(BaseModel):
    id: UUID
    name: str

    model_config = ConfigDict(from_attributes=True)


class FinancialTransactionOut(BaseModel):
    id: UUID
    clinic_id: UUID
    patient_id: UUID | None = None
    guardian_id: UUID | None = None
    description: str
    amount: float
    status: str
    due_date: datetime
    paid_at: datetime | None = None
    payment_method: str
    account_id: UUID
    external_id: str | None = None
    created_at: datetime
    patient: PatientInfo | None = None

    model_config = ConfigDict(from_attributes=True)


class FinancialTransactionPayRequest(BaseModel):
    payment_method: str = "pix"


class FinancialTransactionsPage(BaseModel):
    items: list[FinancialTransactionOut]
    total: int
    page: int
    limit: int
