# Script pour configurer le Android SDK et avdmanager

Write-Host "========================================" -ForegroundColor Green
Write-Host "Configuration du Android SDK pour Flutter" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# 1. Définir le chemin du Android SDK
$ANDROID_SDK_ROOT = "$env:LOCALAPPDATA\Android\sdk"
$CMDLINE_TOOLS_DIR = "$ANDROID_SDK_ROOT\cmdline-tools\latest\bin"

# Créer les dossiers s'ils n'existent pas
if (-not (Test-Path $ANDROID_SDK_ROOT)) {
    Write-Host "[1/3] Création du dossier Android SDK..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $ANDROID_SDK_ROOT -Force | Out-Null
}

# 2. Télécharger les Android SDK command-line tools
Write-Host "[2/3] Téléchargement des Android SDK command-line tools..." -ForegroundColor Cyan
$downloadUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$zipPath = "$env:TEMP\cmdline-tools.zip"
$extractPath = "$ANDROID_SDK_ROOT\cmdline-tools-temp"

if (-not (Test-Path $CMDLINE_TOOLS_DIR)) {
    try {
        # Télécharger
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
        
        # Extraire
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
        
        # Déplacer vers le bon endroit
        $cmdlineDir = "$extractPath\cmdline-tools"
        if (Test-Path "$ANDROID_SDK_ROOT\cmdline-tools") {
            Remove-Item "$ANDROID_SDK_ROOT\cmdline-tools" -Recurse -Force
        }
        New-Item -ItemType Directory -Path "$ANDROID_SDK_ROOT\cmdline-tools" -Force | Out-Null
        Move-Item -Path $cmdlineDir -Destination "$ANDROID_SDK_ROOT\cmdline-tools\latest" -Force
        
        Remove-Item $zipPath -Force
        Remove-Item $extractPath -Recurse -Force
        
        Write-Host "[✓] Android SDK command-line tools installés avec succès" -ForegroundColor Green
    } catch {
        Write-Host "[✗] Erreur lors du téléchargement: $_" -ForegroundColor Red
        exit 1
    }
}

# 3. Configurer les variables d'environnement
Write-Host "[3/3] Configuration des variables d'environnement..." -ForegroundColor Cyan

# Ajouter au PATH si nécessaire
$currentPath = $env:PATH
if ($currentPath -notlike "*$CMDLINE_TOOLS_DIR*") {
    $env:PATH = "$CMDLINE_TOOLS_DIR;$currentPath"
    [System.Environment]::SetEnvironmentVariable('PATH', "$CMDLINE_TOOLS_DIR;$currentPath", 'User')
}

# Définir ANDROID_HOME
$env:ANDROID_HOME = $ANDROID_SDK_ROOT
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', $ANDROID_SDK_ROOT, 'User')

Write-Host "`n[✓] Configuration terminée !" -ForegroundColor Green
Write-Host "`nVerification..." -ForegroundColor Cyan

# Vérifier que avdmanager est accessible
& "$CMDLINE_TOOLS_DIR\avdmanager" --version

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Setup complété ! Redémarrez VS Code." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
