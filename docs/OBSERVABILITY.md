# Observability Architecture

## Overview
This project implements comprehensive observability using the three pillars:
1. **Metrics** - Prometheus for performance monitoring
2. **Logs** - Structured JSON logs for debugging
3. **Tracing** - Distributed trace IDs for request tracking

## Architecture

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│  Observability Middleware           │
│  • Generate Trace ID (UUID)         │
│  • Log Request Start                │
│  • Measure Duration                 │
│  • Record Metrics                   │
│  • Log Request Complete             │
└─────────┬───────────────────────────┘
          │
          ├──────────► Logs (JSON stdout)
          │
          ├──────────► Metrics (/metrics endpoint)
          │
          └──────────► Trace ID (X-Trace-ID header)
```

## 1. METRICS

### Implementation
- **Library**: prometheus-client
- **Endpoint**: `/metrics`
- **Metrics Collected**:
  - `api_requests_total` - Counter for total requests (labels: method, endpoint, status)
  - `api_request_duration_seconds` - Histogram for request duration

### Example Metrics Output
```
# HELP api_requests_total Total API requests
# TYPE api_requests_total counter
api_requests_total{endpoint="/health",method="GET",status="200"} 15.0
api_requests_total{endpoint="/items",method="GET",status="200"} 8.0
api_requests_total{endpoint="/items",method="POST",status="201"} 3.0

# HELP api_request_duration_seconds Request duration
# TYPE api_request_duration_seconds histogram
api_request_duration_seconds_bucket{endpoint="/health",method="GET",le="0.005"} 12.0
api_request_duration_seconds_bucket{endpoint="/health",method="GET",le="0.01"} 15.0
api_request_duration_seconds_sum{endpoint="/health",method="GET"} 0.045
api_request_duration_seconds_count{endpoint="/health",method="GET"} 15.0
```

### Prometheus Integration
To scrape these metrics with Prometheus, add to `prometheus.yml`:
```yaml
scrape_configs:
  - job_name: 'devops-api'
    static_configs:
      - targets: ['localhost:8000']
    metrics_path: '/metrics'
    scrape_interval: 15s
```

## 2. STRUCTURED LOGS

### Implementation
- **Format**: JSON for machine readability
- **Fields**:
  - `trace_id` - Unique request identifier
  - `event` - Event type
  - `timestamp` - ISO 8601 format
  - `method`, `path`, `status_code`, `duration_seconds`

### Example Log Entries

**Application Startup:**
```json
{
  "event": "startup",
  "service": "devops-api",
  "timestamp": "2026-01-12T10:30:00.123456"
}
```

**Request Started:**
```json
{
  "trace_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "event": "request_started",
  "method": "POST",
  "path": "/items",
  "timestamp": "2026-01-12T10:30:15.456789"
}
```

**Request Completed:**
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

**Business Event:**
```json
{
  "event": "item_created",
  "item_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "item_name": "Sample Product",
  "timestamp": "2026-01-12T10:30:15.478000"
}
```

### Log Aggregation
In production, ship logs to:
- **ELK Stack** (Elasticsearch, Logstash, Kibana)
- **Loki** (Grafana Loki)
- **CloudWatch** / **Stackdriver** (cloud providers)

Query example (Elasticsearch):
```json
GET /logs/_search
{
  "query": {
    "match": { "trace_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890" }
  }
}
```

## 3. DISTRIBUTED TRACING

### Implementation
- **Trace ID**: UUID v4 generated per request
- **Propagation**: Returned in `X-Trace-ID` response header
- **Usage**: Track request flow across services

### Example Flow
```
Client Request
    │
    ├─► Generate Trace ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890
    │
    ├─► Log: request_started (with trace_id)
    │
    ├─► Process request
    │
    ├─► Log: item_created (with trace_id)
    │
    ├─► Log: request_completed (with trace_id)
    │
    └─► Response with X-Trace-ID header
```

### Client Usage
```bash
# Make request and capture trace ID
curl -i http://localhost:8000/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Product", "price": 29.99}'

# Response includes:
# X-Trace-ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890

# Use trace ID to search logs
grep "a1b2c3d4-e5f6-7890-abcd-ef1234567890" app.log
```

## Observability Best Practices Applied

### ✅ Consistent Format
- All logs use JSON with standard fields
- Timestamps in ISO 8601 UTC
- Snake_case naming convention

### ✅ Context Propagation
- Trace ID flows through all operations
- Included in every log entry
- Returned to client for support tickets

### ✅ Performance Monitoring
- Request duration tracked automatically
- Histogram buckets for percentile analysis
- Per-endpoint granularity

### ✅ Operational Visibility
- Health check for orchestration
- Startup/shutdown lifecycle events
- Business event tracking (item_created)

### ✅ Debug-Friendly
- Unique identifiers for all entities
- Complete request context in logs
- Machine-readable for automation

## Testing Observability

### 1. Generate Traffic
```bash
# Health checks
for i in {1..10}; do curl http://localhost:8000/health; done

# Create items
for i in {1..5}; do
  curl -X POST http://localhost:8000/items \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"Item $i\", \"price\": $((10 + i))}"
done

# Get items
curl http://localhost:8000/items
```

### 2. View Metrics
```bash
curl http://localhost:8000/metrics
```

### 3. Analyze Logs
```bash
# View all logs
docker logs devops-api

# Filter by trace ID
docker logs devops-api | grep "trace_id"

# Filter by event
docker logs devops-api | grep "item_created"

# Parse JSON (using jq)
docker logs devops-api | jq 'select(.event == "request_completed")'
```

### 4. Visualize with Grafana
Create dashboard with panels:
- **Request Rate**: `rate(api_requests_total[5m])`
- **Error Rate**: `rate(api_requests_total{status=~"5.."}[5m])`
- **Latency p95**: `histogram_quantile(0.95, api_request_duration_seconds)`
- **Logs Panel**: Query Loki for trace_id

## Alerting Examples

### Prometheus Alert Rules
```yaml
groups:
  - name: api_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(api_requests_total{status=~"5.."}[5m]) > 0.05
        for: 2m
        annotations:
          summary: "High error rate detected"

      - alert: SlowRequests
        expr: histogram_quantile(0.95, api_request_duration_seconds) > 1
        for: 5m
        annotations:
          summary: "95th percentile latency > 1s"
```

## Summary

This observability implementation provides:
- **Real-time monitoring** via Prometheus metrics
- **Debugging capability** via structured logs
- **Request tracking** via distributed trace IDs
- **Production-ready** patterns for scale
- **Integration-ready** with standard tools (Prometheus, Grafana, ELK)

**Total Lines**: Backend service implements full observability in ~150 lines of clean Python code.
