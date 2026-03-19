from fastapi import APIRouter

from app.api.routes.auth import router as auth_router
from app.api.routes.patients import router as patients_router
from app.api.routes.anamneses import router as anamneses_router
from app.api.routes.evaluations import router as evaluations_router
from app.api.routes.validations import router as validations_router
from app.api.routes.evolutions import router as evolutions_router
from app.api.routes.dashboard import router as dashboard_router
from app.api.routes.guardians import router as guardians_router
from app.api.routes.appointments import router as appointments_router
from app.api.routes.users import router as users_router

api_router = APIRouter()
api_router.include_router(auth_router)
api_router.include_router(patients_router)
api_router.include_router(anamneses_router)
api_router.include_router(evaluations_router)
api_router.include_router(validations_router)
api_router.include_router(evolutions_router)
api_router.include_router(dashboard_router)
api_router.include_router(guardians_router)
api_router.include_router(appointments_router)
api_router.include_router(users_router)
