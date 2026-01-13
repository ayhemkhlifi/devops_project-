# Security Guide - SAST & DAST Implementation

## Overview
Comprehensive security scanning integrated into CI/CD pipeline:
- **SAST** (Static Application Security Testing) - Scan code before building
- **DAST** (Dynamic Application Security Testing) - Scan running application
- **Container Scanning** - Scan Docker images for vulnerabilities
- **Dependency Scanning** - Check for vulnerable dependencies

## Security Architecture

```
┌─────────────────────────────────────────────────────┐
│              CI/CD Pipeline                         │
│                                                     │
│  Code Push                                          │
│      │                                              │
│      ▼                                              │
│  ┌─────────────────┐                               │
│  │  SAST Scanning  │                               │
│  │  • Bandit       │ → Python security issues      │
│  │  • Semgrep      │ → Code patterns & bugs        │
│  └────────┬────────┘                               │
│           │                                         │
│           ▼                                         │
│  ┌─────────────────┐                               │
│  │  Build Image    │                               │
│  └────────┬────────┘                               │
│           │                                         │
│           ▼                                         │
│  ┌─────────────────┐                               │
│  │ Container Scan  │                               │
│  │  • Trivy        │ → OS & package vulnerabilities│
│  └────────┬────────┘                               │
│           │                                         │
│           ▼                                         │
│  ┌─────────────────┐                               │
│  │     Deploy      │                               │
│  └────────┬────────┘                               │
│           │                                         │
│           ▼                                         │
│  ┌─────────────────┐                               │
│  │  DAST Scanning  │                               │
│  │  • OWASP ZAP    │ → Runtime vulnerabilities     │
│  └─────────────────┘                               │
└─────────────────────────────────────────────────────┘
```

## 1. SAST - Static Application Security Testing

### Tool 1: Bandit
**Purpose**: Python-specific security linter
**What it checks**:
- SQL injection patterns
- Hardcoded passwords
- Insecure SSL/TLS usage
- Unsafe YAML/pickle usage
- Command injection vulnerabilities
- Cryptographic weaknesses

#### Configuration
File: [.bandit](../.bandit)
```toml
[bandit]
exclude_dirs = ["/tests", "/venv"]
tests = ["B201", "B301", ...]  # Security test IDs
```

#### Running Locally
```bash
# Install
pip install bandit

# Run scan
bandit -r app/ -f json -o bandit-report.json
bandit -r app/ -f txt

# View results
cat bandit-report.txt
```

#### Example Output
```
Test results:
>> Issue: [B201:flask_debug_true] Flask app appears to be run with debug=True
   Severity: High   Confidence: High
   Location: app/main.py:5
   More Info: https://bandit.readthedocs.io/en/latest/plugins/b201_flask_debug_true.html

>> Issue: [B608:hardcoded_sql_expressions] Possible SQL injection vector
   Severity: Medium   Confidence: Low
   Location: app/database.py:23
```

#### Common Issues & Fixes

**❌ B201: Debug Mode Enabled**
```python
# Bad
app.run(debug=True)

# Good
app.run(debug=False)
```

**❌ B608: SQL Injection**
```python
# Bad
query = f"SELECT * FROM users WHERE id = {user_id}"

# Good
query = "SELECT * FROM users WHERE id = ?"
cursor.execute(query, (user_id,))
```

**❌ B105: Hardcoded Password**
```python
# Bad
PASSWORD = "admin123"

# Good
import os
PASSWORD = os.getenv("DB_PASSWORD")
```

### Tool 2: Semgrep
**Purpose**: Multi-language semantic code scanner
**What it checks**:
- Security patterns
- Best practice violations
- Common bugs
- Framework-specific issues

#### Running Locally
```bash
# Install
pip install semgrep

# Run with auto-config (recommended)
semgrep --config=auto app/

# Run specific rulesets
semgrep --config=p/owasp-top-ten app/
semgrep --config=p/python app/
```

#### Example Output
```
Findings:
  app/main.py
   rule:python.lang.security.audit.avoid-bind-to-all-interfaces
     Message: Binding to all interfaces (0.0.0.0) can be dangerous in production
     Line: 95
     Severity: WARNING
```

## 2. Container Scanning - Trivy

**Purpose**: Comprehensive container vulnerability scanner
**What it checks**:
- OS package vulnerabilities (CVEs)
- Application dependency vulnerabilities
- Misconfigurations
- Secrets in images

### Running Locally
```bash
# Install Trivy
# Windows (using Chocolatey)
choco install trivy

# Scan image
trivy image devops-api:1.0.0

# Scan with severity filter
trivy image --severity HIGH,CRITICAL devops-api:1.0.0

# Generate SARIF report
trivy image --format sarif --output trivy-report.sarif devops-api:1.0.0
```

### Example Output
```
devops-api:1.0.0 (debian 12.0)
===================================
Total: 15 (CRITICAL: 2, HIGH: 5, MEDIUM: 8)

┌───────────────┬────────────────┬──────────┬────────────────┬───────────────┐
│   Library     │ Vulnerability  │ Severity │ Installed Ver  │  Fixed Ver    │
├───────────────┼────────────────┼──────────┼────────────────┼───────────────┤
│ openssl       │ CVE-2023-12345 │ CRITICAL │ 3.0.2-1        │ 3.0.2-2       │
│ urllib3       │ CVE-2023-67890 │ HIGH     │ 1.26.5         │ 2.0.7         │
└───────────────┴────────────────┴──────────┴────────────────┴───────────────┘
```

### Remediation
```dockerfile
# Update base image to patched version
FROM python:3.11-slim

# Upgrade packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Update Python packages
RUN pip install --upgrade urllib3
```

## 3. DAST - Dynamic Application Security Testing

### Tool: OWASP ZAP (Zed Attack Proxy)
**Purpose**: Automated web application security scanner
**What it checks**:
- SQL Injection
- Cross-Site Scripting (XSS)
- Cross-Site Request Forgery (CSRF)
- Insecure authentication
- Security misconfigurations
- Sensitive data exposure

### Running Locally with Docker

#### Step 1: Start Application
```bash
docker run -d -p 8000:8000 --name api-test devops-api:1.0.0
```

#### Step 2: Run ZAP Baseline Scan
```bash
docker run -v $(pwd):/zap/wrk:rw \
  -t owasp/zap2docker-stable zap-baseline.py \
  -t http://host.docker.internal:8000 \
  -r zap-report.html \
  -J zap-report.json
```

#### Step 3: View Results
```bash
# HTML report
open zap-report.html  # or start zap-report.html on Windows

# JSON for automation
cat zap-report.json | jq '.site[0].alerts'
```

### Example Findings

#### ⚠️ Finding 1: Missing Security Headers
```
Alert: Missing Anti-clickjacking Header
Risk: Medium
Confidence: High
URL: http://localhost:8000/
Description: X-Frame-Options header is not set

Solution: Add header in response
```

**Fix**:
```python
from fastapi.middleware.cors import CORSMiddleware

@app.middleware("http")
async def security_headers(request: Request, call_next):
    response = await call_next(request)
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    return response
```

#### ⚠️ Finding 2: Information Disclosure
```
Alert: Server Leaks Version Information
Risk: Low
Confidence: High
Description: Server header reveals technology stack

Solution: Remove or obscure server header
```

**Fix**:
```python
@app.middleware("http")
async def remove_server_header(request: Request, call_next):
    response = await call_next(request)
    response.headers.pop("Server", None)
    return response
```

### ZAP Configuration
File: [.zap/rules.tsv](../.zap/rules.tsv)
```
# rule_id  IGNORE|WARN|FAIL  description
10021     IGNORE            X-Content-Type-Options (dev)
40018     FAIL              SQL Injection
```

## 4. Dependency Scanning

### Tool: pip-audit
```bash
# Install
pip install pip-audit

# Scan for vulnerable dependencies
pip-audit

# Generate JSON report
pip-audit --format json > vulnerabilities.json
```

### Example Output
```
Found 2 known vulnerabilities in 1 package
Name    Version  ID              Fix Versions
------  -------  --------------  ------------
urllib3 1.26.5   PYSEC-2023-123  2.0.7
urllib3 1.26.5   PYSEC-2023-456  2.0.7
```

### Fix
Update [requirements.txt](../requirements.txt):
```txt
urllib3>=2.0.7  # Fixed CVE-2023-123 and CVE-2023-456
```

## Security in CI/CD Pipeline

### Pipeline Security Flow
```yaml
jobs:
  security-sast:
    steps:
      - Run Bandit        # Check code security
      - Run Semgrep       # Check patterns
      - Upload reports    # Store findings

  build:
    steps:
      - Build image
      - Run Trivy         # Check container
      - Fail if CRITICAL  # Block deployment

  deploy:
    steps:
      - Deploy to K8s
  
  security-dast:
    steps:
      - Run OWASP ZAP     # Test running app
      - Upload report
```

### Security Gates
```yaml
# Fail build on critical vulnerabilities
- name: Check Trivy results
  run: |
    CRITICAL=$(jq '.Results[].Vulnerabilities[] | select(.Severity=="CRITICAL") | length' trivy-report.json)
    if [ "$CRITICAL" -gt 0 ]; then
      echo "Found $CRITICAL critical vulnerabilities"
      exit 1
    fi
```

## Best Practices Summary

### ✅ SAST Best Practices
1. Run on every commit
2. Fail fast on critical issues
3. Integrate with IDE (pre-commit hooks)
4. Maintain security baseline
5. Regular tool updates

### ✅ DAST Best Practices
1. Run against staging environment
2. Schedule regular scans
3. Test authenticated endpoints
4. Include custom test cases
5. Monitor false positives

### ✅ Container Security
1. Use minimal base images
2. Scan before deployment
3. Automate vulnerability patching
4. Version pin dependencies
5. Sign images (Docker Content Trust)

### ✅ Dependency Management
1. Regular dependency updates
2. Automated vulnerability scanning
3. Lock file usage (requirements.txt with versions)
4. Private package repository
5. License compliance checks

## Security Metrics

Track and report:
- **Vulnerability Count**: By severity (Critical/High/Medium/Low)
- **Mean Time to Remediate (MTTR)**: How fast vulnerabilities are fixed
- **Scan Coverage**: % of code/containers scanned
- **False Positive Rate**: Accuracy of findings
- **Security Debt**: Outstanding vulnerabilities over time

## Example Security Dashboard

```
╔════════════════════════════════════════╗
║       Security Scan Summary            ║
╠════════════════════════════════════════╣
║ SAST (Bandit)                          ║
║   Critical: 0                          ║
║   High:     2  ⚠️                      ║
║   Medium:   5                          ║
╠════════════════════════════════════════╣
║ Container Scan (Trivy)                 ║
║   Critical: 1  ❌                      ║
║   High:     3  ⚠️                      ║
║   Medium:   12                         ║
╠════════════════════════════════════════╣
║ DAST (OWASP ZAP)                       ║
║   High:     0                          ║
║   Medium:   3                          ║
║   Low:      8                          ║
╠════════════════════════════════════════╣
║ Status: ❌ BLOCKED - 1 Critical        ║
║ Action: Fix openssl CVE-2023-12345    ║
╚════════════════════════════════════════╝
```

## Remediation Workflow

```
1. Scan identifies vulnerability
         ↓
2. Create GitHub Issue automatically
         ↓
3. Assign to developer
         ↓
4. Developer fixes & commits
         ↓
5. CI/CD re-scans
         ↓
6. Verify fix & close issue
```

## Tools Comparison

| Tool      | Type      | Language | Speed | Accuracy | Cost  |
|-----------|-----------|----------|-------|----------|-------|
| Bandit    | SAST      | Python   | Fast  | High     | Free  |
| Semgrep   | SAST      | Multi    | Fast  | High     | Free  |
| Trivy     | Container | Multi    | Fast  | High     | Free  |
| OWASP ZAP | DAST      | Web      | Slow  | Medium   | Free  |

## Conclusion

Security scanning is integrated at every stage:
- **Pre-commit**: IDE plugins (Bandit, Semgrep)
- **CI**: Automated SAST + container scanning
- **Post-deploy**: DAST scans on live environment
- **Continuous**: Scheduled scans + monitoring

**Result**: Multiple layers of security defense, vulnerabilities caught early, production risk minimized.
