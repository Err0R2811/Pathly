"""FastAPI application entrypoint."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import engine
from .models import Base
from .routers import adaptive, ai, auth, badges, curriculum, leaderboard, lessons, progress, search
from .settings import get_settings

settings = get_settings()

if settings.auto_create_tables:
    Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Pathly Curriculum API",
    version="0.2.0",
    description="AI-powered curriculum generation with Ollama",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=list(settings.cors_origins),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
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


@app.get("/health")
async def health_check():
    return {"status": "ok", "version": app.version}
