"""FastAPI application entrypoint."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import engine
from .models import Base
from .routers import curriculum
from .routers import auth
from .routers import progress
from .routers import badges
from .routers import leaderboard
from .routers import search
from .routers import ai
from .routers import adaptive
from .routers import lessons

# Create all tables on startup (SQLite)
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Pathly Curriculum API",
    version="0.2.0",
    description="AI-powered curriculum generation with Ollama",
)

# Allow Flutter app (running on emulator or web) to call this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten in production
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
