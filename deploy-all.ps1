# Enable Minikube Docker environment
Write-Host ">>> Setting Docker environment to Minikube..."
minikube docker-env | Invoke-Expression

# Define project base path
$basePath = "C:\Users\LENOVO\OneDrive\Desktop\Masters\Sem3_Cloud Computing\Course Work"

# -------------------------
# Build Docker Images (Fresh Build with --no-cache)
# -------------------------

Write-Host ">>> Building Docker images (no cache)..."
cd "$basePath\game-service"
docker build --no-cache -t game-service:1.0 .

cd "$basePath\order-service"
docker build --no-cache -t order-service:1.0 .

cd "$basePath\analytics-service"
docker build --no-cache -t analytics-service:1.0 .

cd "$basePath\lugx_gaming_frontend"
docker build --no-cache -t lugx-frontend:1.0 .

# -------------------------
# Apply Kubernetes Manifests
# -------------------------
Write-Host ">>> Deploying Kubernetes Manifests..."
cd "$basePath\k8s-configs"
kubectl apply -f frontend-deployment.yaml
kubectl apply -f game-service.yaml
kubectl apply -f order-service.yaml
kubectl apply -f analytics-service.yaml

# -------------------------
# Wait for Pods to be Ready
# -------------------------
Write-Host "`n>>> Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=lugx-frontend --timeout=120s
kubectl wait --for=condition=ready pod -l app=game-service --timeout=120s
kubectl wait --for=condition=ready pod -l app=order-service --timeout=120s
kubectl wait --for=condition=ready pod -l app=analytics-service --timeout=120s

# -------------------------
# Start Port-Forward Services with Stable Ports
# -------------------------
Write-Host "`n>>> Starting Port-Forward for all services (stable ports)..."

Start-Process powershell -ArgumentList "kubectl port-forward svc/lugx-frontend-service 8080:80"
Start-Process powershell -ArgumentList "kubectl port-forward svc/game-service 3000:3000"
Start-Process powershell -ArgumentList "kubectl port-forward svc/order-service 3001:3001"
Start-Process powershell -ArgumentList "kubectl port-forward svc/analytics-service 3002:3002"

Write-Host "`n>>> All services are running!"
Write-Host "Frontend:          http://127.0.0.1:8080"
Write-Host "Game Service:      http://127.0.0.1:3000/games"
Write-Host "Order Service:     http://127.0.0.1:3001/orders"
Write-Host "Analytics Service: http://127.0.0.1:3002/analytics"
