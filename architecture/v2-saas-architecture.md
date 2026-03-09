# Pathly v2 — Enterprise SaaS Architecture

> Multi-Tenant · AI-Powered · B2C + B2B · 1M+ Users · Stripe-Level Engineering

---

## High-Level Architecture

```mermaid
graph TB
    subgraph Clients["📱 Clients"]
        FL["Flutter Super App<br/>(Android / iOS)"]
        WEB["Web App<br/>(Next.js 15)"]
        ADMIN["Enterprise Admin<br/>(React Dashboard)"]
        CREATOR["Creator Portal<br/>(React)"]
    end

    subgraph Edge["🌐 Edge Layer"]
        CDN["CloudFront CDN"]
        WAF["AWS WAF / Cloudflare"]
        LB["NGINX Ingress<br/>+ Rate Limiting"]
    end

    subgraph Gateway["🚪 API Gateway"]
        GW["API Gateway<br/>Tenant Resolution · Auth · Rate Limit · Feature Flags"]
    end

    subgraph Core["⚙️ Core Services (Modular Monolith)"]
        AUTH["Auth Service<br/>OAuth2 · JWT · MFA"]
        TENANT["Tenant Service<br/>Org Management · Plans"]
        USER["User Service<br/>Profiles · Roles · RBAC"]
        LEARN["Learning Engine<br/>Skills · Modules · Lessons"]
        PROG["Progress Service<br/>Tracking · XP · Streaks"]
        GAMIFY["Gamification<br/>Badges · Leaderboard · Seasons"]
    end

    subgraph Platform["🏗️ Platform Services"]
        BILL["Billing Service<br/>Stripe · Subscriptions"]
        NOTIF["Notification Service<br/>Push · Email · In-App"]
        BUILDER["Module Builder<br/>Creator Tools"]
        ANALYTICS["Analytics Service<br/>Events · Funnels · Cohorts"]
    end

    subgraph AI["🧠 AI Microservice"]
        REC["Recommendation Engine"]
        TUTOR["AI Tutor (LLM Chat)"]
        ADAPT["Adaptive Branching"]
        EMBED["Embeddings Pipeline"]
    end

    subgraph Data["🗄️ Data Layer"]
        PG["PostgreSQL 16<br/>Multi-Tenant (RLS)"]
        REDIS["Redis 7 Cluster<br/>Cache · Sessions · Leaderboard"]
        QD["Qdrant<br/>Vector Search"]
        S3["S3 / GCS<br/>Media · Exports"]
        EVENTS["Event Store<br/>(Partitioned)"]
    end

    subgraph Infra["☁️ Infrastructure"]
        K8S["Kubernetes<br/>(EKS / GKE)"]
        TF["Terraform IaC"]
        ARGO["ArgoCD GitOps"]
        PROM["Prometheus + Grafana"]
        ELK["ELK + Sentry"]
    end

    FL --> CDN --> WAF --> LB --> GW
    WEB --> CDN
    ADMIN --> CDN
    CREATOR --> CDN

    GW --> Core
    GW --> Platform
    Core --> Data
    Platform --> Data
    Core --> AI
    AI --> QD
    AI --> PG

    K8S --> Core
    K8S --> Platform
    K8S --> AI
```

---

## Service-to-Service Interaction Map

```mermaid
graph LR
    subgraph Sync["Synchronous (REST/gRPC)"]
        GW2["API Gateway"] -->|auth verify| AUTH2["Auth"]
        GW2 -->|tenant resolve| TENANT2["Tenant"]
        GW2 -->|route| LEARN2["Learning Engine"]
        GW2 -->|route| PROG2["Progress"]
        GW2 -->|route| GAMIFY2["Gamification"]
        GW2 -->|route| BILL2["Billing"]
        LEARN2 -->|fetch user plan| BILL2
        PROG2 -->|check features| TENANT2
    end

    subgraph Async["Async Events (Redis Streams)"]
        PROG2 -->|lesson.completed| EV["Event Bus"]
        EV -->|fan-out| GAMIFY2
        EV -->|fan-out| ANALYTICS2["Analytics"]
        EV -->|fan-out| NOTIF2["Notifications"]
        EV -->|fan-out| REC2["AI Recommendations"]
        BILL2 -->|subscription.changed| EV
        AUTH2 -->|user.registered| EV
    end
```

### Event Catalog (Expanded)

| Event | Publisher | Consumers | Priority |
|---|---|---|---|
| `user.registered` | Auth | Tenant, Notification, Analytics | High |
| `lesson.completed` | Progress | Gamification, Leaderboard, Analytics, AI | High |
| `streak.broken` | Progress Worker | Notification, Leaderboard | Medium |
| `badge.unlocked` | Gamification | Notification, User | Medium |
| `subscription.created` | Billing | Tenant, Notification, Analytics | Critical |
| `subscription.cancelled` | Billing | Tenant, Notification, Analytics | Critical |
| `payment.failed` | Billing | Notification (dunning) | Critical |
| `module.published` | Builder | Learning Engine, Embeddings | Medium |
| `tenant.created` | Tenant | Auth, Billing | High |
| `ai.recommendation.served` | AI | Analytics (effectiveness tracking) | Low |

---

## Multi-Tenancy Model

### Strategy: **Hybrid — Row-Level Security (default) + Schema-per-Tenant (enterprise)**

```mermaid
graph TB
    subgraph Default["Standard Tenants (B2C + B2B Teams)"]
        RLS["Shared Database<br/>Row-Level Security<br/>tenant_id on every table"]
    end

    subgraph Enterprise["Enterprise Tenants"]
        SCHEMA["Dedicated Schema<br/>schema_per_tenant<br/>Full data isolation"]
    end

    subgraph Future["Future (Regulated)"]
        DB["Dedicated Database<br/>Per-tenant instance<br/>HIPAA / FedRAMP"]
    end

    Default -->|upgrade| Enterprise
    Enterprise -->|upgrade| Future
```

### Tenant Resolution Flow
```
Request → API Gateway
  ├── Header: X-Tenant-ID (API clients)
  ├── Subdomain: acme.pathly.app → tenant_id
  └── JWT claim: tenant_id (mobile app)
    ↓
  Middleware sets PostgreSQL session:
    SET app.current_tenant = '{tenant_id}';
    ↓
  RLS policy:
    CREATE POLICY tenant_isolation ON users
    USING (tenant_id = current_setting('app.current_tenant')::uuid);
```

### Tenant Table
```sql
CREATE TABLE tenants (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(200) NOT NULL,
    slug            VARCHAR(100) NOT NULL UNIQUE, -- subdomain
    plan            VARCHAR(30) NOT NULL DEFAULT 'free'
                    CHECK (plan IN ('free', 'pro', 'team', 'enterprise')),
    stripe_customer_id VARCHAR(100),
    settings        JSONB DEFAULT '{}',
    feature_flags   JSONB DEFAULT '{}',
    max_users       INT NOT NULL DEFAULT 5,
    max_modules     INT NOT NULL DEFAULT 10,
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## Architecture Decision Records (ADR)

| # | Decision | Choice | Rationale |
|---|---|---|---|
| ADR-001 | Backend Language | **Python 3.12 + FastAPI** | Best AI/ML ecosystem, async, Pydantic v2 |
| ADR-002 | Architecture | **Modular Monolith → Microservices** | Ship fast, split at scale |
| ADR-003 | Multi-Tenancy | **Hybrid RLS + Schema** | Balance cost, isolation, compliance |
| ADR-004 | Billing | **Stripe** | Industry standard, webhooks, global |
| ADR-005 | AI Infrastructure | **Separate FastAPI service** | Independent scaling, GPU-capable nodes |
| ADR-006 | Event Bus | **Redis Streams** | Simple, fast, built-in; Kafka later |
| ADR-007 | Feature Flags | **LaunchDarkly / Flagsmith** | Tenant-level + user-level targeting |
| ADR-008 | Frontend State | **Riverpod 2.x** | Type-safe, testable, code-gen |
| ADR-009 | Auth | **Firebase Auth + custom JWT** | SSO, MFA, enterprise SAML (future) |
| ADR-010 | Leaderboard | **Redis Sorted Sets + seasonal reset** | Real-time, zero-latency ranking |
