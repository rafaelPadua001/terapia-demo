import os
import sys
from pathlib import Path

from sqlalchemy.orm import Session

sys.path.append(str(Path(__file__).resolve().parents[2]))

from app.core.database import SessionLocal
from app.models import Guardian, GuardianPatient, Patient, User
from app.schemas.schemas import ClinicCreate, UserCreate
from app.services.clinic_service import create_clinic_with_admin
from app.services.user_service import create_user


def run():
    clinic_name = os.getenv("SEED_CLINIC_NAME", "Clínica Demo")
    admin_name = os.getenv("SEED_ADMIN_NAME", "Admin")
    admin_email = os.getenv("SEED_ADMIN_EMAIL", "admin@clinic.com")
    admin_password = os.getenv("SEED_ADMIN_PASSWORD", "admin1234")

    db: Session = SessionLocal()
    try:
        existing_admin = db.query(User).filter(User.email == admin_email).first()
        if existing_admin:
            existing_admin.email_is_confirmed = True
            clinic_id = existing_admin.clinic_id
        else:
            clinic_in = ClinicCreate(name=clinic_name)
            admin_in = UserCreate(
                name=admin_name,
                email=admin_email,
                password=admin_password,
                role="admin",
                clinic_id="00000000-0000-0000-0000-000000000000",
            )
            clinic = create_clinic_with_admin(db, clinic_in, admin_in)
            clinic_id = clinic.id

        patient = db.query(Patient).filter(Patient.clinic_id == clinic_id, Patient.deleted_at.is_(None)).first()
        guardian = db.query(Guardian).filter(Guardian.clinic_id == clinic_id, Guardian.deleted_at.is_(None)).first()

        if patient:
            patient.email = patient.email or "paciente@demo.com"
            patient.phone = patient.phone or "11987654321"
        if guardian:
            guardian.email = guardian.email or "responsavel@demo.com"
            guardian.phone = guardian.phone or "11999887766"
        db.commit()

        if clinic_id:
            if not db.query(User).filter(User.email == "terapeuta@demo.com").first():
                create_user(
                    db,
                    name="Terapeuta Demo",
                    email="terapeuta@demo.com",
                    password="123456",
                    role="therapist",
                    clinic_id=clinic_id,
                    email_is_confirmed=True,
                )
            else:
                db.query(User).filter(User.email == "terapeuta@demo.com").update({"email_is_confirmed": True})

            if not db.query(User).filter(User.email == "recepcao@demo.com").first():
                create_user(
                    db,
                    name="Recepção Demo",
                    email="recepcao@demo.com",
                    password="123456",
                    role="receptionist",
                    clinic_id=clinic_id,
                    email_is_confirmed=True,
                )
            else:
                db.query(User).filter(User.email == "recepcao@demo.com").update({"email_is_confirmed": True})

            if patient and not db.query(User).filter(User.email == "paciente@demo.com").first():
                create_user(
                    db,
                    name=patient.name or "Paciente Demo",
                    email=patient.email or "paciente@demo.com",
                    password="Brasil2026",
                    role="patient",
                    clinic_id=clinic_id,
                    patient_id=patient.id,
                    email_is_confirmed=True,
                )
            elif patient:
                db.query(User).filter(User.email == "paciente@demo.com").update(
                    {"email_is_confirmed": True, "patient_id": patient.id}
                )
                db.query(User).filter(User.email == (patient.email or "paciente@demo.com")).update({"email_is_confirmed": True})

            if guardian and not db.query(User).filter(User.email == "responsavel@demo.com").first():
                create_user(
                    db,
                    name=guardian.name or "Responsável Demo",
                    email=guardian.email or "responsavel@demo.com",
                    password="Brasil2026",
                    role="guardian",
                    clinic_id=clinic_id,
                    guardian_id=guardian.id,
                    email_is_confirmed=True,
                )
            elif guardian:
                db.query(User).filter(User.email == "responsavel@demo.com").update(
                    {"email_is_confirmed": True, "guardian_id": guardian.id}
                )
                db.query(User).filter(User.email == (guardian.email or "responsavel@demo.com")).update({"email_is_confirmed": True})

            if guardian and patient:
                exists_link = (
                    db.query(GuardianPatient)
                    .filter(GuardianPatient.guardian_id == guardian.id, GuardianPatient.patient_id == patient.id)
                    .first()
                )
                if not exists_link:
                    db.add(GuardianPatient(guardian_id=guardian.id, patient_id=patient.id))
                    db.commit()

        db.commit()

        print("Seed created")
    finally:
        db.close()


if __name__ == "__main__":
    run()
