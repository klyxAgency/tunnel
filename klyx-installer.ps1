# Klyx Tunnel Installer
$ErrorActionPreference = "Stop"
Clear-Host

Write-Host ""
Write-Host "  KLYX TUNNEL INSTALLER" -ForegroundColor Magenta
Write-Host ""

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "  ERROR: Need Administrator privileges" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "  Running as admin" -ForegroundColor Green
Write-Host ""

$INSTALL_DIR = "C:\Program Files\Klyx"

Write-Host "  [1/3] Creating directory..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
Write-Host "        Done" -ForegroundColor Green

Write-Host "  [2/3] Copying files..." -ForegroundColor Cyan
$sourceExe = Join-Path $PSScriptRoot "klyx-tunnel-windows.exe"
if (Test-Path $sourceExe) {
    Copy-Item $sourceExe -Destination "$INSTALL_DIR\klyx.exe" -Force
    Write-Host "        Done" -ForegroundColor Green
} else {
    Write-Host "        ERROR: exe not found" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "  [3/3] Adding to PATH..." -ForegroundColor Cyan
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$INSTALL_DIR*") {
    $newPath = $currentPath + ";" + $INSTALL_DIR
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Write-Host "        Done" -ForegroundColor Green
} else {
    Write-Host "        Already in PATH" -ForegroundColor Green
}

Write-Host ""
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host "  Open NEW PowerShell and type: klyx" -ForegroundColor Yellow
Write-Host ""
pause
