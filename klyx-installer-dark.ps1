$ErrorActionPreference = "Stop"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Configuration
$KLYX_VERSION = "1.0.0"
$KLYX_REPO = "YOUR-GITHUB-USERNAME/klyx-tunnel"
$KLYX_DOWNLOAD_URL = "https://github.com/$KLYX_REPO/releases/download/v$KLYX_VERSION/klyx-tunnel-windows.exe"
$FRP_VERSION = "0.52.3"
$FRP_URL = "https://github.com/fatedier/frp/releases/download/v$FRP_VERSION/frp_${FRP_VERSION}_windows_amd64.zip"

# Banner
$gradient = @"
  
    ██╗  ██╗██╗  ██╗   ██╗██╗  ██╗
    ██║ ██╔╝██║  ╚██╗ ██╔╝╚██╗██╔╝
    █████╔╝ ██║   ╚████╔╝  ╚███╔╝ 
    ██╔═██╗ ██║    ╚██╔╝   ██╔██╗ 
    ██║  ██╗███████╗██║   ██╔╝ ██╗
    ╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝
    
    T U N N E L   I N S T A L L E R
    Fast tunneling for local services
    v$KLYX_VERSION
    
"@

Write-Host $gradient -ForegroundColor Magenta
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

# Check Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "  ✖ ERROR: Administrator required" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Right-click installer and select" -ForegroundColor Yellow
    Write-Host "  'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

Write-Host "  ✓ Admin privileges verified" -ForegroundColor Green
Write-Host ""
Start-Sleep -Milliseconds 300

# Check internet connection
Write-Host "  Checking internet connection..." -ForegroundColor Cyan
try {
    $null = Test-Connection -ComputerName google.com -Count 1 -Quiet
    Write-Host "  ✓ Connected" -ForegroundColor Green
} catch {
    Write-Host "  ✖ No internet connection" -ForegroundColor Red
    pause
    exit 1
}
Write-Host ""
Start-Sleep -Milliseconds 300

# Paths
$INSTALL_DIR = "C:\Program Files\Klyx"
$APPDATA_DIR = "$env:APPDATA\.klyx-tunnel\bin"
$TEMP_DIR = "$env:TEMP\klyx-install"

# Step 1: Create directories
Write-Host "  [1/4] Creating directories..." -ForegroundColor Cyan
if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
}
if (-not (Test-Path $APPDATA_DIR)) {
    New-Item -ItemType Directory -Path $APPDATA_DIR -Force | Out-Null
}
if (-not (Test-Path $TEMP_DIR)) {
    New-Item -ItemType Directory -Path $TEMP_DIR -Force | Out-Null
}
Start-Sleep -Milliseconds 300
Write-Host "        ✓ Complete" -ForegroundColor Green
Write-Host ""

# Step 2: Download Klyx
Write-Host "  [2/4] Downloading Klyx Tunnel..." -ForegroundColor Cyan
Write-Host "        From: $KLYX_DOWNLOAD_URL" -ForegroundColor DarkGray

# Check if local exe exists (for development)
$localExe = Join-Path $PSScriptRoot "klyx-tunnel-windows.exe"
if (Test-Path $localExe) {
    Write-Host "        Using local file" -ForegroundColor Yellow
    Copy-Item $localExe -Destination "$INSTALL_DIR\klyx.exe" -Force
} else {
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $KLYX_DOWNLOAD_URL -OutFile "$INSTALL_DIR\klyx.exe" -UseBasicParsing -TimeoutSec 30
    } catch {
        Write-Host "        ✖ Download failed" -ForegroundColor Red
        Write-Host "        Error: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Please download manually from:" -ForegroundColor Yellow
        Write-Host "  https://github.com/$KLYX_REPO/releases" -ForegroundColor White
        pause
        exit 1
    }
}
Start-Sleep -Milliseconds 300
Write-Host "        ✓ Complete" -ForegroundColor Green
Write-Host ""

# Step 3: Download FRP client
Write-Host "  [3/4] Downloading tunnel client..." -ForegroundColor Cyan
Write-Host "        From: github.com/fatedier/frp" -ForegroundColor DarkGray
try {
    $ProgressPreference = 'SilentlyContinue'
    $tempZip = "$TEMP_DIR\frp.zip"
    
    Invoke-WebRequest -Uri $FRP_URL -OutFile $tempZip -UseBasicParsing -TimeoutSec 30
    
    Expand-Archive -Path $tempZip -DestinationPath $TEMP_DIR -Force
    
    $frpcExe = Get-ChildItem -Path $TEMP_DIR -Filter "frpc.exe" -Recurse | Select-Object -First 1
    if ($frpcExe) {
        Copy-Item $frpcExe.FullName -Destination "$APPDATA_DIR\frpc.exe" -Force
        Write-Host "        ✓ Complete" -ForegroundColor Green
    } else {
        Write-Host "        ⚠ Will download on first use" -ForegroundColor Yellow
    }
    
    Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
} catch {
    Write-Host "        ⚠ Will download on first use" -ForegroundColor Yellow
}
Write-Host ""

# Step 4: Add to PATH
Write-Host "  [4/4] Setting up system PATH..." -ForegroundColor Cyan
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$INSTALL_DIR*") {
    $newPath = $currentPath.TrimEnd(';') + ";" + $INSTALL_DIR
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Start-Sleep -Milliseconds 300
    Write-Host "        ✓ Complete" -ForegroundColor Green
} else {
    Write-Host "        ✓ Already configured" -ForegroundColor Green
}
Write-Host ""

# Success
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ✓ Installation successful!" -ForegroundColor Green
Write-Host ""
Write-Host "  QUICK START:" -ForegroundColor Magenta
Write-Host ""
Write-Host "    Tunnel a web server:" -ForegroundColor White
Write-Host "    klyx 3000 --name myapp" -ForegroundColor Yellow
Write-Host ""
Write-Host "    Share a folder:" -ForegroundColor White
Write-Host "    klyx folder C:\Files --name files" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Note: Open a NEW PowerShell window" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Press any key to finish..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
