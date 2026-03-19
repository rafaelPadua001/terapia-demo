import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base


class Guardian(Base):
    __tablename__ = "guardians"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    clinic_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("clinics.id"), nullable=False)

    name: Mapped[str] = mapped_column(String(255), nullable=False)
    phone: Mapped[str | None] = mapped_column(String(50))

    relationship_type: Mapped[str | None] = mapped_column(String(100))

    email: Mapped[str | None] = mapped_column(String(255))
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    patient_links = relationship(
        "GuardianPatient",
        back_populates="guardian",
        cascade="all, delete-orphan",
        overlaps="patients,guardians",
    )
    patients = relationship(
        "Patient",
        secondary="patient_guardians",
        back_populates="guardians",
        overlaps="patient_links,guardian_links,guardian,patient",
    )

    @property
    def patient_id(self):
        return self.patients[0].id if self.patients else None

    @property
    def patient_ids(self):
        return [patient.id for patient in self.patients]
