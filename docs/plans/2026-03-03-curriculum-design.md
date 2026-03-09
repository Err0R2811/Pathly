# Curriculum Generation & Verification Design (Pathly SaaS)

**Date:** 2026-03-03

---

## 1. Overview
We are designing a **Research‑Verified Adaptive Curriculum** subsystem that generates learning roadmaps on‑demand, validates them against strict peer‑reviewed sources, and feeds an adaptive engine. The design obeys the constraints you selected:
- **Strict research verification** (≥2 peer‑reviewed citations per module)
- **Dual‑pass generation** (generator → reviewer, repeat until alignment score ≥ 85)
- **Combined storage** (PostgreSQL for structured data + Qdrant for vector embeddings)
- **Both synchronous preview and asynchronous full generation**
- **UI features**: verification scores, source list, export (PDF/Markdown)

---

## 2. Component Diagram
```
+--------------------+      +-------------------+      +--------------------+
|   API Gateway     | ---> |   Curriculum API  | ---> |   Generator svc    |
| (Kong/Traefik)   |      | (FastAPI)         |      | (Ollama model A)   |
+--------------------+      +-------------------+      +--------------------+
                                   |
                                   | async job (Celery)
                                   v
                        +-------------------+      +--------------------+
                        |   Reviewer svc    | ---> |   Verification DB |
                        | (Ollama model B) |      | (Postgres + Qdrant) |
                        +-------------------+      +--------------------+
                                   |
                                   | updates roadmap JSON with scores
                                   v
                        +-------------------+
                        |   Storage svc    |
                        | (Postgres + Qdrant) |
                        +-------------------+
```
*All services run inside the same Docker compose for the MVP, but are cleanly separated for future micro‑service migration.*

---

## 3. API Contract
### 3.1 Preview (synchronous)
`GET /curriculum/preview?skill_name=<name>`
- **Input:** `skill_name`
- **Output:** JSON containing a **draft roadmap** (generator only), no verification scores.
- **Use‑case:** Immediate UI feedback on skill selection.

### 3.2 Full Request (asynchronous)
`POST /curriculum/request`
```json
{
  "skill_name": "Python Programming",
  "user_id": "uuid",
  "max_retries": 3
}
```
- Returns `{ "job_id": "uuid" }`

`GET /curriculum/status/{job_id}`
- Returns `{ "status": "PENDING|RUNNING|COMPLETED|FAILED", "progress": 0‑100 }`

`GET /curriculum/{roadmap_id}`
- Returns the **verified roadmap** with:
  - verification_score (0‑100)
  - `modules[]` each containing `verification_alignment_score` and a list of `research_sources[]` (title, DOI, url).

`GET /curriculum/{roadmap_id}/export?format=pdf|md`
- Generates a PDF or Markdown file for download.

---

## 4. Database Schema (PostgreSQL)
```sql
CREATE TABLE roadmaps (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    skill_name TEXT NOT NULL,
    domain_type TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    verification_score INT CHECK (verification_score BETWEEN 0 AND 100)
);

CREATE TABLE modules (
    id UUID PRIMARY KEY,
    roadmap_id UUID REFERENCES roadmaps(id) ON DELETE CASCADE,
    module_name TEXT NOT NULL,
    level TEXT NOT NULL,
    difficulty_score INT,
    verification_alignment_score INT,
    estimated_hours INT,
    pedagogical_basis TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE research_sources (
    id UUID PRIMARY KEY,
    module_id UUID REFERENCES modules(id) ON DELETE CASCADE,
    title TEXT,
    doi TEXT,
    url TEXT,
    abstract TEXT,
    embedding VECTOR(1536)  -- Qdrant vector
);
```
*Qdrant holds the same `research_sources` embeddings for fast similarity queries (`/search/similar?query=...`).*

---

## 5. Background Task Orchestration (Celery)
1. **GenerateTask** – calls Ollama **Generator** with the skill name.
2. **ReviewTask** – receives generator output, calls Ollama **Reviewer**.
3. **ScoreTask** – computes `alignment_score` based on citation count, source reputation, and semantic similarity (via Qdrant).
4. **Loop** – if `alignment_score < 85` and retries remain, re‑run **GenerateTask**.
5. **Finalize** – store roadmap JSON + verification metadata in PostgreSQL, store source embeddings in Qdrant, mark job **COMPLETED**.

Retry policy: exponential back‑off (2ⁿ seconds), max 3 attempts per stage.

---

## 6. UI Integration (Flutter)
- **SkillSelectionScreen** (pastel grid) → on tap calls preview API; shows draft.
- **RoadmapScreen** displays modules in cards:
  - pastel background (mint, lavender, yellow, pink) with **thick black outline** and 24px+ rounded corners.
  - Shows **verification badge** (green if score≥85, amber otherwise).
  - XP reward badge, difficulty badge, estimated time.
  - *Export* button invokes `/export`.
- **AdaptiveEngine** updates UI when a module is re‑ordered or difficulty adjusted (animation of progress bar, XP boost).

---

## 7. Security & Validation
- All external Ollama requests go through a **service‑side secret**; never expose API keys to the client.
- **Citation validation**: reject any source without DOI/DOI‑lookup or without a peer‑reviewed flag.
- **Logging**: every generation and review request is logged with user ID, timestamp, and model version for audit.
- **Rate limiting**: per‑user quota (free tier: 2 roadmaps/day, Pro: unlimited).

---

## 8. Testing Strategy
| Layer | Tests |
|-------|-------|
| **Unit** | Generator wrapper, Reviewer wrapper, score calculation, DB models. |
| **Integration** | End‑to‑end flow: preview → async request → status → final roadmap, including failure injection (Ollama timeout). |
| **Contract** | OpenAPI spec validation for all endpoints. |
| **Property‑based** | Verify that difficulty scores are monotonic across levels, and that every module contains ≥2 citations. |
| **Security** | Ensure no API key leaks, rate limits enforced, source validation rejects non‑peer‑reviewed entries. |

---

## 9. CI/CD Sketch
1. **Lint & static analysis** (ruff, mypy, black).
2. **Unit tests** (`pytest`).
3. **Docker build** – multi‑stage image with FastAPI, Celery, Qdrant.
4. **Integration tests** (Docker‑compose spin‑up, run API tests).
5. **Deploy** to Kubernetes (Helm chart).
6. **Monitoring** – Prometheus + Grafana for job latency, error rates.

---

## 10. Next Steps
1. Implement the service skeletons (FastAPI routers, Celery tasks).
2. Set up PostgreSQL + Qdrant containers.
3. Create the Flutter UI screens that consume the preview and async endpoints.
4. Write unit & integration tests as defined above.
5. Add CI pipeline to automate the steps.

---

*Please review this design. Once approved, I will commit the document and move on to generating the implementation plan.*