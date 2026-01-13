# DevOps Learning Project - Production-Ready REST API

[![CI/CD Pipeline](https://github.com/YOUR_USERNAME/devops-api/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/YOUR_USERNAME/devops-api/actions)
[![Docker](https://img.shields.io/docker/v/YOUR_USERNAME/devops-api?label=docker)](https://hub.docker.com/r/YOUR_USERNAME/devops-api)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A comprehensive DevOps learning project demonstrating end-to-end software delivery practices including CI/CD, containerization, orchestration, observability, and security.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Quick Start](#quick-start)
- [API Documentation](#api-documentation)
- [Development](#development)
- [Docker](#docker)
- [Kubernetes](#kubernetes)
- [CI/CD Pipeline](#cicd-pipeline)
- [Observability](#observability)
- [Security](#security)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This project implements a simple REST API backend service with **production-grade DevOps practices**:

- **Backend**: Python + FastAPI (< 150 lines)
- **Containerization**: Docker with multi-stage builds
- **Orchestration**: Kubernetes (Minikube)
- **CI/CD**: GitHub Actions with automated testing and deployment
- **Observability**: Prometheus metrics, structured logs, distributed tracing
- **Security**: SAST (Bandit, Semgrep), DAST (OWASP ZAP), container scanning (Trivy)

**Target Audience**: DevOps beginners, students, and engineers learning modern software delivery practices.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      DEVOPS PIPELINE                             │
│                                                                  │
│  Developer                                                       │
│      │                                                           │
│      │ git push                                                  │
│      ▼                                                           │
│  ┌────────────────────────────────────────────────────────┐     │
│  │             GitHub Repository                          │     │
│  │  • Source Code (Python/FastAPI)                        │     │
│  │  • Docker Configuration                                │     │
│  │  • Kubernetes Manifests                                │     │
│  │  • CI/CD Workflows                                     │     │
│  └────────────────┬───────────────────────────────────────┘     │
│                   │                                             │
│                   │ trigger                                     │
│                   ▼                                             │
│  ┌────────────────────────────────────────────────────────┐     │
│  │           GitHub Actions (CI/CD)                       │     │
│  │                                                        │     │
│  │  1. Test                                               │     │
│  │     ├─ Run pytest                                      │     │
│  │     └─ Generate coverage (>80%)                        │     │
│  │                                                        │     │
│  │  2. Security SAST                                      │     │
│  │     ├─ Bandit (Python security)                        │     │
│  │     └─ Semgrep (Code patterns)                         │     │
│  │                                                        │     │
│  │  3. Build                                              │     │
│  │     ├─ Docker build (multi-stage)                      │     │
│  │     ├─ Trivy scan (vulnerabilities)                    │     │
│  │     └─ Push to Docker Hub                              │     │
│  │                                                        │     │
│  │  4. Deploy                                             │     │
│  │     ├─ Update K8s deployment                           │     │
│  │     └─ Verify rollout                                  │     │
│  │                                                        │     │
│  │  5. Security DAST                                      │     │
│  │     └─ OWASP ZAP scan                                  │     │
│  └────────────────┬───────────────────────────────────────┘     │
│                   │                                             │
│                   │ deploy                                      │
│                   ▼                                             │
│  ┌────────────────────────────────────────────────────────┐     │
│  │        Kubernetes Cluster (Minikube)                   │     │
│  │                                                        │     │
│  │  ┌──────────────────────────────────────────────┐     │     │
│  │  │  Service (NodePort :30080)                   │     │     │
│  │  │    Load Balancer                             │     │     │
│  │  └───────────┬──────────────────────────────────┘     │     │
│  │              │                                         │     │
│  │  ┌───────────▼──────────────────────────────────┐     │     │
│  │  │  Deployment (3 replicas)                     │     │     │
│  │  │   ┌──────┐  ┌──────┐  ┌──────┐              │     │     │
│  │  │   │ Pod1 │  │ Pod2 │  │ Pod3 │              │     │     │
│  │  │   │ API  │  │ API  │  │ API  │              │     │     │
│  │  │   └──────┘  └──────┘  └──────┘              │     │     │
│  │  │   Health Checks | Resource Limits           │     │     │
│  │  └──────────────────────────────────────────────┘     │     │
│  │                                                        │     │
│  │  ┌──────────────────────────────────────────────┐     │     │
│  │  │  HorizontalPodAutoscaler                     │     │     │
│  │  │  Auto-scale 2-10 pods (CPU/Memory)           │     │     │
│  │  └──────────────────────────────────────────────┘     │     │
│  └────────────────────────────────────────────────────────┘     │
│                   │                                             │
│                   │ expose                                      │
│                   ▼                                             │
│  ┌────────────────────────────────────────────────────────┐     │
│  │         Observability Stack                            │     │
│  │                                                        │     │
│  │  Prometheus ──► Scrape /metrics every 15s             │     │
│  │  Grafana ─────► Visualize dashboards                  │     │
│  │  Logs ────────► Structured JSON (stdout)              │     │
│  │  Traces ──────► X-Trace-ID headers                    │     │
│  └────────────────────────────────────────────────────────┘     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## ✨ Features

### Backend API
- ✅ **3 RESTful endpoints**: `/health`, `GET /items`, `POST /items`
- ✅ **Input validation**: Pydantic models with constraints
- ✅ **Error handling**: Proper HTTP status codes
- ✅ **Auto-documentation**: OpenAPI/Swagger at `/docs`

### Observability
- ✅ **Metrics**: Prometheus format at `/metrics`
  - Request counter (by method, endpoint, status)
  - Request duration histogram
- ✅ **Logs**: Structured JSON logging
  - Request/response lifecycle
  - Business events
  - Distributed trace IDs
- ✅ **Tracing**: UUID trace ID in all logs and headers

### Security
- ✅ **SAST**: Static code analysis (Bandit, Semgrep)
- ✅ **DAST**: Dynamic scanning (OWASP ZAP)
- ✅ **Container Scanning**: Vulnerability detection (Trivy)
- ✅ **Runtime Security**: Non-root user, minimal image

### DevOps
- ✅ **CI/CD**: Automated pipeline (test → scan → build → deploy)
- ✅ **Docker**: Multi-stage build (~200MB final image)
- ✅ **Kubernetes**: Production-ready manifests with auto-scaling
- ✅ **Git Workflow**: Feature branches, PR reviews, protected main

## 🚀 Quick Start

### Prerequisites

- **Python 3.11+**
- **Docker & Docker Compose**
- **Kubectl**
- **Minikube** (for Kubernetes)
- **Git**

### Local Development (No Docker)

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/devops-api.git
cd devops-api

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run application
uvicorn app.main:app --reload

# 5. Access API
# OpenAPI docs: http://localhost:8000/docs
# Health check: http://localhost:8000/health
```

### Docker (Recommended)

```bash
# 1. Build image
docker build -t devops-api:1.0.0 .

# 2. Run container
docker run -d -p 8000:8000 --name devops-api devops-api:1.0.0

# 3. View logs
docker logs -f devops-api

# 4. Test endpoints
curl http://localhost:8000/health
```

### Docker Compose (Full Stack)

```bash
# Start all services (API + Prometheus + Grafana)
docker-compose up -d

# Access services
# API:        http://localhost:8000
# Prometheus: http://localhost:9090
# Grafana:    http://localhost:3000 (admin/admin)

# Stop services
docker-compose down
```

## 📚 API Documentation

### Endpoints

#### 1. Health Check
```http
GET /health
```

**Response** (200 OK):
```json
{
  "status": "healthy",
  "service": "devops-api",
  "timestamp": "2026-01-12T10:30:00.123456"
}
```

#### 2. Get All Items
```http
GET /items
```

**Response** (200 OK):
```json
[
  {
    "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "name": "Sample Product",
    "description": "A sample item",
    "price": 29.99,
    "created_at": "2026-01-12T10:30:00.123456"
  }
]
```

#### 3. Create Item
```http
POST /items
Content-Type: application/json

{
  "name": "New Product",
  "description": "Optional description",
  "price": 49.99
}
```

**Response** (201 Created):
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "name": "New Product",
  "description": "Optional description",
  "price": 49.99,
  "created_at": "2026-01-12T10:31:00.456789"
}
```

**Validation Rules**:
- `name`: Required, 1-100 characters, not empty/whitespace
- `description`: Optional, max 500 characters
- `price`: Required, > 0, ≤ 1,000,000

#### 4. Metrics
```http
GET /metrics
```

**Response** (200 OK):
```
# HELP api_requests_total Total API requests
# TYPE api_requests_total counter
api_requests_total{endpoint="/health",method="GET",status="200"} 15.0
...
```

### Interactive Documentation

Visit http://localhost:8000/docs for interactive Swagger UI with:
- Try-it-out functionality
- Request/response examples
- Schema definitions

## 🛠️ Development

### Running Tests

```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Run tests with coverage
pytest tests/ -v --cov=app --cov-report=html

# View coverage report
open htmlcov/index.html  # Windows: start htmlcov/index.html
```

### Code Quality

```bash
# Linting
flake8 app/ tests/

# Type checking
mypy app/

# Security scanning
bandit -r app/

# Format code
black app/ tests/
```

### Project Setup for Contributors

```bash
# 1. Fork repository on GitHub

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/devops-api.git

# 3. Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/devops-api.git

# 4. Create feature branch
git checkout -b feature/my-feature

# 5. Make changes, commit, push
git add .
git commit -m "feat: add new feature"
git push origin feature/my-feature

# 6. Open Pull Request on GitHub
```

## 🐳 Docker

### Build & Run

```bash
# Build
docker build -t YOUR_DOCKERHUB_USERNAME/devops-api:1.0.0 .

# Run
docker run -d -p 8000:8000 --name api YOUR_DOCKERHUB_USERNAME/devops-api:1.0.0

# Logs
docker logs -f api

# Execute commands
docker exec -it api /bin/bash

# Stop & remove
docker stop api && docker rm api
```

### Docker Hub

```bash
# Login
docker login

# Tag
docker tag devops-api:1.0.0 YOUR_USERNAME/devops-api:1.0.0

# Push
docker push YOUR_USERNAME/devops-api:1.0.0

# Pull (others can use)
docker pull YOUR_USERNAME/devops-api:1.0.0
```

### Image Details

- **Base Image**: `python:3.11-slim`
- **Build Pattern**: Multi-stage (builder + runtime)
- **Final Size**: ~200MB
- **Security**: Non-root user (uid 1000)
- **Health Check**: Every 30s via `/health`

See [docs/DOCKER.md](docs/DOCKER.md) for detailed documentation.

## ☸️ Kubernetes

### Deploy to Minikube

```bash
# 1. Start Minikube
minikube start --cpus=4 --memory=4096

# 2. Update image in k8s/deployment.yaml
# Change: YOUR_DOCKERHUB_USERNAME/devops-api:1.0.0

# 3. Deploy
kubectl apply -f k8s/

# 4. Verify
kubectl get pods
kubectl get service devops-api-service

# 5. Access API
minikube service devops-api-service --url
# or
curl http://$(minikube ip):30080/health
```

### Kubernetes Resources

- **Deployment**: 3 replicas, rolling updates
- **Service**: NodePort on :30080
- **ConfigMap**: Environment configuration
- **HPA**: Auto-scale 2-10 pods based on CPU/memory

### Useful Commands

```bash
# View logs
kubectl logs -f deployment/devops-api

# Scale manually
kubectl scale deployment devops-api --replicas=5

# Update image
kubectl set image deployment/devops-api api=new-image:tag

# Port forward
kubectl port-forward deployment/devops-api 8000:8000

# Delete all
kubectl delete -f k8s/
```

See [docs/KUBERNETES.md](docs/KUBERNETES.md) for detailed deployment guide.

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

Triggered on: `push` and `pull_request` to `main` and `develop`

**Pipeline Stages**:

1. **Test** (4 min)
   - Install dependencies
   - Run pytest with coverage
   - Upload coverage reports

2. **Security SAST** (3 min)
   - Bandit Python security scan
   - Semgrep pattern matching
   - Upload SARIF reports to GitHub Security

3. **Build** (5 min)
   - Build Docker image
   - Trivy vulnerability scan
   - Push to Docker Hub with tags

4. **Deploy** (2 min) - `main` branch only
   - Update Kubernetes deployment
   - Verify rollout status
   - Run smoke tests

5. **Security DAST** (10 min) - `main` branch only
   - OWASP ZAP baseline scan
   - Upload scan reports

### Required Secrets

Configure in GitHub Settings → Secrets:

```
DOCKERHUB_USERNAME=your_username
DOCKERHUB_TOKEN=your_access_token
KUBE_CONFIG=base64_encoded_kubeconfig
```

### Setup Instructions

```bash
# 1. Generate Docker Hub token
# Visit: https://hub.docker.com/settings/security

# 2. Encode kubeconfig
cat ~/.kube/config | base64

# 3. Add secrets to GitHub repository
# Settings → Secrets and variables → Actions → New repository secret
```

See [.github/workflows/ci-cd.yml](.github/workflows/ci-cd.yml) for complete pipeline configuration.

## 📊 Observability

### Metrics

Access Prometheus metrics at http://localhost:8000/metrics

**Available Metrics**:
- `api_requests_total`: Request counter (labels: method, endpoint, status)
- `api_request_duration_seconds`: Request duration histogram

**Query Examples** (Prometheus):
```promql
# Request rate per second
rate(api_requests_total[5m])

# 95th percentile latency
histogram_quantile(0.95, api_request_duration_seconds)

# Error rate
rate(api_requests_total{status=~"5.."}[5m])
```

### Logs

Structured JSON logs to stdout:

```json
{
  "trace_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "event": "request_completed",
  "method": "POST",
  "path": "/items",
  "status_code": 201,
  "duration_seconds": 0.0234,
  "timestamp": "2026-01-12T10:30:15.480189"
}
```

**View Logs**:
```bash
# Docker
docker logs -f devops-api | jq

# Kubernetes
kubectl logs -f deployment/devops-api | jq
```

### Tracing

Each request gets a unique trace ID:

```bash
# Response header
X-Trace-ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890

# Search logs by trace ID
kubectl logs deployment/devops-api | grep "a1b2c3d4"
```

See [docs/OBSERVABILITY.md](docs/OBSERVABILITY.md) for comprehensive guide.

## 🔒 Security

### Security Scanning

**SAST (Static Analysis)**:
- **Bandit**: Python-specific security issues
- **Semgrep**: Code patterns and anti-patterns

**Container Scanning**:
- **Trivy**: OS and package vulnerabilities

**DAST (Dynamic Analysis)**:
- **OWASP ZAP**: Runtime security testing

### Run Security Scans Locally

```bash
# Install tools
pip install bandit semgrep
choco install trivy  # Windows

# SAST
bandit -r app/ -f txt
semgrep --config=auto app/

# Container scan
trivy image devops-api:1.0.0

# DAST (requires running container)
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t http://localhost:8000
```

### Security Best Practices

- ✅ Non-root container user
- ✅ Multi-stage builds (minimal attack surface)
- ✅ No secrets in code/Dockerfile
- ✅ Regular dependency updates
- ✅ Automated vulnerability scanning
- ✅ Security headers in responses

See [docs/SECURITY.md](docs/SECURITY.md) for detailed security guide.

## 📁 Project Structure

```
devops-api/
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions pipeline
├── app/
│   ├── __init__.py
│   └── main.py                    # FastAPI application (< 150 lines)
├── docs/
│   ├── DOCKER.md                  # Docker documentation
│   ├── KUBERNETES.md              # K8s deployment guide
│   ├── OBSERVABILITY.md           # Metrics, logs, traces
│   ├── SECURITY.md                # Security scanning guide
│   ├── GITHUB_WORKFLOW.md         # Git workflow & issues
│   └── FINAL_REPORT.md            # Professional project report
├── k8s/
│   ├── deployment.yaml            # K8s Deployment (3 replicas)
│   ├── service.yaml               # NodePort Service
│   ├── configmap.yaml             # Configuration
│   └── hpa.yaml                   # HorizontalPodAutoscaler
├── monitoring/
│   └── prometheus.yml             # Prometheus configuration
├── tests/
│   ├── __init__.py
│   └── test_main.py               # Unit tests
├── .bandit                         # Bandit config
├── .dockerignore                   # Docker ignore rules
├── .gitignore                      # Git ignore rules
├── .zap/
│   └── rules.tsv                   # ZAP scanning rules
├── docker-compose.yml              # Multi-service stack
├── Dockerfile                      # Multi-stage build
├── requirements.txt                # Python dependencies
├── requirements-dev.txt            # Dev dependencies
└── README.md                       # This file
```

## 🤝 Contributing

Contributions welcome! Please follow these steps:

1. **Check Issues**: Look for existing issues or create one
2. **Fork Repository**: Create your fork on GitHub
3. **Create Branch**: `git checkout -b feature/your-feature`
4. **Make Changes**: Follow code style and add tests
5. **Run Tests**: Ensure all tests pass
6. **Commit**: Use [Conventional Commits](https://www.conventionalcommits.org/)
7. **Push**: `git push origin feature/your-feature`
8. **Open PR**: Describe changes and link related issue

See [docs/GITHUB_WORKFLOW.md](docs/GITHUB_WORKFLOW.md) for detailed workflow.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built as a comprehensive DevOps learning project demonstrating:
- Modern backend development (Python/FastAPI)
- Container-first architecture (Docker)
- Cloud-native deployment (Kubernetes)
- Automated delivery (CI/CD)
- Production observability (Metrics, Logs, Traces)
- Security-first development (SAST, DAST, Container Scanning)

## 📞 Support

- **Documentation**: See [docs/](docs/) directory
- **Issues**: [GitHub Issues](https://github.com/YOUR_USERNAME/devops-api/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/devops-api/discussions)

## 🚦 Status

![Build](https://img.shields.io/badge/build-passing-brightgreen)
![Tests](https://img.shields.io/badge/tests-passing-brightgreen)
![Coverage](https://img.shields.io/badge/coverage-85%25-green)
![Security](https://img.shields.io/badge/security-passing-brightgreen)

---

**Happy Learning! 🎓**

Built with ❤️ for DevOps education
