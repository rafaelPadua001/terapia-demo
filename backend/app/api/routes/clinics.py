from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models import Clinic
from app.schemas.schemas import ClinicBrandingOut

router = APIRouter(prefix="/clinics", tags=["clinics"])


@router.get("/current", response_model=ClinicBrandingOut)
def get_current_clinic(request: Request, db: Session = Depends(get_db)):
    tenant_clinic = getattr(request.state, "tenant_clinic", None)
    if tenant_clinic:
        return {"name": tenant_clinic.name, "logo_url": tenant_clinic.logo_url, "subdomain": tenant_clinic.subdomain}

    fallback = db.query(Clinic).order_by(Clinic.created_at.asc()).first()
    if fallback:
        return {"name": fallback.name, "logo_url": fallback.logo_url, "subdomain": fallback.subdomain}
    return {"name": "Minha Clinica", "logo_url": None, "subdomain": None}
