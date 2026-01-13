# DevOps Project - Production-Ready REST API

> A complete DevOps project demonstrating CI/CD, containerization, Kubernetes orchestration, observability, and security best practices.

[![CI/CD Pipeline](https://github.com/ayhemkhlifi/devops_project-/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/ayhemkhlifi/devops_project-/actions)

---

## 🚀 What This Project Does

A **FastAPI REST API** with full DevOps automation:

- ✅ **CI/CD Pipeline** - Automated testing, security scanning, and deployment
- ✅ **Docker** - Multi-stage build (~200MB optimized image)
- ✅ **Kubernetes** - 3 replicas with auto-scaling (2-10 pods)
- ✅ **Observability** - Prometheus metrics, Grafana dashboards, structured logs
- ✅ **Security** - SAST (Bandit, Semgrep), DAST (OWASP ZAP), container scanning (Trivy)

---

## 📁 Project Structure

```
devops/
├── app/                    # FastAPI application
├── tests/                  # Unit tests
├── k8s/                    # Kubernetes manifests
├── .github/workflows/      # CI/CD pipeline
├── monitoring/             # Prometheus config
├── Dockerfile              # Multi-stage Docker build
└── docker-compose.yml      # Full stack (API + Prometheus + Grafana)
```

---

## 🏃 Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# Start all services
docker-compose up -d

# Access:
# - API: http://localhost:8000/docs
# - Prometheus: http://localhost:9090
# - Grafana: http://localhost:3000 (admin/admin)
```

### Option 2: Local Python

```bash
# Install dependencies
pip install -r requirements.txt

# Run application
uvicorn app.main:app --reload

# Access: http://localhost:8000/docs
```

### Option 3: Kubernetes

```bash
# Start Minikube
minikube start

# Deploy
kubectl apply -f k8s/

# Access
kubectl port-forward service/devops-api-service 8080:8000
# Open: http://localhost:8080/docs
```

---

## 🔥 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/items` | List all items |
| POST | `/items` | Create new item |
| GET | `/docs` | Interactive API docs |
| GET | `/metrics` | Prometheus metrics |

**Test it:**
```bash
curl http://localhost:8000/health
curl http://localhost:8000/docs
```

---

## 🔄 CI/CD Pipeline

**Location:** `.github/workflows/ci-cd.yml`

**Pipeline Stages:**
1. **Test & Code Quality** - pytest with 85%+ coverage
2. **Security SAST** - Bandit + Semgrep static analysis
3. **Build Docker Image** - Multi-stage build + Trivy scan
4. **Security DAST** - OWASP ZAP dynamic testing

**Results:**
- ✅ 0 Critical vulnerabilities
- ✅ 66 security checks passed
- ✅ All tests passing

**View:** [GitHub Actions](https://github.com/ayhemkhlifi/devops_project-/actions)

---

## 📊 Observability

### Metrics
- **Endpoint:** `http://localhost:8000/metrics`
- **Prometheus:** `http://localhost:9090`
- **Grafana:** `http://localhost:3000`

**Available Metrics:**
- `api_requests_total` - Total requests
- `api_request_duration_seconds` - Response time

### Logs
```bash
# Docker logs
docker logs devops-api

# Kubernetes logs
kubectl logs -l app=devops-api
```

Structured JSON format with trace IDs for request correlation.

---

## 🔒 Security

### Static Analysis (SAST)
- **Bandit** - Python security linter
- **Semgrep** - Code pattern analyzer

### Dynamic Analysis (DAST)
- **OWASP ZAP** - Web application security scanner
- Results: 0 failures, 66 passed checks

### Container Security
- **Trivy** - Vulnerability scanner
- **Non-root user** in container
- **Minimal base image** (python:3.12-slim)

---

## ☸️ Kubernetes Features

- **3 Replicas** - High availability
- **Auto-scaling** - HPA (2-10 pods based on CPU/memory)
- **Health Checks** - Liveness and readiness probes
- **Resource Limits** - CPU and memory constraints
- **Rolling Updates** - Zero-downtime deployments

**Commands:**
```bash
kubectl get all                     # View all resources
kubectl get pods                    # View pods
kubectl logs -l app=devops-api      # View logs
kubectl describe hpa                # View auto-scaler
```

---

## 🐳 Docker

**Build:**
```bash
docker build -t devops-api:1.0.0 .
```

**Run:**
```bash
docker run -d -p 8000:8000 devops-api:1.0.0
```

**Features:**
- Multi-stage build (60% size reduction)
- Non-root user for security
- Health checks included
- Optimized layer caching

---

## 🧪 Testing

```bash
# Run tests
pytest tests/ -v

# With coverage
pytest tests/ --cov=app --cov-report=html

# View coverage report
open htmlcov/index.html
```

**Coverage:** 85%+

---

## 📚 Documentation

- **API Docs:** http://localhost:8000/docs (Swagger UI)
- **ReDoc:** http://localhost:8000/redoc
- **Detailed Docs:** See `docs/` folder

---

## 🛠️ Tech Stack

- **Language:** Python 3.12
- **Framework:** FastAPI
- **Container:** Docker
- **Orchestration:** Kubernetes (Minikube)
- **CI/CD:** GitHub Actions
- **Monitoring:** Prometheus + Grafana
- **Testing:** pytest
- **Security:** Bandit, Semgrep, OWASP ZAP, Trivy

---

## 📈 Project Status

✅ **COMPLETE & PRODUCTION-READY**

- [x] REST API implementation
- [x] Unit tests (85%+ coverage)
- [x] Docker containerization
- [x] Kubernetes deployment
- [x] CI/CD pipeline
- [x] Observability (metrics, logs, tracing)
- [x] Security scanning (SAST + DAST)
- [x] Complete documentation

---

## 👨‍💻 Author

**DevOps Learning Project**

For educational purposes demonstrating modern DevOps practices.

---

## 📝 License

MIT License - See [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

This is a learning project. Feel free to fork and experiment!

---

**⭐ If you find this project helpful, please star it on GitHub!**
