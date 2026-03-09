"""In-memory job store for async curriculum generation jobs.

Each job has: status (PENDING|RUNNING|COMPLETED|FAILED), progress (0-100),
an optional roadmap_id once completed, and an optional error message.
"""
from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
import threading

@dataclass
class JobState:
    job_id: str
    status: str = "PENDING"  # PENDING | RUNNING | COMPLETED | FAILED
    progress: int = 0
    roadmap_id: Optional[str] = None
    error: Optional[str] = None


class JobStore:
    def __init__(self) -> None:
        self._store: dict[str, JobState] = {}
        self._lock = threading.Lock()

    def create(self, job_id: str) -> JobState:
        state = JobState(job_id=job_id)
        with self._lock:
            self._store[job_id] = state
        return state

    def get(self, job_id: str) -> Optional[JobState]:
        with self._lock:
            return self._store.get(job_id)

    def update(self, job_id: str, **kwargs) -> None:
        with self._lock:
            state = self._store.get(job_id)
            if state:
                for k, v in kwargs.items():
                    setattr(state, k, v)


# Singleton used across the application
job_store = JobStore()
