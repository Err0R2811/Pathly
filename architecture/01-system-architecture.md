# 01 — System Architecture

> Pathly: Gamified Module-Based Learning Platform

---

## High-Level Architecture

```mermaid
graph TB
    subgraph Clients["📱 Clients"]
        FL["Flutter App<br/>(Android / iOS)"]
        WEB["Web App<br/>(Next.js 15 — Future)"]
        ADMIN["Admin Panel<br/>(Future)"]
    end

    subgraph Gateway["🚪 API Gateway"]
        KONG["Kong / Traefik<br/>Rate Limiting · CORS · Auth Verify"]
    end

    subgraph Backend["⚙️ Backend — Modular Monolith (FastAPI)"]
        AUTH["Auth Module"]
        USER["User Module"]
        MOD["Module / Content"]
        PROG["Progress Module"]
        ACH["Achievement Module"]
        LEAD["Leaderboard Module"]
        NOTIF["Notification Module"]
    end

    subgraph AI["🧠 AI Services"]
        REC["Recommendation<br/>Engine"]
        ADAPT["Adaptive<br/>Difficulty"]
        LLM["LLM Enhancer<br/>(RAG)"]
    end

    subgraph Data["🗄️ Data Layer"]
        PG["PostgreSQL 16"]
        REDIS["Redis 7<br/>Cache · Sessions"]
        QDRANT["Qdrant<br/>Vector DB"]
        S3["S3 / GCS<br/>Object Storage"]
    end

    subgraph Workers["🔧 Background"]
        CELERY["Celery Workers<br/>Async Jobs"]
        BEAT["Celery Beat<br/>Scheduled Tasks"]
    end

    FL --> KONG
    WEB --> KONG
    KONG --> Backend
    Backend --> PG
    Backend --> REDIS
    Backend --> CELERY
    CELERY --> PG
    CELERY --> AI
    AI --> QDRANT
    AI --> PG
    MOD --> S3
```

## Architecture Decisions

| # | Decision | Choice | Rationale |
|---|---|---|---|
| ADR-001 | Backend Language | **Python 3.12 + FastAPI** | Best AI/ML ecosystem, async-native, Pydantic v2 |
| ADR-002 | Architecture Style | **Modular Monolith → Microservices** | Clear domain boundaries now; split later at scale |
| ADR-003 | API Style | **REST + OpenAPI 3.1** | Universal tooling, code generation, client SDKs |
| ADR-004 | State Management | **Riverpod 2.x** | Compile-safe, testable, code-gen friendly |
| ADR-005 | Primary DB | **PostgreSQL 16** | JSONB for content, FTS, CTEs for analytics |
| ADR-006 | Cache Layer | **Redis 7** | Sorted sets for leaderboard, pub/sub for events |
| ADR-007 | Vector DB | **Qdrant** | Purpose-built, gRPC, K8s-native |
| ADR-008 | Background Jobs | **Celery + Redis broker** | Battle-tested, integrates with FastAPI |

---

## Domain Model — Bounded Contexts (DDD)

```mermaid
graph LR
    subgraph Identity["Identity & Access"]
        U["User"] --> R["Role"]
        U --> S["Session"]
    end

    subgraph Content["Learning Content"]
        SK["Skill"] --> MO["Module"]
        MO --> LE["Lesson"]
        LE --> LS["LessonStep"]
    end

    subgraph Engagement["Progress & Engagement"]
        UP["UserProgress"]
        ST["Streak"]
        XP["XP Ledger"]
    end

    subgraph Gamification["Gamification"]
        AC["Achievement"]
        BA["Badge"]
        LB["Leaderboard"]
        LV["Level"]
    end

    subgraph Intelligence["AI & Personalization"]
        RE["Recommendation"]
        DP["DifficultyProfile"]
        EN["LessonEnhancement"]
    end

    Identity --> Content
    Content --> Engagement
    Engagement --> Gamification
    Content --> Intelligence
    Engagement --> Intelligence
```

### Aggregate Roots

| Aggregate | Owns | Invariants |
|---|---|---|
| **User** | profile, settings, auth_tokens | email unique, password hashed |
| **Skill** | modules → lessons → steps | ordering enforced, prerequisites |
| **UserProgress** | step completions, XP earned | idempotent completion, no duplicate XP |
| **Achievement** | badge rules, unlock conditions | rule engine evaluates on events |
| **Leaderboard** | rankings, decay scores | time-windowed, periodic recalc |

---

## Communication Patterns

| Pattern | Technology | Use Case |
|---|---|---|
| Synchronous REST | HTTP/JSON | CRUD, auth, lesson fetch |
| Async Events | Redis Pub/Sub | Progress → achievements, streak, leaderboard |
| Background Jobs | Celery | AI recs, batch analytics, notifications |
| Scheduled Tasks | Celery Beat | Streak expiry, leaderboard decay, daily digests |

### Event Flow: Lesson Completion

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant GW as API Gateway
    participant Prog as Progress Module
    participant Bus as Event Bus (Redis)
    participant Ach as Achievement Module
    participant Lead as Leaderboard Module
    participant Streak as Streak Worker

    App->>GW: POST /api/v1/progress/complete
    GW->>Prog: Validate + record completion
    Prog->>Prog: Calculate XP, update progress
    Prog->>Bus: emit("lesson.completed", {user_id, lesson_id, xp})
    par Fan-out
        Bus-->>Ach: Evaluate badge rules
        Bus-->>Lead: Recalculate rank
        Bus-->>Streak: Increment streak
    end
    Prog-->>GW: {xp_earned, new_level, badges: [...]}
    GW-->>App: Animated reward payload
```

### Event Catalog

| Event | Publisher | Consumers |
|---|---|---|
| `user.registered` | Auth | User, Notification, Achievement |
| `lesson.completed` | Progress | Achievement, Leaderboard, Streak, Analytics |
| `streak.broken` | Streak Worker | Notification, Leaderboard |
| `badge.unlocked` | Achievement | Notification, User |
| `level.up` | Progress | Notification, Achievement |
| `xp.earned` | Progress | Leaderboard |
