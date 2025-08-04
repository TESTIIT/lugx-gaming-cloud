Write-Host ">>> Cleaning up Lugx Gaming frontend, microservices, and MySQL..."

# Define project base path
$basePath = "C:\Users\sdezlk\OneDrive - IFS\Desktop\Masters\Sem3_Cloud Computing\Course Work"

# -------------------------
# Stop Port-Forward Processes
# -------------------------
Write-Host ">>> Stopping all kubectl port-forward processes..."
Get-Process | Where-Object { $_.ProcessName -eq "kubectl" } | Stop-Process -ErrorAction SilentlyContinue
Get-Job | ForEach-Object { Stop-Job $_.Id -ErrorAction SilentlyContinue; Remove-Job $_.Id -ErrorAction SilentlyContinue }

# -------------------------
# Delete Kubernetes Deployments, Services, Jobs, and ConfigMaps
# -------------------------
Write-Host ">>> Deleting Kubernetes resources..."
cd "$basePath\k8s-configs"

kubectl delete -f frontend-deployment.yaml --ignore-not-found
kubectl delete -f game-service.yaml --ignore-not-found
kubectl delete -f order-service.yaml --ignore-not-found
kubectl delete -f analytics-service.yaml --ignore-not-found
kubectl delete -f lugx-ingress.yaml --ignore-not-found
kubectl delete -f mysql-init-job.yaml --ignore-not-found
kubectl delete -f mysql-init-configmap.yaml --ignore-not-found
kubectl delete -f mysql.yaml --ignore-not-found

# -------------------------
# Delete Remaining Deployments (safety net)
# -------------------------
Write-Host ">>> Deleting any leftover deployments..."
kubectl delete deployment lugx-frontend --ignore-not-found
kubectl delete deployment game-service --ignore-not-found
kubectl delete deployment order-service --ignore-not-found
kubectl delete deployment analytics-service --ignore-not-found
kubectl delete deployment mysql --ignore-not-found

# -------------------------
# Optional: Delete Docker Images from Minikube
# -------------------------
Write-Host ">>> Removing Docker images from Minikube..."
minikube docker-env | Invoke-Expression
docker rmi -f lugx-frontend:3.0 lugx-frontend:4.0 game-service:3.0 game-service:4.0 order-service:3.0 order-service:4.0 analytics-service:3.0 2>$null

# -------------------------
# Verify Cluster State
# -------------------------
Write-Host "`n>>> Verifying remaining resources..."
kubectl get pods
kubectl get svc
kubectl get jobs
kubectl get ingress

Write-Host "`n>>> Cleanup completed! All services, MySQL, ingress, and port-forwards have been stopped."
