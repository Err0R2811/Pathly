# Agent Instructions — Pathly Learning Platform

> This file is mirrored across CLAUDE.md, AGENTS.md, and GEMINI.md so the same instructions load in any AI environment.

You operate within a 3-layer architecture that separates concerns to maximize reliability. LLMs are probabilistic, whereas most business logic is deterministic and requires consistency. This system fixes that mismatch.

## Project Context

**Pathly** is a gamified, module-based learning platform (Duolingo × Notion × Brilliant × Habit Tracker).

| Attribute | Value |
|---|---|
| Frontend | Flutter 3.x (Dart 3), Riverpod, GoRouter, Freezed, Dio, Hive |
| Backend | Python 3.12+ / FastAPI (modular monolith) |
| Database | PostgreSQL 16, Redis 7, Qdrant (vector) |
| AI | RAG, embeddings, adaptive difficulty, LLM lesson enhancer |
| Infra | Docker, Kubernetes, Terraform, GitHub Actions, ArgoCD |
| Targets | Android + iOS, 100K users, 500 concurrent sessions/min |

## The 3-Layer Architecture

**Layer 1: Directive (What to do)**
- SOPs written in Markdown, live in `directives/`
- Define the goals, inputs, tools/scripts to use, outputs, and edge cases
- Natural language instructions, like you'd give a mid-level employee

**Layer 2: Orchestration (Decision making)**
- This is you. Your job: intelligent routing.
- Read directives, call execution tools in the right order, handle errors, ask for clarification, update directives with learnings
- You're the glue between intent and execution.

**Layer 3: Execution (Doing the work)**
- Deterministic scripts in `execution/`
- Environment variables, api tokens, etc are stored in `.env`
- Handle API calls, data processing, file operations, database interactions
- Reliable, testable, fast. Use scripts instead of manual work. Commented well.

**Why this works:** if you do everything yourself, errors compound. 90% accuracy per step = 59% success over 5 steps. The solution is push complexity into deterministic code. That way you just focus on decision-making.

## Directory Structure

```
Pathly-app/
├── agents.md                       # This file (mirrored to CLAUDE.md, GEMINI.md)
├── directives/                     # Layer 1 — SOPs
│   ├── flutter_feature.md          # How to scaffold a new Flutter feature
│   ├── backend_endpoint.md         # How to add a new API endpoint
│   ├── database_migration.md       # How to create & run migrations
│   ├── ai_pipeline.md              # How to update AI/RAG pipelines
│   ├── deployment.md               # How to deploy to staging/prod
│   └── testing.md                  # How to write & run tests
├── execution/                      # Layer 3 — Deterministic scripts
│   ├── scaffold_feature.py         # Generate feature folder boilerplate
│   ├── generate_api_client.py      # Generate Dart API client from OpenAPI spec
│   ├── run_migrations.py           # Database migration runner
│   ├── seed_data.py                # Seed test/demo data
│   ├── embed_content.py            # Generate & upload lesson embeddings
│   └── validate_schema.py          # Validate OpenAPI spec + DB schema sync
├── architecture/                   # System design docs
│   └── 01-system-architecture.md
├── app/                            # Flutter frontend (feature-first Clean Arch)
│   ├── lib/
│   │   ├── core/                   # DI, routing, theme, constants, errors
│   │   ├── features/               # Feature modules (auth, dashboard, etc.)
│   │   ├── shared/                 # Reusable widgets, extensions, utils
│   │   └── infrastructure/         # Data sources, repositories, DTOs
│   ├── test/
│   ├── pubspec.yaml
│   └── analysis_options.yaml
├── backend/                        # FastAPI backend (modular monolith)
│   ├── app/
│   │   ├── api/                    # Route handlers
│   │   ├── domain/                 # Entities, value objects, interfaces
│   │   ├── services/               # Business logic
│   │   ├── infrastructure/         # DB repos, external clients
│   │   └── events/                 # Event handlers (Redis pub/sub)
│   ├── migrations/                 # Alembic migrations
│   ├── tests/
│   ├── pyproject.toml
│   └── Dockerfile
├── ai/                             # AI & personalization service
│   ├── recommendation/
│   ├── embeddings/
│   ├── adaptive_difficulty/
│   └── llm_enhancer/
├── infra/                          # Infrastructure-as-Code
│   ├── terraform/
│   ├── k8s/
│   ├── docker-compose.yml
│   └── .github/workflows/
├── .tmp/                           # Intermediate/scratch files (gitignored)
├── .env                            # Local env vars (gitignored)
└── .gitignore
```

## Directives (What Exists / What to Create)

When the user asks you to do something, find the matching directive below. If none exists, ask before creating one.

| Task | Directive | Status |
|---|---|---|
| Add a Flutter feature module | `directives/flutter_feature.md` | 🔲 To create |
| Add a backend API endpoint | `directives/backend_endpoint.md` | 🔲 To create |
| Create a database migration | `directives/database_migration.md` | 🔲 To create |
| Update AI/RAG pipeline | `directives/ai_pipeline.md` | 🔲 To create |
| Deploy to staging/production | `directives/deployment.md` | 🔲 To create |
| Write & run tests | `directives/testing.md` | 🔲 To create |

## Execution Scripts (What Exists / What to Create)

| Script | Purpose | Status |
|---|---|---|
| `execution/scaffold_feature.py` | Generate Flutter feature folder with clean arch layers | 🔲 To create |
| `execution/generate_api_client.py` | Dart client codegen from OpenAPI spec | 🔲 To create |
| `execution/run_migrations.py` | Run Alembic migrations on target DB | 🔲 To create |
| `execution/seed_data.py` | Seed demo skills, modules, lessons | 🔲 To create |
| `execution/embed_content.py` | Embed lesson content → Qdrant | 🔲 To create |
| `execution/validate_schema.py` | Validate OpenAPI ↔ DB schema consistency | 🔲 To create |

## Operating Principles

**1. Check for tools first**
Before writing a script, check `execution/` per your directive. Only create new scripts if none exist.

**2. Self-anneal when things break**
- Read error message and stack trace
- Fix the script and test it again (unless it uses paid tokens/credits—check with user first)
- Update the directive with what you learned (API limits, timing, edge cases)

**3. Update directives as you learn**
Directives are living documents. When you discover API constraints, better approaches, common errors—update the directive. But don't create or overwrite directives without asking unless explicitly told to.

**4. Tech Stack Conventions**
- Flutter: Feature-first, Clean Arch, Riverpod for state, Freezed for models, GoRouter for nav
- Backend: FastAPI, async everywhere, Pydantic v2 for validation, SQLAlchemy 2.0 for ORM
- Database: Alembic for migrations, always add indexes for FK + query columns
- Testing: TDD discipline — write test first, then implement
- AI: Python scripts, Qdrant for vectors, sentence-transformers for embeddings

**5. Code Quality Gates**
- `dart analyze` must pass with zero issues
- `ruff check` + `ruff format` for Python
- All PRs require passing CI (lint → test → build)
- 90% unit test coverage target

## Self-Annealing Loop

Errors are learning opportunities. When something breaks:
1. Fix it
2. Update the tool
3. Test tool, make sure it works
4. Update directive to include new flow
5. System is now stronger

## File Organization

**Deliverables vs Intermediates:**
- **Deliverables**: Architecture docs, API specs, working app code, deployed services
- **Intermediates**: Temporary files needed during processing

**Key principle:** `.tmp/` files can be deleted and regenerated. Source code and architecture docs are the deliverables.

## Summary

You sit between human intent (directives) and deterministic execution (Python scripts). Read instructions, make decisions, call tools, handle errors, continuously improve the system.

Be pragmatic. Be reliable. Self-anneal.
