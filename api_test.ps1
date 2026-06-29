# Script pour tester l'API FreeLanceMada

Write-Host "========================================" -ForegroundColor Green
Write-Host "Test de l'API FreeLanceMada" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$baseUrl = "http://localhost:8000/api"

# Test 1: Vérifier que le serveur répond
Write-Host "`n[Test 1] Verification du serveur..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000" -UseBasicParsing -ErrorAction Stop
    Write-Host "[OK] Serveur Django repond (HTTP $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "[ERREUR] Le serveur n'est pas accessible" -ForegroundColor Red
    exit 1
}

# Test 2: Lister les utilisateurs
Write-Host "`n[Test 2] Recuperation des utilisateurs..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/users/" -UseBasicParsing -ErrorAction Stop
    Write-Host "[OK] Utilisateurs recuperes:" -ForegroundColor Green
    Write-Host $response.Content -ForegroundColor Yellow
} catch {
    Write-Host "[ERREUR] $_" -ForegroundColor Red
}

# Test 3: Lister les missions
Write-Host "`n[Test 3] Recuperation des missions..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/missions/" -UseBasicParsing -ErrorAction Stop
    Write-Host "[OK] Missions recuperees:" -ForegroundColor Green
    Write-Host $response.Content -ForegroundColor Yellow
} catch {
    Write-Host "[ERREUR] $_" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Tests terminés" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
