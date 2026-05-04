import logging
import time

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.middleware.trustedhost import TrustedHostMiddleware
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.api.routes import api_router
from app.core.config import settings
from app.core.database import SessionLocal
from app.services.tenant_service import extract_subdomain, get_clinic_by_subdomain, get_default_clinic
import os

port = int(os.getenv("PORT", 8000))


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("app")

app = FastAPI(title=settings.app_name)

allowed_hosts = [
    "localhost",
    "127.0.0.1",
    "localhost.tiangolo.com",
    "*.localhost.tiangolo.com",
    "terapia-demo.onrender.com",
    "terapia-demo-1.onrender.com",
    "*.onrender.com",
]
tenant_base_domain = (settings.tenant_base_domain or "").strip().lower()
if tenant_base_domain:
    allowed_hosts.append(f"*.{tenant_base_domain}")

app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=allowed_hosts,
)

origins = [origin.strip() for origin in os.getenv("CORS_ORIGINS", "http://localhost:5173,https://terapia-demo.onrender.com,https://terapia-demo-1.onrender.com").split(",") if origin.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    request.state.tenant_subdomain = None
    request.state.tenant_clinic = None
    request.state.clinic = None
    subdomain = extract_subdomain(request.headers.get("host"))
    request.state.tenant_subdomain = subdomain
    db = SessionLocal()
    try:
        clinic = get_clinic_by_subdomain(db, subdomain) if subdomain else None
        if not clinic:
            clinic = get_default_clinic(db) if not settings.tenant_enforce_subdomain else None
        if not clinic and settings.tenant_enforce_subdomain:
            return JSONResponse(status_code=404, content={"error": "Clinica nao encontrada", "code": "TENANT_NOT_FOUND"})
        request.state.tenant_clinic = clinic
        request.state.clinic = clinic
    finally:
        db.close()

    start = time.time()
    response = await call_next(request)
    duration = (time.time() - start) * 1000
    logger.info(
        "request",
        extra={
            "method": request.method,
            "path": request.url.path,
            "status": response.status_code,
            "duration_ms": round(duration, 2),
        },
    )
    return response


@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    logger.warning("http_error", extra={"path": request.url.path, "status": exc.status_code})
    if isinstance(exc.detail, dict):
        payload = {"code": f"HTTP_{exc.status_code}", **exc.detail}
    else:
        payload = {"error": exc.detail, "code": f"HTTP_{exc.status_code}"}
    return JSONResponse(
        status_code=exc.status_code,
        content=payload,
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    logger.warning("validation_error", extra={"path": request.url.path})
    return JSONResponse(
        status_code=422,
        content={"error": "Validation error", "code": "VALIDATION_ERROR", "details": exc.errors()},
    )


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    logger.exception("unhandled_error", extra={"path": request.url.path})
    return JSONResponse(
        status_code=500,
        content={"error": "Internal server error", "code": "INTERNAL_ERROR"},
    )


app.include_router(api_router, prefix=settings.api_v1_prefix)


@app.get("/")
def health_check():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=port)
