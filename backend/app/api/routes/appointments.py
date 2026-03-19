from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models import Appointment
from app.schemas.schemas import AppointmentCreate, AppointmentOut, AppointmentUpdate, AppointmentsPage
from app.services.appointment_service import (
    build_whatsapp_link_for_appointment,
    confirm_appointment as confirm_appointment_service,
    create_appointment,
    list_appointments,
    soft_delete_appointment,
    update_appointment,
)

router = APIRouter(prefix="/appointments", tags=["appointments"])


@router.post(
    "",
    response_model=AppointmentOut,
    dependencies=[Depends(require_role("admin", "therapist", "receptionist"))],
)
def create(data: AppointmentCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    appointment, whatsapp_link = create_appointment(db, clinic_id=user.clinic_id, user=user, appointment_in=data)
    payload = AppointmentOut.model_validate(appointment).model_dump()
    payload["whatsapp_link"] = whatsapp_link
    return payload


@router.get(
    "",
    response_model=AppointmentsPage,
    dependencies=[Depends(require_role("admin", "therapist", "receptionist", "patient", "guardian"))],
)
def list_all(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    patient_id: str | None = None,
    therapist_id: str | None = None,
    status: str | None = None,
    show_deleted: bool = False,
):
    items, total = list_appointments(
        db,
        user,
        page,
        limit,
        patient_id=patient_id,
        therapist_id=therapist_id,
        status=status,
        show_deleted=show_deleted,
    )
    payload = []
    for item in items:
        serialized = AppointmentOut.model_validate(item).model_dump()
        serialized["whatsapp_link"] = build_whatsapp_link_for_appointment(db, user.clinic_id, item)
        payload.append(serialized)
    return AppointmentsPage(items=payload, total=total, page=page, limit=limit)


@router.put("/{appointment_id}", response_model=AppointmentOut, dependencies=[Depends(require_role("admin", "therapist", "receptionist"))])
def update(appointment_id: str, data: AppointmentUpdate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        return update_appointment(db, clinic_id=user.clinic_id, appointment_id=appointment_id, appointment_in=data, updated_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.delete("/{appointment_id}", status_code=status.HTTP_204_NO_CONTENT, dependencies=[Depends(require_role("admin", "therapist", "receptionist"))])
def delete(appointment_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        soft_delete_appointment(db, clinic_id=user.clinic_id, appointment_id=appointment_id, deleted_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/confirm/{appointment_id}")
def confirm_appointment_legacy(appointment_id: str, db: Session = Depends(get_db)):
    appointment = db.query(Appointment).filter(Appointment.id == appointment_id).first()
    if not appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
    appointment.status = "confirmed"
    appointment.is_confirmed = True
    if not appointment.confirmed_at:
        appointment.confirmed_at = appointment.updated_at or appointment.created_at
    db.commit()
    return {"message": "Consulta confirmada com sucesso"}


@router.patch(
    "/{appointment_id}/confirm",
    response_model=AppointmentOut,
    dependencies=[Depends(require_role("admin", "therapist", "receptionist"))],
)
def confirm_appointment_inline(appointment_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        appointment = confirm_appointment_service(
            db,
            clinic_id=user.clinic_id,
            appointment_id=appointment_id,
            confirmed_by=user.id,
        )
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))

    payload = AppointmentOut.model_validate(appointment).model_dump()
    payload["whatsapp_link"] = build_whatsapp_link_for_appointment(db, user.clinic_id, appointment)
    return payload
