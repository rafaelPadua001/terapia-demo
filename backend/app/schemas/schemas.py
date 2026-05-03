from __future__ import annotations

import uuid
import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator


class ClinicBase(BaseModel):
    name: str
    logo_url: str | None = None
    subdomain: str | None = None


class ClinicCreate(ClinicBase):
    pass


class ClinicOut(ClinicBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    created_at: datetime.datetime


class ClinicBrandingOut(BaseModel):
    name: str
    logo_url: str | None = None
    subdomain: str | None = None


class UserBase(BaseModel):
    name: str
    email: EmailStr
    role: str


class UserCreate(UserBase):
    password: str = Field(min_length=8)
    clinic_id: uuid.UUID


class UserOut(UserBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    clinic_id: uuid.UUID
    phone: str | None = None
    specialty: str | None = None
    cpf: str | None = None
    registration_type: str | None = None
    professional_registration: str | None = None
    email_is_confirmed: bool = False
    first_login: bool = True
    has_seen_tutorial: bool = False
    patient_id: uuid.UUID | None = None
    guardian_id: uuid.UUID | None = None
    created_at: datetime.datetime
    deleted_at: datetime.datetime | None = None


class TherapistCreate(BaseModel):
    name: str
    email: EmailStr
    cpf: str
    phone: str | None = None
    specialty: str | None = None
    registration_type: str | None = None
    professional_registration: str | None = None
    password: str | None = None


class TherapistOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    clinic_id: uuid.UUID
    name: str
    email: EmailStr
    phone: str | None = None
    specialty: str | None = None
    cpf: str | None = None
    registration_type: str | None = None
    professional_registration: str | None = None
    role: str
    created_at: datetime.datetime


class TherapistUpdate(BaseModel):
    name: str | None = None
    email: EmailStr | None = None
    cpf: str | None = None
    phone: str | None = None
    specialty: str | None = None
    registration_type: str | None = None
    professional_registration: str | None = None
    password: str | None = None


class GuardianBase(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    name: str
    phone: str | None = None
    email: EmailStr | None = None
    relationship_type: str | None = Field(default=None, alias="relationship")


class GuardianCreate(GuardianBase):
    patient_id: uuid.UUID | None = None
    patient_ids: list[uuid.UUID] = Field(default_factory=list)
    password: str | None = None


class GuardianOut(GuardianBase):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

    id: uuid.UUID
    clinic_id: uuid.UUID
    patient_id: uuid.UUID | None = None
    patient_ids: list[uuid.UUID] = Field(default_factory=list)
    deleted_at: datetime.datetime | None = None


class PatientBase(BaseModel):
    name: str
    birth_date: datetime.date
    diagnosis: str | None = None
    notes: str | None = None
    cpf: str | None = None
    email: EmailStr | None = None
    phone: str | None = None


class PatientCreate(PatientBase):
    password: str | None = None
    guardians: list[GuardianCreate] = Field(default_factory=list)
    guardian_ids: list[uuid.UUID] = Field(default_factory=list)
    new_guardian: GuardianCreate | None = None


class PatientUpdate(BaseModel):
    name: str | None = None
    birth_date: datetime.date | None = None
    diagnosis: str | None = None
    notes: str | None = None
    cpf: str | None = None
    email: EmailStr | None = None
    phone: str | None = None
    password: str | None = None
    guardian_ids: list[uuid.UUID] | None = None
    new_guardian: GuardianCreate | None = None


class PatientOut(PatientBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    clinic_id: uuid.UUID
    created_by: uuid.UUID
    updated_by: uuid.UUID | None = None
    patient_code: str
    created_at: datetime.datetime
    updated_at: datetime.datetime | None = None
    deleted_at: datetime.datetime | None = None
    guardians: list[GuardianOut] = []


class PatientSearchOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    name: str
    patient_code: str
    cpf: str | None = None
    birth_date: datetime.date
    email: EmailStr | None = None
    email_confirmed: bool | None = None
    phone: str | None = None


class AnamneseBase(BaseModel):
    data: dict

    @field_validator("data")
    @classmethod
    def validate_structure(cls, value: dict) -> dict:
        if "sections" not in value or not isinstance(value["sections"], list):
            raise ValueError("Invalid structure: missing sections list")
        for section in value["sections"]:
            if "title" not in section or "fields" not in section:
                raise ValueError("Each section needs title and fields")
            if not isinstance(section["fields"], list):
                raise ValueError("fields must be a list")
            for field in section["fields"]:
                if "type" not in field or "label" not in field:
                    raise ValueError("Each field needs type and label")
                if field["type"] not in {"text", "textarea", "select"}:
                    raise ValueError("Unsupported field type")
        return value


class AnamneseCreate(AnamneseBase):
    patient_id: uuid.UUID


class AnamneseUpdate(BaseModel):
    data: dict


class AnamneseOut(AnamneseBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    clinic_id: uuid.UUID
    patient_id: uuid.UUID
    patient: PatientSearchOut | None = None
    created_by: uuid.UUID
    updated_by: uuid.UUID | None = None
    created_at: datetime.datetime
    updated_at: datetime.datetime | None = None
    deleted_at: datetime.datetime | None = None


class EvaluationBase(BaseModel):
    type: str
    result: dict | str


class EvaluationCreate(EvaluationBase):
    patient_id: uuid.UUID


class EvaluationUpdate(BaseModel):
    type: str | None = None
    result: dict | str | None = None
    status: str | None = None


class EvaluationValidateRequest(BaseModel):
    status: str
    notes: str | None = None


class EvaluationOut(EvaluationBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    clinic_id: uuid.UUID
    patient_id: uuid.UUID
    patient: PatientSearchOut | None = None
    status: str
    created_by: uuid.UUID
    updated_by: uuid.UUID | None = None
    created_at: datetime.datetime
    updated_at: datetime.datetime | None = None
    deleted_at: datetime.datetime | None = None


class ValidationBase(BaseModel):
    status: str
    notes: str | None = None


class ValidationCreate(ValidationBase):
    evaluation_id: uuid.UUID


class ValidationUpdate(BaseModel):
    status: str
    notes: str | None = None


class ValidationOut(ValidationBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    clinic_id: uuid.UUID
    evaluation_id: uuid.UUID
    evaluation: EvaluationOut | None = None
    validated_by: uuid.UUID
    created_at: datetime.datetime
    deleted_at: datetime.datetime | None = None


class EvolutionBase(BaseModel):
    description: dict | str


class EvolutionCreate(EvolutionBase):
    patient_id: uuid.UUID


class EvolutionUpdate(BaseModel):
    description: dict | str | None = None


class EvolutionOut(EvolutionBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    clinic_id: uuid.UUID
    patient_id: uuid.UUID
    patient: PatientSearchOut | None = None
    created_by: uuid.UUID
    updated_by: uuid.UUID | None = None
    created_at: datetime.datetime
    updated_at: datetime.datetime | None = None
    deleted_at: datetime.datetime | None = None


class DashboardOut(BaseModel):
    total_patients: int
    evaluations_pending: int
    evaluations_approved: int
    last_evolutions: list[dict[str, Any]]


class PatientsPage(BaseModel):
    items: list[PatientOut]
    total: int
    page: int
    limit: int


class AnamnesesPage(BaseModel):
    items: list[AnamneseOut]
    total: int
    page: int
    limit: int


class EvaluationsPage(BaseModel):
    items: list[EvaluationOut]
    total: int
    page: int
    limit: int


class EvolutionsPage(BaseModel):
    items: list[EvolutionOut]
    total: int
    page: int
    limit: int


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    first_login: bool = False
    has_seen_tutorial: bool = False


class TokenPayload(BaseModel):
    sub: str
    clinic_id: uuid.UUID
    role: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    role: str | None = None


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class GenericMessageOut(BaseModel):
    message: str


class ResetTokenValidationOut(BaseModel):
    valid: bool


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str = Field(min_length=8)


class ChangePasswordRequest(BaseModel):
    new_password: str = Field(min_length=8)


class GuardianUpdate(BaseModel):
    name: str | None = None
    phone: str | None = None
    email: EmailStr | None = None
    relationship_type: str | None = Field(default=None, alias="relationship")
    patient_id: uuid.UUID | None = None
    patient_ids: list[uuid.UUID] | None = None
    password: str | None = None


class AppointmentBase(BaseModel):
    patient_id: uuid.UUID
    therapist_id: uuid.UUID
    date: datetime.date | None = None
    time: datetime.time | None = None
    type: str | None = None
    is_first_visit: bool = False
    is_confirmed: bool = False
    scheduled_at: datetime.datetime | None = None
    status: str = "scheduled"
    notes: dict | str | None = None



class AppointmentCreate(AppointmentBase):
    pass


class AppointmentUpdate(BaseModel):
    patient_id: uuid.UUID | None = None
    therapist_id: uuid.UUID | None = None
    date: datetime.date | None = None
    time: datetime.time | None = None
    type: str | None = None
    is_first_visit: bool | None = None
    is_confirmed: bool | None = None
    scheduled_at: datetime.datetime | None = None
    status: str | None = None
    notes: dict | str | None = None


class AppointmentOut(AppointmentBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    clinic_id: uuid.UUID
    patient: PatientSearchOut | None = None
    created_by: uuid.UUID
    confirmed_by: uuid.UUID | None = None
    updated_by: uuid.UUID | None = None
    created_at: datetime.datetime
    confirmed_at: datetime.datetime | None = None
    updated_at: datetime.datetime | None = None
    deleted_at: datetime.datetime | None = None
    whatsapp_link: str | None = None


class AppointmentsPage(BaseModel):
    items: list[AppointmentOut]
    total: int
    page: int
    limit: int
