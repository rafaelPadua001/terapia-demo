from datetime import datetime
import urllib.parse

from sqlalchemy.orm import Session, joinedload

from app.models import Appointment, Guardian, GuardianPatient, Patient, User
from app.schemas.schemas import AppointmentCreate, AppointmentUpdate
from app.services.audit_service import log_action
from app.services.notification_service import send_whatsapp_message
from app.services.patient_service import _normalize_phone
from app.services.rbac_service import apply_role_filter


def _safe_send(phone: str, message: str) -> None:
    try:
        send_whatsapp_message(phone, message)
    except Exception as exc:
        print(f"Failed to send WhatsApp to {phone}: {exc}")


def _build_scheduled_at(date_value, time_value, scheduled_at):
    if scheduled_at:
        return scheduled_at, scheduled_at.date(), scheduled_at.time()
    if date_value and time_value:
        combined = datetime.combine(date_value, time_value)
        return combined, date_value, time_value
    raise ValueError("Appointment must include scheduled_at or date/time")


def get_patient_phone(db: Session, patient_id):
    patient = db.query(Patient).filter(Patient.id == patient_id).first()
    return patient.phone if patient else None


def _normalize_whatsapp_phone(phone: str | None) -> str | None:
    digits = _normalize_phone(phone)
    if not digits:
        return None
    if digits.startswith("55") and len(digits) >= 12:
        return digits
    if len(digits) in {10, 11}:
        return f"55{digits}"
    return digits


def build_whatsapp_message(appointment: Appointment, patient: Patient | None, therapist: User | None) -> str:
    patient_name = patient.name if patient else "Paciente"
    therapist_name = therapist.name if therapist else "Profissional"
    date_value = appointment.date or appointment.scheduled_at.date()
    time_value = appointment.time or appointment.scheduled_at.time()
    date_text = date_value.strftime("%d/%m/%Y")
    time_text = time_value.strftime("%H:%M")
    return (
        "Olá! Seu agendamento foi confirmado.\n\n"
        f"Paciente: {patient_name}\n"
        f"Data: {date_text}\n"
        f"Hora: {time_text}\n"
        f"Profissional: {therapist_name}\n"
        f"Atendimento: {appointment.type or '-'}\n\n"
        "Em caso de dúvidas, entre em contato."
    )


def generate_whatsapp_link(phone: str, message: str) -> str:
    encoded = urllib.parse.quote(message, safe="")
    normalized_phone = _normalize_whatsapp_phone(phone)
    return f"https://wa.me/{normalized_phone}?text={encoded}"


def build_whatsapp_link_for_appointment(db: Session, clinic_id, appointment: Appointment) -> str | None:
    patient = appointment.patient
    if not patient:
        patient = (
            db.query(Patient)
            .filter(Patient.id == appointment.patient_id, Patient.clinic_id == clinic_id, Patient.deleted_at.is_(None))
            .first()
        )
    if not patient:
        return None

    patient_phone = _normalize_whatsapp_phone(patient.phone)
    if not patient_phone:
        return None

    therapist = db.query(User).filter(User.id == appointment.therapist_id).first()
    message = build_whatsapp_message(appointment, patient, therapist)
    return generate_whatsapp_link(patient_phone, message)


def create_appointment(db: Session, clinic_id, user, appointment_in: AppointmentCreate) -> tuple[Appointment, str | None]:
    if user.role == "patient" and user.patient_id != appointment_in.patient_id:
        raise ValueError("Forbidden")
    if user.role == "guardian":
        if not user.guardian_id:
            raise ValueError("Forbidden")
        link = (
            db.query(GuardianPatient)
            .filter(
                GuardianPatient.guardian_id == user.guardian_id,
                GuardianPatient.patient_id == appointment_in.patient_id,
            )
            .first()
        )
        if not link:
            raise ValueError("Forbidden")

    scheduled_at, date_value, time_value = _build_scheduled_at(
        appointment_in.date,
        appointment_in.time,
        appointment_in.scheduled_at,
    )

    appointment = Appointment(
        clinic_id=clinic_id,
        patient_id=appointment_in.patient_id,
        therapist_id=appointment_in.therapist_id,
        date=date_value,
        time=time_value,
        type=appointment_in.type,
        is_first_visit=bool(appointment_in.is_first_visit),
        is_confirmed=False,
        scheduled_at=scheduled_at,
        status=appointment_in.status or "scheduled",
        notes=appointment_in.notes,
        created_by=user.id,
    )
    db.add(appointment)
    db.commit()
    db.refresh(appointment)
    log_action(db, clinic_id=clinic_id, user_id=user.id, action="create", entity="appointment", entity_id=appointment.id)

    patient = (
        db.query(Patient)
        .filter(Patient.id == appointment.patient_id, Patient.clinic_id == clinic_id, Patient.deleted_at.is_(None))
        .first()
    )
    therapist = db.query(User).filter(User.id == appointment.therapist_id).first()

    whatsapp_link = None
    if patient:
        message = build_whatsapp_message(appointment, patient, therapist)
        phones_to_notify = []
        patient_phone = _normalize_whatsapp_phone(patient.phone)
        if patient_phone:
            whatsapp_link = generate_whatsapp_link(patient_phone, message)
            phones_to_notify.append(patient_phone)

        guardians = (
            db.query(Guardian)
            .join(GuardianPatient, GuardianPatient.guardian_id == Guardian.id)
            .filter(
                GuardianPatient.patient_id == patient.id,
                Guardian.clinic_id == clinic_id,
                Guardian.deleted_at.is_(None),
            )
            .distinct()
            .all()
        )
        for guardian in guardians:
            guardian_phone = _normalize_whatsapp_phone(guardian.phone)
            if guardian_phone:
                phones_to_notify.append(guardian_phone)

        for phone in sorted(set(phones_to_notify)):
            _safe_send(phone, message)

    return appointment, whatsapp_link


def confirm_appointment(db: Session, clinic_id, appointment_id, confirmed_by) -> Appointment:
    appointment = (
        db.query(Appointment)
        .filter(Appointment.id == appointment_id, Appointment.clinic_id == clinic_id, Appointment.deleted_at.is_(None))
        .first()
    )
    if not appointment:
        raise ValueError("Appointment not found")
    if appointment.is_confirmed:
        return appointment

    appointment.is_confirmed = True
    appointment.confirmed_at = datetime.utcnow()
    appointment.confirmed_by = confirmed_by
    appointment.updated_by = confirmed_by
    appointment.updated_at = appointment.confirmed_at
    db.commit()
    db.refresh(appointment)
    log_action(
        db,
        clinic_id=clinic_id,
        user_id=confirmed_by,
        action="confirm",
        entity="appointment",
        entity_id=appointment.id,
    )
    return appointment


def update_appointment(db: Session, clinic_id, appointment_id, appointment_in: AppointmentUpdate, updated_by) -> Appointment:
    appointment = (
        db.query(Appointment)
        .filter(Appointment.id == appointment_id, Appointment.clinic_id == clinic_id, Appointment.deleted_at.is_(None))
        .first()
    )

    if not appointment:
        raise ValueError("Appointment not found")

    payload = appointment_in.model_dump(exclude_unset=True)
    date_value = payload.get("date", appointment.date)
    time_value = payload.get("time", appointment.time)
    scheduled_at = payload.get("scheduled_at")
    if scheduled_at or ("date" in payload or "time" in payload):
        scheduled_at, date_value, time_value = _build_scheduled_at(date_value, time_value, scheduled_at)
        payload["scheduled_at"] = scheduled_at
        payload["date"] = date_value
        payload["time"] = time_value

    for field, value in payload.items():
        setattr(appointment, field, value)

    appointment.updated_by = updated_by
    appointment.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(appointment)
    log_action(db, clinic_id=clinic_id, user_id=updated_by, action="update", entity="appointment", entity_id=appointment.id)
    return appointment


def soft_delete_appointment(db: Session, clinic_id, appointment_id, deleted_by) -> None:
    appointment = (
        db.query(Appointment)
        .filter(Appointment.id == appointment_id, Appointment.clinic_id == clinic_id, Appointment.deleted_at.is_(None))
        .first()
    )

    if not appointment:
        raise ValueError("Appointment not found")
    appointment.deleted_at = datetime.utcnow()
    appointment.updated_by = deleted_by
    appointment.updated_at = datetime.utcnow()
    db.commit()
    log_action(db, clinic_id=clinic_id, user_id=deleted_by, action="delete", entity="appointment", entity_id=appointment.id)


def list_appointments(
    db: Session,
    user,
    page: int,
    limit: int,
    patient_id: str | None = None,
    therapist_id: str | None = None,
    status: str | None = None,
    show_deleted: bool = False,
):
    query = (
        db.query(Appointment)
        .options(joinedload(Appointment.patient))
        .filter(Appointment.clinic_id == user.clinic_id)
    )
    if not show_deleted:
        query = query.filter(Appointment.deleted_at.is_(None))
    if patient_id:
        query = query.filter(Appointment.patient_id == patient_id)
    if therapist_id:
        query = query.filter(Appointment.therapist_id == therapist_id)
    if status:
        query = query.filter(Appointment.status == status)
    query = apply_role_filter(query, user, Appointment)
    total = query.count()
    items = query.order_by(Appointment.created_at.desc()).offset((page - 1) * limit).limit(limit).all()
    return items, total
