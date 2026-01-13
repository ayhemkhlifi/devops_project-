# DevOps Project Setup Script
# This script helps you set up and verify the complete DevOps project

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DevOps Project Setup & Verification  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check command existence
function Test-Command {
    param($Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
Write-Host ""

$prerequisites = @{
    "Python" = "python --version"
    "Docker" = "docker --version"
    "Docker Compose" = "docker-compose --version"
    "Git" = "git --version"
}

$allPresent = $true
foreach ($prereq in $prerequisites.GetEnumerator()) {
    if (Test-Command $prereq.Value.Split()[0]) {
        $version = & $prereq.Value 2>&1
        Write-Host "  [OK] $($prereq.Key): $version" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $($prereq.Key)" -ForegroundColor Red
        $allPresent = $false
    }
}

Write-Host ""

if (-not $allPresent) {
    Write-Host "Some prerequisites are missing. Please install them before continuing." -ForegroundColor Red
    Write-Host ""
    Write-Host "Installation guides:"
    Write-Host "  - Python: https://www.python.org/downloads/"
    Write-Host "  - Docker: https://docs.docker.com/desktop/install/windows-install/"
    Write-Host "  - Git: https://git-scm.com/download/win"
    exit 1
}

# Optional tools
Write-Host "Checking optional tools..." -ForegroundColor Yellow
Write-Host ""

$optionalTools = @{
    "kubectl" = "kubectl version --client"
    "minikube" = "minikube version"
}

foreach ($tool in $optionalTools.GetEnumerator()) {
    if (Test-Command $tool.Value.Split()[0]) {
        $version = & $tool.Value 2>&1 | Select-Object -First 1
        Write-Host "  [OK] $($tool.Key): $version" -ForegroundColor Green
    } else {
        Write-Host "  [OPTIONAL] $($tool.Key) - Install for Kubernetes features" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup Options  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Setup Python virtual environment"
Write-Host "2. Run tests"
Write-Host "3. Build Docker image"
Write-Host "4. Run with Docker"
Write-Host "5. Run with Docker Compose (Full Stack)"
Write-Host "6. Initialize Git repository"
Write-Host "7. Verify entire project"
Write-Host "8. Clean up resources"
Write-Host "0. Exit"
Write-Host ""

$choice = Read-Host "Enter your choice (0-8)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Setting up Python virtual environment..." -ForegroundColor Yellow
        
        if (Test-Path "venv") {
            Write-Host "Virtual environment already exists." -ForegroundColor Yellow
        } else {
            python -m venv venv
            Write-Host "Virtual environment created." -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "Activating virtual environment..." -ForegroundColor Yellow
        & ".\venv\Scripts\Activate.ps1"
        
        Write-Host ""
        Write-Host "Installing dependencies..." -ForegroundColor Yellow
        pip install -r requirements.txt
        pip install -r requirements-dev.txt
        
        Write-Host ""
        Write-Host "[DONE] Virtual environment is ready!" -ForegroundColor Green
        Write-Host "Run: .\venv\Scripts\Activate.ps1" -ForegroundColor Cyan
    }
    
    "2" {
        Write-Host ""
        Write-Host "Running tests..." -ForegroundColor Yellow
        
        if (-not (Test-Path "venv")) {
            Write-Host "Virtual environment not found. Creating one..." -ForegroundColor Yellow
            python -m venv venv
            & ".\venv\Scripts\Activate.ps1"
            pip install -r requirements.txt -r requirements-dev.txt
        }
        
        Write-Host ""
        pytest tests/ -v --cov=app --cov-report=term --cov-report=html
        
        Write-Host ""
        Write-Host "[DONE] Tests completed!" -ForegroundColor Green
        Write-Host "Coverage report: htmlcov\index.html" -ForegroundColor Cyan
    }
    
    "3" {
        Write-Host ""
        Write-Host "Building Docker image..." -ForegroundColor Yellow
        
        docker build -t devops-api:1.0.0 .
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "[DONE] Docker image built successfully!" -ForegroundColor Green
            Write-Host "Image: devops-api:1.0.0" -ForegroundColor Cyan
            docker images devops-api:1.0.0
        }
    }
    
    "4" {
        Write-Host ""
        Write-Host "Running Docker container..." -ForegroundColor Yellow
        
        # Stop existing container if running
        docker stop devops-api 2>$null
        docker rm devops-api 2>$null
        
        docker run -d -p 8000:8000 --name devops-api devops-api:1.0.0
        
        if ($LASTEXITCODE -eq 0) {
            Start-Sleep -Seconds 3
            Write-Host ""
            Write-Host "[DONE] Container is running!" -ForegroundColor Green
            Write-Host "API: http://localhost:8000" -ForegroundColor Cyan
            Write-Host "Docs: http://localhost:8000/docs" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "View logs: docker logs -f devops-api" -ForegroundColor Yellow
        }
    }
    
    "5" {
        Write-Host ""
        Write-Host "Starting Docker Compose stack..." -ForegroundColor Yellow
        
        docker-compose up -d
        
        if ($LASTEXITCODE -eq 0) {
            Start-Sleep -Seconds 5
            Write-Host ""
            Write-Host "[DONE] All services are running!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Services:"
            Write-Host "  API:        http://localhost:8000" -ForegroundColor Cyan
            Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor Cyan
            Write-Host "  Grafana:    http://localhost:3000 (admin/admin)" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Stop services: docker-compose down" -ForegroundColor Yellow
        }
    }
    
    "6" {
        Write-Host ""
        Write-Host "Initializing Git repository..." -ForegroundColor Yellow
        
        if (Test-Path ".git") {
            Write-Host "Git repository already initialized." -ForegroundColor Yellow
        } else {
            git init
            Write-Host "Git repository initialized." -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "Creating initial commit..." -ForegroundColor Yellow
        git add .
        git commit -m "feat: initial commit - complete DevOps project"
        
        Write-Host ""
        Write-Host "[DONE] Repository initialized!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:"
        Write-Host "  1. Create repository on GitHub"
        Write-Host "  2. git remote add origin https://github.com/YOUR_USERNAME/devops-api.git"
        Write-Host "  3. git push -u origin main"
    }
    
    "7" {
        Write-Host ""
        Write-Host "Verifying entire project..." -ForegroundColor Yellow
        Write-Host ""
        
        # Check file structure
        Write-Host "Checking file structure..." -ForegroundColor Yellow
        $requiredFiles = @(
            "app\main.py",
            "tests\test_main.py",
            "Dockerfile",
            "docker-compose.yml",
            "requirements.txt",
            "README.md",
            "k8s\deployment.yaml",
            "k8s\service.yaml"
        )
        
        foreach ($file in $requiredFiles) {
            if (Test-Path $file) {
                Write-Host "  [OK] $file" -ForegroundColor Green
            } else {
                Write-Host "  [MISSING] $file" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Write-Host "Checking documentation..." -ForegroundColor Yellow
        $docs = Get-ChildItem "docs" -Filter "*.md"
        Write-Host "  Found $($docs.Count) documentation files" -ForegroundColor Green
        foreach ($doc in $docs) {
            Write-Host "    - $($doc.Name)" -ForegroundColor Cyan
        }
        
        Write-Host ""
        Write-Host "[DONE] Verification complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Project Summary:"
        Write-Host "  - Backend: Python/FastAPI" -ForegroundColor Cyan
        Write-Host "  - Docker: Multi-stage build" -ForegroundColor Cyan
        Write-Host "  - K8s: Production-ready manifests" -ForegroundColor Cyan
        Write-Host "  - CI/CD: GitHub Actions pipeline" -ForegroundColor Cyan
        Write-Host "  - Docs: $($docs.Count) comprehensive guides" -ForegroundColor Cyan
    }
    
    "8" {
        Write-Host ""
        Write-Host "Cleaning up resources..." -ForegroundColor Yellow
        
        Write-Host "Stopping Docker containers..."
        docker-compose down 2>$null
        docker stop devops-api 2>$null
        docker rm devops-api 2>$null
        
        Write-Host "Removing Python cache..."
        Get-ChildItem -Path . -Include __pycache__,*.pyc,*.pyo -Recurse | Remove-Item -Force -Recurse
        
        if (Test-Path "htmlcov") {
            Write-Host "Removing coverage reports..."
            Remove-Item -Path "htmlcov" -Recurse -Force
        }
        
        if (Test-Path ".pytest_cache") {
            Write-Host "Removing pytest cache..."
            Remove-Item -Path ".pytest_cache" -Recurse -Force
        }
        
        Write-Host ""
        Write-Host "[DONE] Cleanup complete!" -ForegroundColor Green
    }
    
    "0" {
        Write-Host ""
        Write-Host "Exiting... Goodbye!" -ForegroundColor Cyan
        exit 0
    }
    
    default {
        Write-Host ""
        Write-Host "Invalid choice. Please run the script again." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "For more information, see:" -ForegroundColor Yellow
Write-Host "  - README.md (main documentation)"
Write-Host "  - QUICKSTART.md (quick start guide)"
Write-Host "  - docs/ (detailed guides)"
Write-Host ""
