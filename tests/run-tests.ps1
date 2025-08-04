Write-Host ">>> Running Integration Tests..."

$response = Invoke-WebRequest http://lugx-frontend-service:80
if ($response.StatusCode -ne 200) { exit 1 }

$response = Invoke-WebRequest http://game-service:3000/games
if ($response.StatusCode -ne 200) { exit 1 }

$response = Invoke-WebRequest http://order-service:3001/orders
if ($response.StatusCode -ne 200) { exit 1 }

$response = Invoke-WebRequest http://analytics-service:3002/analytics
if ($response.StatusCode -ne 200) { exit 1 }

Write-Host ">>> All Integration Tests Passed!"
exit 0
