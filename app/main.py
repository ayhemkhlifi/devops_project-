"""
DevOps Learning Project - REST API Service
A simple FastAPI backend with observability, security, and DevOps best practices
"""
import logging
import time
import json
import uuid
from datetime import datetime
from typing import List, Optional
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import PlainTextResponse
from pydantic import BaseModel, Field, validator
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(message)s'
)
logger = logging.getLogger(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter('api_requests_total', 'Total API requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('api_request_duration_seconds', 'Request duration', ['method', 'endpoint'])

# In-memory data store
items_db = []

class Item(BaseModel):
    """Item model with validation"""
    id: Optional[str] = None
    name: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    price: float = Field(..., gt=0, le=1000000)
    created_at: Optional[datetime] = None

    @validator('name')
    def name_must_not_be_empty(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty or whitespace')
        return v.strip()

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    logger.info(json.dumps({"event": "startup", "service": "devops-api", "timestamp": datetime.utcnow().isoformat()}))
    yield
    logger.info(json.dumps({"event": "shutdown", "service": "devops-api", "timestamp": datetime.utcnow().isoformat()}))

app = FastAPI(
    title="DevOps Learning API",
    description="Production-ready REST API with observability and security",
    version="1.0.0",
    lifespan=lifespan
)

@app.middleware("http")
async def observability_middleware(request: Request, call_next):
    """Add tracing, logging, and metrics to all requests"""
    trace_id = str(uuid.uuid4())
    request.state.trace_id = trace_id
    start_time = time.time()
    
    # Log request
    logger.info(json.dumps({
        "trace_id": trace_id,
        "event": "request_started",
        "method": request.method,
        "path": request.url.path,
        "timestamp": datetime.utcnow().isoformat()
    }))
    
    response = await call_next(request)
    duration = time.time() - start_time
    
    # Record metrics
    REQUEST_COUNT.labels(method=request.method, endpoint=request.url.path, status=response.status_code).inc()
    REQUEST_DURATION.labels(method=request.method, endpoint=request.url.path).observe(duration)
    
    # Log response
    logger.info(json.dumps({
        "trace_id": trace_id,
        "event": "request_completed",
        "method": request.method,
        "path": request.url.path,
        "status_code": response.status_code,
        "duration_seconds": round(duration, 4),
        "timestamp": datetime.utcnow().isoformat()
    }))
    
    response.headers["X-Trace-ID"] = trace_id
    return response

@app.get("/health")
async def health_check():
    """Health check endpoint for container orchestration"""
    return {
        "status": "healthy",
        "service": "devops-api",
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/items", response_model=List[Item])
async def get_items():
    """Retrieve all items"""
    logger.info(json.dumps({"event": "get_items", "count": len(items_db)}))
    return items_db

@app.post("/items", response_model=Item, status_code=201)
async def create_item(item: Item):
    """Create a new item with validation"""
    item.id = str(uuid.uuid4())
    item.created_at = datetime.utcnow()
    items_db.append(item)
    
    logger.info(json.dumps({
        "event": "item_created",
        "item_id": item.id,
        "item_name": item.name,
        "timestamp": datetime.utcnow().isoformat()
    }))
    
    return item

@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint"""
    return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "DevOps Learning API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health",
        "metrics": "/metrics"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
