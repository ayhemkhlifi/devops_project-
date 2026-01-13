# GitHub Workflow & Issues Management

## Overview
This document outlines the GitHub workflow, issue tracking, branch strategy, and pull request process for the DevOps Learning Project.

## Repository Structure

```
devops-learning-api/
├── .github/
│   ├── workflows/
│   │   └── ci-cd.yml              # CI/CD pipeline
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       ├── feature_request.md
│       └── security_issue.md
├── app/                            # Application code
├── tests/                          # Test suite
├── k8s/                            # Kubernetes manifests
├── docs/                           # Documentation
└── monitoring/                     # Observability configs
```

## Branch Strategy

### Main Branches
```
main (production)
  ├── develop (staging/integration)
      ├── feature/* (new features)
      ├── bugfix/* (bug fixes)
      ├── hotfix/* (urgent production fixes)
      └── docs/* (documentation updates)
```

### Branch Naming Convention
- `feature/add-authentication`
- `bugfix/fix-metrics-endpoint`
- `hotfix/security-patch-cve-2024`
- `docs/update-kubernetes-guide`

### Protection Rules

#### Main Branch
```yaml
- Require pull request before merging
- Require status checks to pass:
  - test
  - security-sast
  - build
- Require code review (1 approval)
- No force pushes
- No direct commits
```

#### Develop Branch
```yaml
- Require pull request
- Require status checks to pass:
  - test
- Allow force push with lease
```

## GitHub Issues

### Issue Templates

Create 7 issues for the project lifecycle:

---

### Issue #1: Backend Implementation
**Label**: `enhancement`, `backend`, `priority:high`

```markdown
## Description
Implement REST API backend service with FastAPI

## Requirements
- [ ] Create FastAPI application
- [ ] Implement GET /health endpoint
- [ ] Implement GET /items endpoint
- [ ] Implement POST /items endpoint
- [ ] Add input validation using Pydantic
- [ ] Add structured logging
- [ ] Keep total code under 150 lines
- [ ] Write unit tests

## Acceptance Criteria
- All endpoints return correct responses
- Input validation works
- Tests pass with >80% coverage
- Code follows PEP 8 style guide

## Technical Details
- Framework: FastAPI 0.109.0
- Python: 3.11
- Validation: Pydantic models

## Estimated Time
4 hours
```

---

### Issue #2: Dockerization
**Label**: `enhancement`, `docker`, `priority:high`

```markdown
## Description
Containerize the application using Docker best practices

## Requirements
- [ ] Write Dockerfile with multi-stage build
- [ ] Minimize image size (<250MB)
- [ ] Run as non-root user
- [ ] Add health check
- [ ] Create docker-compose.yml
- [ ] Include Prometheus and Grafana services
- [ ] Document Docker commands

## Acceptance Criteria
- Image builds successfully
- Container passes health checks
- All services communicate on Docker network
- Documentation includes build/run instructions

## Technical Details
- Base image: python:3.11-slim
- Pattern: Multi-stage build
- Tools: Docker, Docker Compose

## Estimated Time
3 hours
```

---

### Issue #3: CI/CD Pipeline
**Label**: `enhancement`, `ci-cd`, `priority:critical`

```markdown
## Description
Implement complete CI/CD pipeline using GitHub Actions

## Requirements
- [ ] Create .github/workflows/ci-cd.yml
- [ ] Add test job (pytest + coverage)
- [ ] Add security scanning (Bandit, Semgrep)
- [ ] Add Docker build & push
- [ ] Add container scanning (Trivy)
- [ ] Add deployment to Kubernetes
- [ ] Add DAST scanning (OWASP ZAP)
- [ ] Configure required secrets

## Acceptance Criteria
- Pipeline runs on every push/PR
- All tests pass
- Security scans complete
- Docker image pushed to registry
- Deployment successful

## Technical Details
- Platform: GitHub Actions
- Triggers: push, pull_request
- Jobs: test, security-sast, build, deploy, security-dast

## Secrets Required
- DOCKERHUB_USERNAME
- DOCKERHUB_TOKEN
- KUBE_CONFIG

## Estimated Time
6 hours
```

---

### Issue #4: Observability Implementation
**Label**: `enhancement`, `observability`, `priority:high`

```markdown
## Description
Add comprehensive observability (metrics, logs, tracing)

## Requirements
- [ ] Add Prometheus metrics endpoint
- [ ] Implement request counter metric
- [ ] Implement request duration histogram
- [ ] Add structured JSON logging
- [ ] Add distributed trace IDs
- [ ] Create Prometheus configuration
- [ ] Document observability architecture

## Acceptance Criteria
- /metrics endpoint returns Prometheus format
- All requests logged as JSON
- Trace IDs present in logs and headers
- Prometheus scrapes metrics successfully
- Documentation includes examples

## Technical Details
- Metrics: prometheus-client
- Format: JSON logs
- Trace ID: UUID v4

## Estimated Time
4 hours
```

---

### Issue #5: Security Scanning
**Label**: `enhancement`, `security`, `priority:critical`

```markdown
## Description
Implement security scanning (SAST, DAST, container scanning)

## Requirements
- [ ] Configure Bandit for Python SAST
- [ ] Configure Semgrep for pattern matching
- [ ] Add Trivy for container scanning
- [ ] Configure OWASP ZAP for DAST
- [ ] Create security documentation
- [ ] Add remediation examples
- [ ] Integrate scans into CI/CD

## Acceptance Criteria
- All security scanners run in pipeline
- Reports generated and uploaded
- Critical vulnerabilities block deployment
- Documentation includes fix examples

## Technical Details
- SAST: Bandit, Semgrep
- Container: Trivy
- DAST: OWASP ZAP

## Estimated Time
5 hours
```

---

### Issue #6: Kubernetes Deployment
**Label**: `enhancement`, `kubernetes`, `priority:high`

```markdown
## Description
Deploy application to Kubernetes with production-ready configuration

## Requirements
- [ ] Create Deployment manifest (3 replicas)
- [ ] Create Service manifest (NodePort)
- [ ] Create ConfigMap for configuration
- [ ] Create HorizontalPodAutoscaler
- [ ] Add liveness/readiness probes
- [ ] Set resource limits/requests
- [ ] Document deployment steps
- [ ] Create troubleshooting guide

## Acceptance Criteria
- Application deploys successfully
- Health checks pass
- Service accessible externally
- Auto-scaling configured
- Documentation complete

## Technical Details
- Platform: Minikube/Kind
- Replicas: 3
- Service: NodePort :30080

## Estimated Time
5 hours
```

---

### Issue #7: Documentation
**Label**: `documentation`, `priority:medium`

```markdown
## Description
Create comprehensive project documentation

## Requirements
- [ ] Write main README.md
- [ ] Create architecture diagram
- [ ] Document API endpoints with examples
- [ ] Document Docker usage
- [ ] Document Kubernetes deployment
- [ ] Document CI/CD pipeline
- [ ] Document observability
- [ ] Document security practices
- [ ] Write final project report

## Acceptance Criteria
- README is beginner-friendly
- All commands documented and tested
- Architecture diagrams included
- Examples are copy-paste ready
- Final report is professional (1-2 pages)

## Technical Details
- Format: Markdown
- Diagrams: ASCII art acceptable
- Sections: Setup, Usage, Deployment, CI/CD

## Estimated Time
6 hours
```

---

## Pull Request Workflow

### Creating a Pull Request

#### 1. Create Branch
```bash
# From develop branch
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/backend-implementation

# Make changes
# ...

# Commit
git add .
git commit -m "feat: implement REST API endpoints"

# Push
git push origin feature/backend-implementation
```

#### 2. Open PR
```markdown
Title: feat: Implement REST API endpoints

## Description
Implements the backend REST API with FastAPI including health check and items endpoints.

## Related Issue
Closes #1

## Changes
- ✅ Added FastAPI application setup
- ✅ Implemented GET /health endpoint
- ✅ Implemented GET /items endpoint
- ✅ Implemented POST /items endpoint
- ✅ Added Pydantic validation models
- ✅ Added structured logging
- ✅ Wrote unit tests (coverage: 85%)

## Testing
```bash
# Install dependencies
pip install -r requirements.txt -r requirements-dev.txt

# Run tests
pytest tests/ -v --cov=app

# Start server
uvicorn app.main:app --reload

# Test endpoints
curl http://localhost:8000/health
curl http://localhost:8000/items
```

## Checklist
- [x] Code follows style guide (PEP 8)
- [x] Tests pass locally
- [x] Tests added/updated
- [x] Documentation updated
- [x] No breaking changes
- [x] CI/CD pipeline passes

## Screenshots
(Attach test results, coverage report)
```

### Pull Request Review Process

#### Reviewer 1 Comments (Constructive)
```markdown
## Review Summary
Overall great implementation! Just a few suggestions for improvement.

### ✅ Strengths
- Clean code structure
- Good test coverage (85%)
- Proper error handling
- Excellent logging implementation

### 💭 Suggestions

**1. Validation Enhancement (Minor)**
`app/main.py:45`
```python
# Current
@validator('name')
def name_must_not_be_empty(cls, v):
    if not v.strip():
        raise ValueError('Name cannot be empty')
    return v.strip()

# Suggestion: Add length validation
@validator('name')
def validate_name(cls, v):
    v = v.strip()
    if not v:
        raise ValueError('Name cannot be empty')
    if len(v) < 3:
        raise ValueError('Name must be at least 3 characters')
    return v
```

**2. Documentation (Minor)**
Consider adding docstrings to all endpoints:
```python
@app.get("/items")
async def get_items():
    """
    Retrieve all items.
    
    Returns:
        List[Item]: List of all items in the database
    """
    return items_db
```

**3. Performance (Optional)**
For large datasets, consider adding pagination:
```python
@app.get("/items")
async def get_items(skip: int = 0, limit: int = 100):
    return items_db[skip:skip+limit]
```

### 📝 Questions
1. Should we add rate limiting for the POST endpoint?
2. Do we need to persist items between restarts?

### ✅ Approval
Approved with minor suggestions. Feel free to address or create follow-up issues.

**Status**: ✅ APPROVED
```

#### Reviewer 2 Comments (Constructive)
```markdown
## Code Review

### Positive Feedback
- Excellent use of Pydantic for validation
- Structured logging is very clean
- Test coverage exceeds requirements

### Requested Changes

**1. Error Handling (Important)**
`app/main.py:78`
Add try-catch for database operations:
```python
@app.post("/items")
async def create_item(item: Item):
    try:
        item.id = str(uuid.uuid4())
        item.created_at = datetime.utcnow()
        items_db.append(item)
        logger.info(json.dumps({"event": "item_created", "item_id": item.id}))
        return item
    except Exception as e:
        logger.error(json.dumps({"event": "item_creation_failed", "error": str(e)}))
        raise HTTPException(status_code=500, detail="Failed to create item")
```

**2. Test Coverage Gap**
Missing test for invalid price validation:
```python
def test_create_item_price_too_high():
    item_data = {"name": "Expensive Item", "price": 2000000}
    response = client.post("/items", json=item_data)
    assert response.status_code == 422
```

**3. Code Style (Nitpick)**
Line 92: Consider breaking long line per PEP 8:
```python
# Current (>79 chars)
logger.info(json.dumps({"event": "request_completed", "method": request.method, "path": request.url.path, "status": response.status_code}))

# Better
logger.info(json.dumps({
    "event": "request_completed",
    "method": request.method,
    "path": request.url.path,
    "status": response.status_code
}))
```

### Verdict
**Status**: 🔄 CHANGES REQUESTED
Please address items 1 and 2, then I'll approve.
```

#### Author Response
```markdown
## Response to Review Comments

### @reviewer1

**1. Validation Enhancement**
✅ Implemented in commit abc123f

**2. Documentation**
✅ Added docstrings in commit def456g

**3. Pagination**
📝 Created issue #8 for pagination feature

### @reviewer2

**1. Error Handling**
✅ Added try-catch blocks in commit 789hij0

**2. Test Coverage Gap**
✅ Added test in commit 012klm3

**3. Code Style**
✅ Reformatted long lines in commit 345nop6

---

All requested changes implemented. Ready for re-review!
```

### Merging Strategy

```bash
# After approval
# Option 1: Squash and merge (for clean history)
git checkout develop
git merge --squash feature/backend-implementation
git commit -m "feat: implement REST API endpoints (#1)"

# Option 2: Merge commit (for full history)
git checkout develop
git merge --no-ff feature/backend-implementation

# Push to remote
git push origin develop
```

## Git Workflow Commands

### Daily Workflow
```bash
# Start work
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# During work
git add .
git commit -m "feat: add something"
git push origin feature/my-feature

# Update from develop
git checkout develop
git pull origin develop
git checkout feature/my-feature
git rebase develop

# Finish work
# Open PR on GitHub
# After approval and merge
git checkout develop
git pull origin develop
git branch -d feature/my-feature
```

### Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Tests
- `chore`: Build/tooling

**Examples**:
```
feat(api): add POST /items endpoint
fix(docker): resolve health check timeout
docs(readme): update installation steps
test(api): add validation tests
chore(deps): update fastapi to 0.109.0
```

## Project Timeline

```
Week 1: Backend & Testing
  │
  ├─ Issue #1: Backend Implementation (4h)
  └─ Issue #4: Observability (4h)

Week 2: Containerization
  │
  ├─ Issue #2: Docker (3h)
  └─ Issue #5: Security (5h)

Week 3: Orchestration & CI/CD
  │
  ├─ Issue #6: Kubernetes (5h)
  └─ Issue #3: CI/CD (6h)

Week 4: Documentation
  │
  └─ Issue #7: Documentation (6h)

Total: ~33 hours
```

## Labels & Milestones

### Labels
- `priority:critical` - Red
- `priority:high` - Orange
- `priority:medium` - Yellow
- `priority:low` - Green
- `type:bug` - Red
- `type:feature` - Blue
- `type:docs` - Purple
- `security` - Red
- `good-first-issue` - Green

### Milestones
1. **v1.0.0 - MVP Release**
   - All 7 issues complete
   - CI/CD functional
   - Documentation complete
   - Due: 4 weeks

## Summary

This workflow ensures:
- ✅ Organized issue tracking
- ✅ Clean branch management
- ✅ Quality code reviews
- ✅ Collaborative development
- ✅ Automated quality gates
- ✅ Production-ready releases
