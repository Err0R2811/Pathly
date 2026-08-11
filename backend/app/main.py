"""FastAPI application entrypoint."""

import asyncio

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from slowapi.util import get_remote_address
from sqlalchemy import text

from .database import SessionLocal, engine
from .models import Base
from .routers import adaptive, ai, auth, badges, curriculum, leaderboard, lessons, progress, search
from .services.leaderboard import get_redis_client
from .settings import get_settings

settings = get_settings()

if settings.auto_create_tables:
    Base.metadata.create_all(bind=engine)

limiter = Limiter(key_func=get_remote_address, default_limits=["1000/minute"])

app = FastAPI(
    title="Pathly Curriculum API",
    version="0.2.0",
    description="AI-powered curriculum generation with Ollama",
)
app.state.limiter = limiter

app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)

app.add_middleware(
    CORSMiddleware,
    allow_origins=list(settings.cors_origins),
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)

app.include_router(curriculum.router)
app.include_router(auth.router)
app.include_router(progress.router)
app.include_router(badges.router)
app.include_router(leaderboard.router)
app.include_router(search.router)
app.include_router(ai.router)
app.include_router(adaptive.router)
app.include_router(lessons.router)


def _check_database() -> bool:
    try:
        with SessionLocal() as db:
            db.execute(text("SELECT 1"))
            return True
    except Exception:
        return False


def _check_redis() -> bool:
    client = get_redis_client()
    if not client:
        return False
    try:
        client.ping()
        return True
    except Exception:
        return False


@app.get("/health")
async def health_check():
    db_ok, redis_ok = await asyncio.gather(
        asyncio.to_thread(_check_database),
        asyncio.to_thread(_check_redis),
    )
    status = "ok" if db_ok else "degraded"
    return {
        "status": status,
        "version": app.version,
        "database": db_ok,
        "redis": redis_ok,
    }
