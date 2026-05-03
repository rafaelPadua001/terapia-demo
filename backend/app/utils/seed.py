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
    # =========================
    # ENV CONFIG
    # =========================
    clinic_name = os.getenv("SEED_CLINIC_NAME", "Clinica Demo")

    frontend_url = os.getenv("FRONTEND_URL", "http://localhost:5173")
    clinic_logo_url = os.getenv("SEED_CLINIC_LOGO_URL") or f"{frontend_url}/logo/default.png"

    clinic_subdomain = os.getenv("SEED_CLINIC_SUBDOMAIN", "demo")

    admin_name = os.getenv("SEED_ADMIN_NAME", "Admin")
    admin_email = os.getenv("SEED_ADMIN_EMAIL", "admin@clinic.com")
    admin_password = os.getenv("SEED_ADMIN_PASSWORD", "admin1234")

    db: Session = SessionLocal()

    try:
        # =========================
        # CLINIC + ADMIN (IDEMPOTENTE)
        # =========================
        clinic_in = ClinicCreate(
            name=clinic_name,
            logo_url=clinic_logo_url,
            subdomain=clinic_subdomain,
        )

        admin_in = UserCreate(
            name=admin_name,
            email=admin_email,
            password=admin_password,
            role="admin",
            clinic_id="00000000-0000-0000-0000-000000000000",
        )

        clinic = create_clinic_with_admin(db, clinic_in, admin_in)
        clinic_id = clinic.id

        # garante confirmação do admin
        db.query(User).filter(User.email == admin_email).update(
            {"email_is_confirmed": True}
        )

        # =========================
        # BASE DATA (PATIENT / GUARDIAN)
        # =========================
        patient = (
            db.query(Patient)
            .filter(Patient.clinic_id == clinic_id, Patient.deleted_at.is_(None))
            .first()
        )

        guardian = (
            db.query(Guardian)
            .filter(Guardian.clinic_id == clinic_id, Guardian.deleted_at.is_(None))
            .first()
        )

        if patient:
            patient.email = patient.email or "paciente@demo.com"
            patient.phone = patient.phone or "11987654321"

        if guardian:
            guardian.email = guardian.email or "responsavel@demo.com"
            guardian.phone = guardian.phone or "11999887766"

        db.flush()

        # =========================
        # USERS (IDEMPOTENTE)
        # =========================
        def ensure_user(email, **kwargs):
            user = db.query(User).filter(User.email == email).first()
            if not user:
                create_user(db, email=email, **kwargs)
            else:
                db.query(User).filter(User.email == email).update(
                    {"email_is_confirmed": True}
                )

        ensure_user(
            "terapeuta@demo.com",
            name="Terapeuta Demo",
            password="123456",
            role="therapist",
            clinic_id=clinic_id,
            email_is_confirmed=True,
        )

        ensure_user(
            "recepcao@demo.com",
            name="Recepção Demo",
            password="123456",
            role="receptionist",
            clinic_id=clinic_id,
            email_is_confirmed=True,
        )

        if patient:
            ensure_user(
                "paciente@demo.com",
                name=patient.name or "Paciente Demo",
                password="Brasil2026",
                role="patient",
                clinic_id=clinic_id,
                patient_id=patient.id,
                email_is_confirmed=True,
            )

            db.query(User).filter(User.email == "paciente@demo.com").update(
                {"patient_id": patient.id}
            )

        if guardian:
            ensure_user(
                "responsavel@demo.com",
                name=guardian.name or "Responsável Demo",
                password="Brasil2026",
                role="guardian",
                clinic_id=clinic_id,
                guardian_id=guardian.id,
                email_is_confirmed=True,
            )

            db.query(User).filter(User.email == "responsavel@demo.com").update(
                {"guardian_id": guardian.id}
            )

        # =========================
        # RELATIONSHIP
        # =========================
        if guardian and patient:
            exists_link = (
                db.query(GuardianPatient)
                .filter(
                    GuardianPatient.guardian_id == guardian.id,
                    GuardianPatient.patient_id == patient.id,
                )
                .first()
            )

            if not exists_link:
                db.add(
                    GuardianPatient(
                        guardian_id=guardian.id,
                        patient_id=patient.id,
                    )
                )

        # =========================
        # FINAL COMMIT
        # =========================
        db.commit()

        print("✅ Seed executed successfully")

    except Exception as e:
        db.rollback()
        print("❌ Seed failed:", str(e))
        raise
    finally:
        db.close()


if __name__ == "__main__":
    run()
