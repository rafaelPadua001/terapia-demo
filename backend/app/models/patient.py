import uuid
from datetime import datetime, date

from sqlalchemy import Date, DateTime, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base


class Patient(Base):
    __tablename__ = "patients"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    clinic_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("clinics.id"), nullable=False)
    created_by: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    updated_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    patient_code: Mapped[str] = mapped_column(String(20), unique=True, index=True, nullable=False)
    cpf: Mapped[str | None] = mapped_column(String(11), unique=True, index=True, nullable=True)
    email: Mapped[str | None] = mapped_column(String(255), nullable=True)
    phone: Mapped[str | None] = mapped_column(String(20), nullable=True)
    birth_date: Mapped[date] = mapped_column(Date, nullable=False)
    diagnosis: Mapped[str | None] = mapped_column(String(255))
    notes: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    clinic = relationship("Clinic", back_populates="patients")
    guardian_links = relationship(
        "GuardianPatient",
        back_populates="patient",
        cascade="all, delete-orphan",
        overlaps="patients,guardians",
    )
    guardians = relationship(
        "Guardian",
        secondary="patient_guardians",
        back_populates="patients",
        overlaps="guardian_links,patient_links,guardian,patient",
    )
    anamneses = relationship("Anamnese", back_populates="patient")
    evaluations = relationship("Evaluation", back_populates="patient")
    evolutions = relationship("Evolution", back_populates="patient")
    appointments = relationship("Appointment", back_populates="patient")
