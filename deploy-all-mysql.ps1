# Enable Minikube Docker environment
Write-Host ">>> Setting Docker environment to Minikube..."
minikube docker-env | Invoke-Expression

# Define project base path
$basePath = "C:\Users\sdezlk\OneDrive - IFS\Desktop\Masters\Sem3_Cloud Computing\Course Work"

# -------------------------
# Deploy MySQL
# -------------------------
Write-Host ">>> Deploying MySQL..."
cd "$basePath\k8s-configs"
kubectl apply -f mysql.yaml

# Wait for MySQL pod to be Ready
Write-Host ">>> Waiting for MySQL pod to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=180s

# -------------------------
# Initialize MySQL Schema
# -------------------------
Write-Host ">>> Applying MySQL schema initialization..."
kubectl apply -f mysql-init-configmap.yaml
kubectl apply -f mysql-init-job.yaml

# Wait for job completion
Write-Host ">>> Waiting for schema init Job to complete..."
kubectl wait --for=condition=complete job/mysql-init --timeout=120s

# -------------------------
# Build Docker Images (Fresh Build with --no-cache)
# -------------------------

Write-Host ">>> Building Docker images..."
cd "$basePath\game-service"; docker build --no-cache -t game-service:3.0 .
cd "$basePath\order-service"; docker build --no-cache -t order-service:3.0 .
cd "$basePath\analytics-service"; docker build --no-cache -t analytics-service:3.0 .
cd "$basePath\lugx_gaming_frontend"; docker build --no-cache -t lugx-frontend:3.0 .

# -------------------------
# Apply Kubernetes Manifests
# -------------------------
Write-Host ">>> Deploying application manifests..."
cd "$basePath\k8s-configs"
kubectl apply -f frontend-deployment.yaml
kubectl apply -f game-service.yaml
kubectl apply -f order-service.yaml
kubectl apply -f analytics-service.yaml
kubectl apply -f lugx-ingress.yaml

# -------------------------
# Verify Deployment
# -------------------------
Write-Host "`n>>> Checking Pods and Services..."
kubectl get pods
kubectl get svc
kubectl get ingress

Write-Host "`n>>> Deployment with MySQL completed!"
Write-Host "Frontend:          http://lugx.local/"
Write-Host "Game Service:      http://lugx.local/game"
Write-Host "Order Service:     http://lugx.local/order"
Write-Host "Analytics Service: http://lugx.local/analytics"
