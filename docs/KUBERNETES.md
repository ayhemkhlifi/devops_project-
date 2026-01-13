# Kubernetes Deployment Guide

## Overview
Deploy the DevOps API to Kubernetes with:
- **3 replicas** for high availability
- **Auto-scaling** based on CPU/memory
- **Health checks** for automated recovery
- **Resource limits** for stability
- **NodePort service** for external access

## Architecture

```
                      ┌─────────────────┐
                      │  Minikube Node  │
                      │                 │
  Internet/Client     │  ┌───────────┐  │
       │              │  │  Service  │  │
       │              │  │ NodePort  │  │
       │              │  │  :30080   │  │
       │              │  └─────┬─────┘  │
       │              │        │        │
       │              │  ┌─────▼─────┐  │
       └──────────────┼─►│ Ingress/  │  │
                      │  │    LB     │  │
                      │  └─────┬─────┘  │
                      │        │        │
                      │  ┌─────▼──────────────┐
                      │  │   Deployment       │
                      │  │  (3 replicas)      │
                      │  └────────────────────┘
                      │    │      │      │
                      │  ┌─▼─┐  ┌─▼─┐  ┌─▼─┐
                      │  │Pod│  │Pod│  │Pod│
                      │  │ 1 │  │ 2 │  │ 3 │
                      │  └───┘  └───┘  └───┘
                      │    ▲      ▲      ▲
                      │    │      │      │
                      │  ┌─┴──────┴──────┴─┐
                      │  │  Health Checks  │
                      │  │  • Liveness     │
                      │  │  • Readiness    │
                      │  └─────────────────┘
                      └─────────────────────┘
```

## Kubernetes Components Explained

### 1. **Pods**
- Smallest deployable unit
- Contains one or more containers
- Ephemeral (can be recreated)
- Each pod has unique IP address
- In our deployment: 3 pods running API containers

### 2. **Deployment**
- Manages pod lifecycle
- Ensures desired state (3 replicas)
- Rolling updates (zero downtime)
- Automatic pod recreation on failure
- Rollback capability

### 3. **Service**
- Stable network endpoint
- Load balances across pods
- Service discovery within cluster
- Types: ClusterIP, NodePort, LoadBalancer
- Our choice: NodePort for local access

### 4. **ConfigMap**
- Store configuration separately
- Environment variables
- Configuration files
- Mounted as volumes or env vars

### 5. **HorizontalPodAutoscaler (HPA)**
- Automatic scaling based on metrics
- Monitors CPU/memory usage
- Scales pods up/down dynamically
- Min 2, Max 10 replicas

## Prerequisites

### Install Minikube
```bash
# Windows (PowerShell as Administrator)
choco install minikube

# Or download from: https://minikube.sigs.k8s.io/docs/start/

# Start Minikube
minikube start --driver=docker --cpus=4 --memory=4096

# Verify
kubectl cluster-info
kubectl get nodes
```

### Install kubectl
```bash
# Windows
choco install kubernetes-cli

# Verify
kubectl version --client
```

## Deployment Steps

### Step 1: Build & Push Docker Image
```bash
# Build image
docker build -t YOUR_DOCKERHUB_USERNAME/devops-api:1.0.0 .

# Login to Docker Hub
docker login

# Push image
docker push YOUR_DOCKERHUB_USERNAME/devops-api:1.0.0
```

### Step 2: Update Kubernetes Manifests
Edit [k8s/deployment.yaml](../k8s/deployment.yaml):
```yaml
image: YOUR_DOCKERHUB_USERNAME/devops-api:1.0.0  # Replace with your username
```

### Step 3: Deploy to Kubernetes
```bash
# Create namespace (optional)
kubectl create namespace devops

# Apply ConfigMap
kubectl apply -f k8s/configmap.yaml

# Deploy application
kubectl apply -f k8s/deployment.yaml

# Create service
kubectl apply -f k8s/service.yaml

# Apply HPA (optional, requires metrics-server)
kubectl apply -f k8s/hpa.yaml
```

### Step 4: Verify Deployment
```bash
# Check pods
kubectl get pods
kubectl get pods -o wide

# Check deployment
kubectl get deployment devops-api

# Check service
kubectl get service devops-api-service

# View pod logs
kubectl logs -f deployment/devops-api

# Describe pod (troubleshooting)
kubectl describe pod <pod-name>
```

### Step 5: Access the API

#### Method 1: NodePort (Minikube)
```bash
# Get Minikube IP
minikube ip

# Access API
curl http://$(minikube ip):30080/health

# Or get URL
minikube service devops-api-service --url
```

#### Method 2: Port Forward
```bash
# Forward local port to pod
kubectl port-forward deployment/devops-api 8000:8000

# Access locally
curl http://localhost:8000/health
```

#### Method 3: Minikube Tunnel (LoadBalancer)
```bash
# In separate terminal
minikube tunnel

# Access via localhost
curl http://localhost:8000/health
```

## Testing the Deployment

### Health Check
```bash
API_URL=$(minikube service devops-api-service --url)

# Health endpoint
curl $API_URL/health
```

### Create Items
```bash
# Create item
curl -X POST $API_URL/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Kubernetes Test", "price": 99.99}'

# Get all items
curl $API_URL/items
```

### Metrics
```bash
# View Prometheus metrics
curl $API_URL/metrics
```

### Load Test
```bash
# Generate traffic
for i in {1..100}; do
  curl -s $API_URL/health > /dev/null &
done

# Watch pods scale (if HPA is enabled)
kubectl get hpa -w
```

## Pod Lifecycle Management

### Rolling Update
```bash
# Update image version
kubectl set image deployment/devops-api api=YOUR_USERNAME/devops-api:2.0.0

# Watch rollout
kubectl rollout status deployment/devops-api

# Rollback if needed
kubectl rollout undo deployment/devops-api
```

### Manual Scaling
```bash
# Scale to 5 replicas
kubectl scale deployment devops-api --replicas=5

# Verify
kubectl get pods
```

### Restart Pods
```bash
# Restart all pods (rolling restart)
kubectl rollout restart deployment/devops-api
```

## Health Checks Explained

### Liveness Probe
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 10
  periodSeconds: 30
```
- **Purpose**: Detect if container is alive
- **Action**: Restart container if fails
- **Use case**: Application deadlock, crash

### Readiness Probe
```yaml
readinessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 10
```
- **Purpose**: Detect if container is ready for traffic
- **Action**: Remove from service endpoints if fails
- **Use case**: Startup dependencies, initialization

### Probe Lifecycle
```
Pod Created
    │
    ▼
Startup (initialDelaySeconds: 5s)
    │
    ▼
Readiness Check Every 10s
    │
    ├─ PASS → Add to service endpoints
    │
    └─ FAIL → Remove from service endpoints
    
Liveness Check Every 30s
    │
    ├─ PASS → Continue running
    │
    └─ FAIL (3 times) → Restart container
```

## Resource Management

### Requests vs Limits
```yaml
resources:
  requests:      # Guaranteed resources
    memory: "128Mi"
    cpu: "100m"
  limits:        # Maximum allowed
    memory: "256Mi"
    cpu: "500m"
```

- **Requests**: Kubernetes schedules pod on node with available resources
- **Limits**: Container is throttled/killed if exceeded
- **100m** = 0.1 CPU core
- **128Mi** = 128 Mebibytes of memory

### Monitoring Resources
```bash
# Pod resource usage
kubectl top pods

# Node resource usage
kubectl top nodes

# Enable metrics-server if needed
minikube addons enable metrics-server
```

## Troubleshooting

### Pod Won't Start
```bash
# Check pod status
kubectl get pods

# View events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Previous container logs (if restarted)
kubectl logs <pod-name> --previous
```

### ImagePullBackOff Error
```bash
# Check image name in deployment
kubectl describe pod <pod-name> | grep Image

# Verify image exists on Docker Hub
docker pull YOUR_USERNAME/devops-api:1.0.0

# Check imagePullPolicy
kubectl get deployment devops-api -o yaml | grep imagePullPolicy
```

### Service Not Accessible
```bash
# Check service endpoints
kubectl get endpoints devops-api-service

# Verify pod labels match service selector
kubectl get pods --show-labels
kubectl describe service devops-api-service

# Test from within cluster
kubectl run debug --image=busybox -it --rm -- wget -O- http://devops-api-service:8000/health
```

### Probes Failing
```bash
# Check probe configuration
kubectl describe pod <pod-name> | grep -A 10 Liveness

# Test endpoint manually
kubectl port-forward <pod-name> 8000:8000
curl http://localhost:8000/health

# Increase timeouts if needed
kubectl edit deployment devops-api
```

## Cleanup

```bash
# Delete all resources
kubectl delete -f k8s/

# Or delete individually
kubectl delete deployment devops-api
kubectl delete service devops-api-service
kubectl delete configmap api-config
kubectl delete hpa devops-api-hpa

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete
```

## Advanced: Production Considerations

### 1. Use Ingress Controller
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: devops-api-ingress
spec:
  rules:
  - host: api.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: devops-api-service
            port:
              number: 8000
```

### 2. Add Persistent Storage
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: api-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### 3. Security Enhancements
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL
```

### 4. Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-network-policy
spec:
  podSelector:
    matchLabels:
      app: devops-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 8000
```

## Summary

**Deployment Features:**
- ✅ 3 replicas for high availability
- ✅ Health checks for automatic recovery
- ✅ Resource limits for stability
- ✅ Auto-scaling capability (HPA)
- ✅ Rolling updates for zero downtime
- ✅ Security context (non-root user)
- ✅ NodePort service for external access

**Commands Summary:**
```bash
# Deploy
kubectl apply -f k8s/

# Access
minikube service devops-api-service --url

# Monitor
kubectl get pods -w
kubectl logs -f deployment/devops-api

# Scale
kubectl scale deployment devops-api --replicas=5

# Update
kubectl set image deployment/devops-api api=new-image:tag

# Cleanup
kubectl delete -f k8s/
```
