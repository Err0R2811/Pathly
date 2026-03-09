"""FastAPI application entrypoint."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import engine
from .models import Base
from .routers import preview
from .routers import curriculum

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

app.include_router(preview.router)
app.include_router(curriculum.router)


@app.get("/health")
async def health_check():
    return {"status": "ok", "version": app.version}
