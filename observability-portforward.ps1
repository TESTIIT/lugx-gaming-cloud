# -------------------------
# Observability Deployment & Port Forward Script (Corrected)
# -------------------------

Write-Host ">>> Deploying Observability Stack (kube-state-metrics, node-exporter, Prometheus, Grafana)..."

$basePath = "C:\Users\LENOVO\OneDrive\Desktop\Masters\Sem3_Cloud Computing\Course Work"
cd "$basePath\k8s-configs"

# Apply manifests
Write-Host "`n>>> Applying kube-state-metrics..."
kubectl apply -f kube-state-metrics.yaml -n monitoring

Write-Host "`n>>> Applying node-exporter..."
kubectl apply -f node-exporter.yaml -n monitoring

Write-Host "`n>>> Applying Prometheus..."
kubectl apply -f prometheus-deployment.yaml -n monitoring

Write-Host "`n>>> Applying Grafana..."
kubectl apply -f grafana-deployment.yaml -n monitoring

# -------------------------
# Wait for Observability Pods
# -------------------------
Write-Host "`n>>> Waiting for observability pods to be ready..."
kubectl wait --for=condition=ready pod -l app=kube-state-metrics -n monitoring --timeout=180s
kubectl wait --for=condition=ready pod -l app=node-exporter -n monitoring --timeout=180s
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=180s
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=180s

# -------------------------
# Port-Forward Services
# -------------------------
Write-Host "`n>>> Starting Port-Forward for Prometheus and Grafana..."
Start-Process powershell -ArgumentList "kubectl port-forward svc/prometheus-service 9099:9090 -n monitoring"
Start-Process powershell -ArgumentList "kubectl port-forward svc/grafana-service 3004:3000 -n monitoring"

# -------------------------
# Success Message
# -------------------------
Write-Host "`n>>> Observability stack is running!"
Write-Host "Prometheus: http://127.0.0.1:9099"
Write-Host "Grafana:    http://127.0.0.1:3004"
