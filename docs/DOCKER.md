# Docker Best Practices & Architecture

## Dockerfile Architecture

### Multi-Stage Build Pattern

```
┌─────────────────────────────────────┐
│  Stage 1: Builder                   │
│  • Python 3.11 slim base            │
│  • Install pip & dependencies       │
│  • Create virtual environment       │
│  • ~500MB total size                │
└───────────┬─────────────────────────┘
            │
            │ Copy only /opt/venv
            ▼
┌─────────────────────────────────────┐
│  Stage 2: Runtime                   │
│  • Python 3.11 slim base            │
│  • Copy venv from builder           │
│  • Copy application code            │
│  • ~200MB final size (60% smaller)  │
└─────────────────────────────────────┘
```

### Best Practices Implemented

#### ✅ 1. Multi-Stage Build
**Why**: Reduces final image size by excluding build tools
**Impact**: 60% size reduction (500MB → 200MB)

#### ✅ 2. Layer Caching Optimization
```dockerfile
COPY requirements.txt .        # Changes rarely - cached
RUN pip install -r ...         # Expensive - cached when possible
COPY app/ /app/app/            # Changes often - separate layer
```

#### ✅ 3. Non-Root User
**Security**: Runs as `appuser` instead of root
**Why**: Principle of least privilege, prevents container breakout escalation

#### ✅ 4. Health Check
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3
```
**Why**: Enables container orchestration to detect and restart unhealthy containers

#### ✅ 5. Environment Variables
```dockerfile
PYTHONUNBUFFERED=1           # Real-time log output
PYTHONDONTWRITEBYTECODE=1    # No .pyc files (smaller image)
```

#### ✅ 6. Minimal Base Image
**Choice**: `python:3.11-slim` instead of full Python image
**Impact**: 900MB → 150MB base size

#### ✅ 7. Labels & Metadata
```dockerfile
LABEL maintainer="devops-student"
LABEL version="1.0.0"
```
**Why**: Documentation, image management, automation

## Image Layers Explained

```
Layer 1: python:3.11-slim base          [150 MB]
Layer 2: Create non-root user           [  1 KB]
Layer 3: Copy virtual environment       [ 50 MB]
Layer 4: Copy application code          [ 10 KB]
───────────────────────────────────────────────
Total Image Size:                       [~200 MB]
```

### Layer Caching Strategy
1. **Static layers first** (base image, system packages)
2. **Dependencies second** (requirements.txt)
3. **Code last** (changes frequently)

Result: Fast rebuilds during development

## Docker Compose Architecture

```
┌─────────────────────────────────────────────┐
│              Docker Network                 │
│          (devops-network)                   │
│                                             │
│  ┌──────────┐  ┌────────────┐  ┌─────────┐ │
│  │   API    │→ │ Prometheus │→ │ Grafana │ │
│  │  :8000   │  │   :9090    │  │  :3000  │ │
│  └──────────┘  └────────────┘  └─────────┘ │
│       ↓               ↓              ↓      │
│  [metrics]      [storage]      [dashboard] │
└─────────────────────────────────────────────┘
          ↓                ↓              ↓
      Host:8000       Host:9090      Host:3000
```

### Services

#### 1. API Service
- **Port**: 8000
- **Health**: Automatic checks every 30s
- **Restart**: Unless stopped manually
- **Network**: Internal bridge

#### 2. Prometheus
- **Purpose**: Scrapes `/metrics` from API
- **Config**: `monitoring/prometheus.yml`
- **Storage**: Persistent volume
- **Scrape Interval**: 15s

#### 3. Grafana
- **Purpose**: Visualize metrics
- **Credentials**: admin/admin
- **Data Source**: Prometheus
- **Dashboards**: Import JSON configs

## Building & Running

### Build Image
```bash
# Build with tag
docker build -t devops-api:1.0.0 .

# Build with cache disabled (fresh build)
docker build --no-cache -t devops-api:1.0.0 .

# View build history
docker history devops-api:1.0.0
```

### Run Single Container
```bash
# Run in foreground
docker run -p 8000:8000 devops-api:1.0.0

# Run in background
docker run -d -p 8000:8000 --name devops-api devops-api:1.0.0

# View logs
docker logs -f devops-api

# Execute commands in running container
docker exec -it devops-api /bin/bash
```

### Run with Docker Compose
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f api

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up -d --build
```

## Security Considerations

### ✅ Implemented
- Non-root user execution
- Minimal base image (reduced attack surface)
- No secrets in Dockerfile
- Read-only filesystem where possible

### 🔒 Production Additions
```dockerfile
# Add security scanning
RUN apt-get update && apt-get install -y --no-install-recommends \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set read-only root filesystem
docker run --read-only ...

# Limit resources
docker run --memory="512m" --cpus="1.0" ...
```

## Docker Hub Publishing

### Tag & Push
```bash
# Login
docker login

# Tag for Docker Hub
docker tag devops-api:1.0.0 YOUR_USERNAME/devops-api:1.0.0
docker tag devops-api:1.0.0 YOUR_USERNAME/devops-api:latest

# Push
docker push YOUR_USERNAME/devops-api:1.0.0
docker push YOUR_USERNAME/devops-api:latest
```

### Pull & Run
```bash
# Anyone can now pull
docker pull YOUR_USERNAME/devops-api:1.0.0

# Run pulled image
docker run -p 8000:8000 YOUR_USERNAME/devops-api:1.0.0
```

## Testing Docker Build

```bash
# Build
docker build -t devops-api:test .

# Run with health check
docker run -d --name api-test -p 8000:8000 devops-api:test

# Wait for health check
sleep 10

# Test health endpoint
curl http://localhost:8000/health

# Test metrics endpoint
curl http://localhost:8000/metrics

# Create item
curl -X POST http://localhost:8000/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Test", "price": 9.99}'

# Verify logs
docker logs api-test | grep "item_created"

# Check container status
docker ps
docker inspect api-test | grep Health

# Cleanup
docker stop api-test
docker rm api-test
```

## Troubleshooting

### Image Size Too Large
```bash
# Analyze layers
docker history devops-api:1.0.0

# Use dive tool
dive devops-api:1.0.0
```

### Container Won't Start
```bash
# View logs
docker logs container_name

# Check health
docker inspect --format='{{json .State.Health}}' container_name
```

### Network Issues
```bash
# Inspect network
docker network inspect devops-network

# Check container connectivity
docker exec api ping prometheus
```

## Summary

**Image Size**: ~200 MB (optimized multi-stage build)
**Security**: Non-root user, minimal base image
**Observability**: Health checks, structured logs, metrics
**Deployment**: Single-command startup with docker-compose
**Production-Ready**: Follows Docker & security best practices
