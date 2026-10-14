"""Semantic search service — Qdrant-based vector search over roadmaps/modules."""

from __future__ import annotations

import os
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from qdrant_client import QdrantClient
    from sentence_transformers import SentenceTransformer

# Configuration
QDRANT_HOST = os.getenv("QDRANT_HOST", "localhost")
QDRANT_PORT = int(os.getenv("QDRANT_PORT", 6333))
COLLECTION_NAME = "pathly_content"

# Embedding model (lightweight, fast)
MODEL_NAME = "all-MiniLM-L6-v2"

# Global variables (lazy initialization) — types are strings to avoid eager import
_model: "SentenceTransformer | None" = None
_qdrant_client: "QdrantClient | None" = None


def get_embedding_model() -> "SentenceTransformer":
    """Get or initialize the sentence transformer model (lazy import)."""
    global _model
    if _model is None:
        try:
            from sentence_transformers import SentenceTransformer  # noqa: PLC0415
            _model = SentenceTransformer(MODEL_NAME)
        except Exception:
            return None  # type: ignore[return-value]
    return _model


def get_qdrant_client() -> "QdrantClient | None":
    """Get or initialize the Qdrant client (lazy import)."""
    global _qdrant_client
    if _qdrant_client is None:
        try:
            from qdrant_client import QdrantClient  # noqa: PLC0415
            _qdrant_client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)
            # Ensure collection exists
            _ensure_collection()
        except Exception:
            # Return None if Qdrant is not available (graceful degradation)
            _qdrant_client = None
    return _qdrant_client


def _ensure_collection() -> None:
    """Ensure the Qdrant collection exists."""
    client = get_qdrant_client()
    if not client:
        return

    try:
        collections = client.get_collections().collections
        collection_names = [c.name for c in collections]

        if COLLECTION_NAME not in collection_names:
            from qdrant_client.models import Distance, VectorParams  # noqa: PLC0415
            client.create_collection(
                collection_name=COLLECTION_NAME,
                vectors_config=VectorParams(size=384, distance=Distance.COSINE),
            )
    except Exception:
        pass


def embed_text(text: str) -> list[float]:
    """Convert text to embedding vector."""
    model = get_embedding_model()
    if model is None:
        return []
    embedding = model.encode(text, convert_to_numpy=True)
    return embedding.tolist()


def index_roadmap(roadmap_id: str, skill_name: str, modules: list[dict]) -> None:
    """Index a roadmap and its modules for semantic search."""
    client = get_qdrant_client()
    if not client:
        return

    model = get_embedding_model()
    if model is None:
        return

    try:
        from qdrant_client.models import PointStruct  # noqa: PLC0415
    except Exception:
        return

    points = []

    # Index the roadmap itself
    roadmap_text = f"{skill_name} " + " ".join(
        [f"{m.get('module_name', '')} {' '.join(m.get('learning_objectives', []))}" for m in modules]
    )
    roadmap_embedding = model.encode(roadmap_text, convert_to_numpy=True).tolist()

    points.append(
        PointStruct(
            id=roadmap_id,
            vector=roadmap_embedding,
            payload={
                "type": "roadmap",
                "roadmap_id": roadmap_id,
                "skill_name": skill_name,
                "text": roadmap_text,
            },
        )
    )

    # Index each module
    for module in modules:
        module_id = module.get("id")
        module_text = (
            f"{module.get('module_name', '')} "
            f"{' '.join(module.get('learning_objectives', []))} "
            f"{' '.join(module.get('skills_gained', []))}"
        )
        module_embedding = model.encode(module_text, convert_to_numpy=True).tolist()

        points.append(
            PointStruct(
                id=module_id,
                vector=module_embedding,
                payload={
                    "type": "module",
                    "roadmap_id": roadmap_id,
                    "module_id": module_id,
                    "module_name": module.get("module_name", ""),
                    "text": module_text,
                },
            )
        )

    try:
        client.upsert(collection_name=COLLECTION_NAME, points=points)
    except Exception:
        pass


def search(query: str, limit: int = 10, content_type: str | None = None) -> list[dict]:
    """Search for relevant content using semantic similarity."""
    client = get_qdrant_client()
    if not client:
        return []

    try:
        query_embedding = embed_text(query)

        # Build filter if content_type is specified
        query_filter = None
        if content_type:
            from qdrant_client.models import FieldCondition, Filter, MatchValue  # noqa: PLC0415
            query_filter = Filter(must=[FieldCondition(key="type", match=MatchValue(value=content_type))])

        results = client.search(
            collection_name=COLLECTION_NAME,
            query_vector=query_embedding,
            limit=limit,
            query_filter=query_filter,
        )

        return [
            {
                "id": hit.id,
                "score": hit.score,
                "payload": hit.payload,
            }
            for hit in results
        ]
    except Exception:
        return []


def fallback_search(query: str, db) -> list[dict]:
    """Fallback to keyword search if Qdrant is unavailable."""
    from ..models import Module, Roadmap

    results = []

    # Search roadmaps
    roadmaps = db.query(Roadmap).filter(Roadmap.skill_name.ilike(f"%{query}%")).all()

    for roadmap in roadmaps:
        results.append(
            {
                "id": roadmap.id,
                "score": 0.8,  # Fixed score for keyword match
                "payload": {
                    "type": "roadmap",
                    "roadmap_id": roadmap.id,
                    "skill_name": roadmap.skill_name,
                    "text": roadmap.skill_name,
                },
            }
        )

    # Search modules
    modules = db.query(Module).filter(Module.module_name.ilike(f"%{query}%")).all()

    for module in modules:
        results.append(
            {
                "id": module.id,
                "score": 0.7,  # Lower score for module match
                "payload": {
                    "type": "module",
                    "roadmap_id": module.roadmap_id,
                    "module_id": module.id,
                    "module_name": module.module_name,
                    "text": module.module_name,
                },
            }
        )

    return results[:10]
