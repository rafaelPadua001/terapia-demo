import logging
import os
from pathlib import Path

from dotenv import dotenv_values
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR = Path(__file__).resolve().parents[2]
ENV_PATH = BASE_DIR / ".env"

logger = logging.getLogger("app.config")



def clean_env_key(key: str) -> str:
    return key.replace("\ufeff", "")


_original_environ = dict(os.environ)
os.environ.clear()
os.environ.update({clean_env_key(k): v for k, v in _original_environ.items()})



def load_env_file() -> dict:
    if not ENV_PATH.exists():
        return {}

    values = dotenv_values(ENV_PATH, interpolate=False, encoding="utf-8-sig")
    return {clean_env_key(k): v for k, v in values.items() if k and v is not None}


class Settings(BaseSettings):
    app_name: str = "Clinics SaaS"
    api_v1_prefix: str = "/api"
    secret_key: str = Field(alias="SECRET_KEY")
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 24
    frontend_url: str = Field(default="http://localhost:5173", alias="FRONTEND_URL")
    clinic_email: str | None = Field(default=None, alias="CLINIC_EMAIL")
    clinic_email_password: str | None = Field(default=None, alias="CLINIC_EMAIL_PASSWORD")
    smtp_host: str | None = Field(default="smtp.gmail.com", alias="SMTP_HOST")
    smtp_port: int = Field(default=587, alias="SMTP_PORT")
    smtp_username: str | None = Field(default=None, alias="SMTP_USERNAME")
    smtp_password: str | None = Field(default=None, alias="SMTP_PASSWORD")
    smtp_from_email: str | None = Field(default=None, alias="SMTP_FROM_EMAIL")
    smtp_use_tls: bool = Field(default=True, alias="SMTP_USE_TLS")
    database_url: str = Field(alias="DATABASE_URL")

    model_config = SettingsConfigDict(
        env_file=str(ENV_PATH),
        env_file_encoding="utf-8-sig",
        case_sensitive=False,
        extra="ignore",
        populate_by_name=True,
    )

    @classmethod
    def settings_customise_sources(
        cls,
        settings_cls,
        init_settings,
        env_settings,
        dotenv_settings,
        file_secret_settings,
    ):
        return (init_settings, load_env_file, dotenv_settings, env_settings, file_secret_settings)

    @field_validator("secret_key", "database_url")
    @classmethod
    def validate_required(cls, value: str, info):
        if not value:
            raise ValueError(f"Missing required setting: {info.field_name}")
        return value

    @field_validator("database_url")
    @classmethod
    def validate_database_url(cls, value: str):
        if not value.startswith("postgresql+psycopg2://"):
            raise ValueError(
                "DATABASE_URL invalida. Use: postgresql+psycopg2://user:pass@localhost:5432/db"
            )
        return value


settings = Settings()
print("DATABASE_URL:", settings.database_url[:20])
