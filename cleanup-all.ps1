Write-Host ">>> Cleaning up Lugx Gaming frontend and microservices..."

# Define project base path
$basePath = "C:\Users\sdezlk\OneDrive - IFS\Desktop\Masters\Sem3_Cloud Computing\Course Work"

# -------------------------
# Stop Port-Forward Processes
# -------------------------
Write-Host ">>> Stopping all kubectl port-forward processes..."
Get-Process | Where-Object { $_.ProcessName -eq "kubectl" } | Stop-Process -Force -ErrorAction SilentlyContinue

# -------------------------
# Delete Kubernetes Deployments and Services
# -------------------------
Write-Host ">>> Deleting Kubernetes resources..."
cd "$basePath\k8s-configs"

kubectl delete -f frontend-deployment.yaml --ignore-not-found
kubectl delete -f game-service.yaml --ignore-not-found
kubectl delete -f order-service.yaml --ignore-not-found
kubectl delete -f analytics-service.yaml --ignore-not-found

# -------------------------
# Optional: Delete Docker Images from Minikube
# -------------------------
Write-Host ">>> Removing Docker images from Minikube..."
minikube docker-env | Invoke-Expression
docker rmi -f lugx-frontend:1.0 game-service:1.0 order-service:1.0 analytics-service:1.0 2>$null

# -------------------------
# Verify Cluster State
# -------------------------
Write-Host "`n>>> Verifying remaining resources..."
kubectl get pods
kubectl get svc

Write-Host "`n>>> Cleanup completed! All services and port-forwards have been stopped."
