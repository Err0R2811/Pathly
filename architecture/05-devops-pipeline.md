# 05 — DevOps Pipeline & Infrastructure

> Docker · Kubernetes · Terraform · GitHub Actions · ArgoCD

---

## Infrastructure Overview

```mermaid
graph TB
    subgraph Dev["👨‍💻 Developer"]
        CODE["Push to GitHub"]
    end

    subgraph CI["🔄 GitHub Actions"]
        LINT["Lint & Format"]
        TEST["Unit + Integration Tests"]
        SCAN["Security Scan (SAST)"]
        BUILD["Docker Build"]
        PUSH["Push to Registry"]
    end

    subgraph CD["🚀 ArgoCD (GitOps)"]
        SYNC["Sync K8s Manifests"]
        CANARY["Canary / Blue-Green"]
    end

    subgraph K8s["☸️ Kubernetes (EKS/GKE)"]
        STAGING["Staging Namespace"]
        PROD["Production Namespace"]
    end

    subgraph Monitoring["📊 Observability"]
        PROM["Prometheus"]
        GRAF["Grafana"]
        ELK["ELK Stack"]
    end

    CODE --> CI
    LINT --> TEST --> SCAN --> BUILD --> PUSH
    PUSH --> CD
    CD --> K8s
    K8s --> Monitoring
```

---

## GitHub Actions CI Pipeline

```yaml
# .github/workflows/ci.yml
name: Pathly CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

env:
  REGISTRY: ghcr.io
  FLUTTER_VERSION: "3.27.0"
  PYTHON_VERSION: "3.12"

jobs:
  # ──────────────────────────────────────────
  #  Flutter Frontend
  # ──────────────────────────────────────────
  flutter-check:
    name: Flutter Lint & Test
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: app
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: dart analyze --fatal-infos

      - name: Format check
        run: dart format --set-exit-if-changed .

      - name: Run tests
        run: flutter test --coverage --reporter=github

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: app/coverage/lcov.info
          flags: flutter

  flutter-build:
    name: Flutter Build (${{ matrix.platform }})
    needs: flutter-check
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        include:
          - platform: android
            os: ubuntu-latest
          - platform: ios
            os: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Build APK / IPA
        working-directory: app
        run: |
          if [ "${{ matrix.platform }}" = "android" ]; then
            flutter build apk --release
          else
            flutter build ios --release --no-codesign
          fi

  # ──────────────────────────────────────────
  #  Backend (FastAPI)
  # ──────────────────────────────────────────
  backend-check:
    name: Backend Lint & Test
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: backend
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: pathly_test
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7-alpine
        ports: ["6379:6379"]
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}

      - name: Install uv
        run: pip install uv

      - name: Install dependencies
        run: uv sync

      - name: Lint (ruff)
        run: |
          uv run ruff check .
          uv run ruff format --check .

      - name: Type check (mypy)
        run: uv run mypy app/

      - name: Run tests
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/pathly_test
          REDIS_URL: redis://localhost:6379/0
        run: uv run pytest --cov=app --cov-report=xml -v

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: backend/coverage.xml
          flags: backend

  # ──────────────────────────────────────────
  #  Security Scanning
  # ──────────────────────────────────────────
  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Trivy (filesystem)
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: fs
          scan-ref: .
          severity: HIGH,CRITICAL

      - name: Run Bandit (Python SAST)
        run: |
          pip install bandit
          bandit -r backend/app/ -f json -o bandit-report.json || true

      - name: OWASP Dependency Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          path: .
          format: HTML

  # ──────────────────────────────────────────
  #  Docker Build & Push
  # ──────────────────────────────────────────
  docker-build:
    name: Build & Push Images
    needs: [backend-check, security-scan]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4

      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/build-push-action@v5
        with:
          context: backend
          push: true
          tags: |
            ${{ env.REGISTRY }}/pathly/backend:${{ github.sha }}
            ${{ env.REGISTRY }}/pathly/backend:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

## Dockerfile (Backend)

```dockerfile
# backend/Dockerfile
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install uv
RUN pip install uv

# Install dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# Copy application
COPY app/ app/
COPY migrations/ migrations/
COPY alembic.ini .

# Non-root user
RUN adduser --disabled-password --no-create-home appuser
USER appuser

EXPOSE 8000

CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## Kubernetes Manifests

```yaml
# infra/k8s/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pathly-backend
  namespace: pathly
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: pathly-backend
  template:
    metadata:
      labels:
        app: pathly-backend
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
    spec:
      containers:
        - name: backend
          image: ghcr.io/pathly/backend:latest
          ports:
            - containerPort: 8000
          envFrom:
            - secretRef:
                name: pathly-secrets
            - configMapRef:
                name: pathly-config
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 10
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 8000
            initialDelaySeconds: 5
            periodSeconds: 10
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: pathly-backend-hpa
  namespace: pathly
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: pathly-backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

---

## Terraform (Core Infrastructure)

```hcl
# infra/terraform/main.tf
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "pathly-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true  # Cost-optimize for MVP
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "pathly-cluster"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = {
    general = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 6
      desired_size   = 3
    }
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier     = "pathly-db"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.medium"

  allocated_storage     = 50
  max_allocated_storage = 200

  db_name  = "pathly"
  username = "pathly_admin"

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids             = module.vpc.private_subnets

  backup_retention_period = 7
  multi_az               = false  # Single-AZ for MVP, multi-AZ for prod
  deletion_protection    = true
}
```

---

## Environment Strategy

| Env | Branch | Auto-deploy | URL |
|---|---|---|---|
| **Dev** | `develop` | ✅ on push | `dev.pathly.app` |
| **Staging** | `release/*` | ✅ on push | `staging.pathly.app` |
| **Production** | `main` | 🔒 Manual approval | `api.pathly.app` |

### Secrets Management
- **Kubernetes Secrets** for pod env vars
- **AWS Secrets Manager** for DB passwords, API keys
- **External Secrets Operator** syncs AWS → K8s
- **Never** hardcode secrets in code or manifests

---

## Monitoring & Observability

| Tool | Purpose | Deployment |
|---|---|---|
| Prometheus | Metrics collection | K8s DaemonSet |
| Grafana | Dashboards & alerts | K8s Deployment |
| Loki | Log aggregation | K8s DaemonSet |
| Jaeger | Distributed tracing | K8s Deployment |
| PagerDuty/Slack | Alert routing | Integration |

### Key Metrics Tracked
- Request latency (p50, p95, p99)
- Error rate (5xx)
- Active users (WebSocket connections)
- Database query duration
- Redis hit/miss ratio
- Celery queue depth
- Pod CPU / memory utilization
