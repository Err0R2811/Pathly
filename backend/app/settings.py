"""Runtime configuration for the Pathly API."""

from __future__ import annotations

import os
from dataclasses import dataclass
from functools import lru_cache


def _split_csv(value: str) -> tuple[str, ...]:
    return tuple(item.strip() for item in value.split(",") if item.strip())


@dataclass(frozen=True)
class Settings:
    """Environment-backed settings with production guardrails."""

    environment: str
    database_url: str
    jwt_secret_key: str
    jwt_algorithm: str
    cors_origins: tuple[str, ...]
    auto_create_tables: bool

    @property
    def is_production(self) -> bool:
        return self.environment in {"production", "prod"}

    def validate(self) -> None:
        if self.is_production:
            if not self.jwt_secret_key or len(self.jwt_secret_key) < 32:
                raise RuntimeError("JWT_SECRET_KEY must be set to at least 32 characters in production.")
            if self.database_url.startswith("sqlite"):
                raise RuntimeError(
                    "DATABASE_URL must point to PostgreSQL or another production database in production."
                )
            if not self.cors_origins:
                raise RuntimeError("CORS_ORIGINS must be set in production.")


@lru_cache
def get_settings() -> Settings:
    environment = os.getenv("ENVIRONMENT", "development").strip().lower()
    is_production = environment in {"production", "prod"}
    database_url = os.getenv("DATABASE_URL", "sqlite:///./pathly.db")
    dev_secret = "dev-only-pathly-secret-change-me-before-deploy"
    jwt_secret_key = os.getenv("JWT_SECRET_KEY", "" if is_production else dev_secret)
    cors_origins = _split_csv(
        os.getenv(
            "CORS_ORIGINS",
            "" if is_production else "http://localhost:3000,http://localhost:5173,http://127.0.0.1:8000",
        )
    )
    auto_create_tables = os.getenv("AUTO_CREATE_TABLES", "true" if not is_production else "false").lower() == "true"

    settings = Settings(
        environment=environment,
        database_url=database_url,
        jwt_secret_key=jwt_secret_key,
        jwt_algorithm=os.getenv("JWT_ALGORITHM", "HS256"),
        cors_origins=cors_origins,
        auto_create_tables=auto_create_tables,
    )
    settings.validate()
    return settings
