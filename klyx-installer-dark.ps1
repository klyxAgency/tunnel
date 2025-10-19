$ErrorActionPreference = "Stop"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Configuration - Downloads latest from GitHub
$KLYX_DOWNLOAD_URL = "https://github.com/klyxAgency/tunnel/raw/main/client/dist/klyx-tunnel-windows.exe"
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
    Fast & secure tunneling
    
"@

Write-Host $gradient -ForegroundColor Magenta
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

# Check Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "  ✖ Administrator privileges required" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Right-click and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

Write-Host "  ✓ Admin privileges verified" -ForegroundColor Green
Start-Sleep -Milliseconds 400
Write-Host ""

# Check internet
Write-Host "  Checking connection..." -ForegroundColor Cyan
try {
    $null = Test-Connection -ComputerName google.com -Count 1 -Quiet -ErrorAction Stop
    Write-Host "  ✓ Connected" -ForegroundColor Green
} catch {
    Write-Host "  ✖ Internet connection required" -ForegroundColor Red
    pause
    exit 1
}
Start-Sleep -Milliseconds 400
Write-Host ""

# Paths
$INSTALL_DIR = "C:\Program Files\Klyx"
$APPDATA_DIR = "$env:APPDATA\.klyx-tunnel\bin"
$TEMP_DIR = "$env:TEMP\klyx-install"

# Step 1: Directories
Write-Host "  [1/4] Creating directories..." -ForegroundColor Cyan
@($INSTALL_DIR, $APPDATA_DIR, $TEMP_DIR) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}
Start-Sleep -Milliseconds 500
Write-Host "        ✓ Complete" -ForegroundColor Green
Write-Host ""

# Step 2: Download Klyx
Write-Host "  [2/4] Downloading Klyx Tunnel..." -ForegroundColor Cyan
Write-Host "        Source: github.com/klyxAgency/tunnel" -ForegroundColor DarkGray

# Check local file first (for offline installs)
$localExe = Join-Path $PSScriptRoot "klyx-tunnel-windows.exe"
if (Test-Path $localExe) {
    Write-Host "        Using local file" -ForegroundColor Yellow
    Copy-Item $localExe -Destination "$INSTALL_DIR\klyx.exe" -Force
    Start-Sleep -Milliseconds 300
    Write-Host "        ✓ Complete" -ForegroundColor Green
} else {
    # Download from GitHub
    try {
        $ProgressPreference = 'SilentlyContinue'
        
        # Show download progress
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($KLYX_DOWNLOAD_URL, "$INSTALL_DIR\klyx.exe")
        
        Start-Sleep -Milliseconds 300
        Write-Host "        ✓ Complete" -ForegroundColor Green
    } catch {
        Write-Host "        ✖ Download failed" -ForegroundColor Red
        Write-Host "        Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Alternative: Download manually from" -ForegroundColor Yellow
        Write-Host "  https://github.com/klyxAgency/tunnel/releases" -ForegroundColor White
        pause
        exit 1
    }
}
Write-Host ""

# Step 3: Download FRP
Write-Host "  [3/4] Downloading tunnel client..." -ForegroundColor Cyan
Write-Host "        Source: github.com/fatedier/frp" -ForegroundColor DarkGray
try {
    $ProgressPreference = 'SilentlyContinue'
    $tempZip = "$TEMP_DIR\frp.zip"
    
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($FRP_URL, $tempZip)
    
    Expand-Archive -Path $tempZip -DestinationPath $TEMP_DIR -Force
    
    $frpcExe = Get-ChildItem -Path $TEMP_DIR -Filter "frpc.exe" -Recurse | Select-Object -First 1
    if ($frpcExe) {
        Copy-Item $frpcExe.FullName -Destination "$APPDATA_DIR\frpc.exe" -Force
        Start-Sleep -Milliseconds 300
        Write-Host "        ✓ Complete" -ForegroundColor Green
    } else {
        Write-Host "        ⚠ Will download on first use" -ForegroundColor Yellow
    }
    
    Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
} catch {
    Write-Host "        ⚠ Will download on first use" -ForegroundColor Yellow
}
Write-Host ""

# Step 4: PATH
Write-Host "  [4/4] Configuring system PATH..." -ForegroundColor Cyan
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$INSTALL_DIR*") {
    $newPath = $currentPath.TrimEnd(';') + ";" + $INSTALL_DIR
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Start-Sleep -Milliseconds 500
    Write-Host "        ✓ Complete" -ForegroundColor Green
} else {
    Write-Host "        ✓ Already configured" -ForegroundColor Green
}
Write-Host ""

# Success!
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ✓✓✓ Installation successful! ✓✓✓" -ForegroundColor Green
Write-Host ""
Write-Host "  USAGE:" -ForegroundColor Magenta
Write-Host ""
Write-Host "    Tunnel web server:" -ForegroundColor White
Write-Host "    → klyx 3000 --name myapp" -ForegroundColor Yellow
Write-Host ""
Write-Host "    Share folder as ZIP:" -ForegroundColor White
Write-Host "    → klyx folder C:\Files --name files" -ForegroundColor Yellow
Write-Host ""
Write-Host "    With password:" -ForegroundColor White
Write-Host "    → klyx folder C:\Files --name files --password secret" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ⚠ IMPORTANT: Close this window and open a NEW PowerShell" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Press any key to finish..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
