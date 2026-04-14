import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, JSON, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base


class FinancialAccount(Base):
    __tablename__ = "financial_accounts"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    clinic_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("clinics.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    type: Mapped[str] = mapped_column(String(30), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    meta: Mapped[dict | None] = mapped_column("metadata", JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=datetime.utcnow)


class FinancialTransaction(Base):
    __tablename__ = "financial_transactions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    clinic_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("clinics.id"), nullable=False, index=True)
    patient_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("patients.id"), nullable=True, index=True)
    guardian_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("guardians.id"), nullable=True, index=True)
    description: Mapped[str] = mapped_column(String(255), nullable=False)
    amount: Mapped[float] = mapped_column(Float, nullable=False)
    status: Mapped[str] = mapped_column(String(30), nullable=False, default="pending", index=True)
    due_date: Mapped[datetime] = mapped_column(DateTime, nullable=False, index=True)
    paid_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    payment_method: Mapped[str] = mapped_column(String(30), nullable=False, default="pix")
    account_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("financial_accounts.id"),
        nullable=False,
        index=True,
    )
    external_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=datetime.utcnow)

    patient = relationship("Patient", foreign_keys=[patient_id])
    guardian = relationship("Guardian", foreign_keys=[guardian_id])
    account = relationship("FinancialAccount", foreign_keys=[account_id])
