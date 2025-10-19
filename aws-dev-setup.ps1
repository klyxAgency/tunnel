<#
.SYNOPSIS
    AWS Windows Server Development Environment Setup
.DESCRIPTION
    Installs Node.js, Python, Git, and Klyx Tunnel on fresh AWS Windows Server
.NOTES
    Run as Administrator
    Tested on: Windows Server 2019/2022
#>

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Banner
Write-Host ""
Write-Host "  ╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║                                           ║" -ForegroundColor Cyan
Write-Host "  ║   AWS DEV ENVIRONMENT SETUP               ║" -ForegroundColor Cyan
Write-Host "  ║   Node.js + Python + Git + Klyx           ║" -ForegroundColor Cyan
Write-Host "  ║                                           ║" -ForegroundColor Cyan
Write-Host "  ╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Configuration
$NODE_VERSION = "20.11.0"
$PYTHON_VERSION = "3.12.1"
$GIT_VERSION = "2.43.0"

$NODE_URL = "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-x64.msi"
$PYTHON_URL = "https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION-amd64.exe"
$GIT_URL = "https://github.com/git-for-windows/git/releases/download/v$GIT_VERSION.windows.1/Git-$GIT_VERSION-64-bit.exe"
$KLYX_INSTALLER = "https://raw.githubusercontent.com/klyxAgency/tunnel/main/klyx-installer-dark.ps1"

# Check Administrator
Write-Host "  [SYSTEM CHECK]" -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "  ✖ Administrator privileges required" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Right-click and 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "  ✓ Running as Administrator" -ForegroundColor Green

# Check internet
Write-Host "  ✓ Checking internet connection..." -ForegroundColor Cyan
try {
    $null = Test-Connection -ComputerName google.com -Count 1 -Quiet -ErrorAction Stop
    Write-Host "  ✓ Internet connected" -ForegroundColor Green
} catch {
    Write-Host "  ✖ No internet connection" -ForegroundColor Red
    pause
    exit 1
}
Write-Host ""

# Create temp directory
$TEMP_DIR = "$env:TEMP\aws-dev-setup"
if (Test-Path $TEMP_DIR) {
    Remove-Item $TEMP_DIR -Recurse -Force
}
New-Item -ItemType Directory -Path $TEMP_DIR -Force | Out-Null

# Function to download files
function Download-File {
    param(
        [string]$Url,
        [string]$Output,
        [string]$Name
    )
    
    Write-Host "  Downloading $Name..." -ForegroundColor Cyan
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile $Output -UseBasicParsing -TimeoutSec 300
        Write-Host "  ✓ Downloaded: $Name" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  ✖ Failed: $Name" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# ====================================
# 1. INSTALL NODE.JS
# ====================================
Write-Host ""
Write-Host "  [1/4] INSTALLING NODE.JS v$NODE_VERSION" -ForegroundColor Magenta
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

# Check if Node already installed
$nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
if ($nodeInstalled) {
    $currentVersion = node --version
    Write-Host "  ⚠ Node.js already installed: $currentVersion" -ForegroundColor Yellow
    Write-Host "  Skipping Node.js installation" -ForegroundColor Yellow
} else {
    $nodeInstaller = "$TEMP_DIR\node-installer.msi"
    
    if (Download-File -Url $NODE_URL -Output $nodeInstaller -Name "Node.js") {
        Write-Host "  Installing Node.js..." -ForegroundColor Cyan
        Start-Process msiexec.exe -ArgumentList "/i `"$nodeInstaller`" /quiet /norestart" -Wait -NoNewWindow
        Write-Host "  ✓ Node.js installed" -ForegroundColor Green
        
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }
}

# ====================================
# 2. INSTALL PYTHON
# ====================================
Write-Host ""
Write-Host "  [2/4] INSTALLING PYTHON v$PYTHON_VERSION" -ForegroundColor Magenta
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

# Check if Python already installed
$pythonInstalled = Get-Command python -ErrorAction SilentlyContinue
if ($pythonInstalled) {
    $currentVersion = python --version
    Write-Host "  ⚠ Python already installed: $currentVersion" -ForegroundColor Yellow
    Write-Host "  Skipping Python installation" -ForegroundColor Yellow
} else {
    $pythonInstaller = "$TEMP_DIR\python-installer.exe"
    
    if (Download-File -Url $PYTHON_URL -Output $pythonInstaller -Name "Python") {
        Write-Host "  Installing Python..." -ForegroundColor Cyan
        Start-Process $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_pip=1" -Wait -NoNewWindow
        Write-Host "  ✓ Python installed" -ForegroundColor Green
        
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }
}

# ====================================
# 3. INSTALL GIT
# ====================================
Write-Host ""
Write-Host "  [3/4] INSTALLING GIT v$GIT_VERSION" -ForegroundColor Magenta
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

# Check if Git already installed
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
if ($gitInstalled) {
    $currentVersion = git --version
    Write-Host "  ⚠ Git already installed: $currentVersion" -ForegroundColor Yellow
    Write-Host "  Skipping Git installation" -ForegroundColor Yellow
} else {
    $gitInstaller = "$TEMP_DIR\git-installer.exe"
    
    if (Download-File -Url $GIT_URL -Output $gitInstaller -Name "Git") {
        Write-Host "  Installing Git..." -ForegroundColor Cyan
        Start-Process $gitInstaller -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS='icons,ext\reg\shellhere,assoc,assoc_sh'" -Wait -NoNewWindow
        Write-Host "  ✓ Git installed" -ForegroundColor Green
        
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }
}

# ====================================
# 4. INSTALL KLYX TUNNEL
# ====================================
Write-Host ""
Write-Host "  [4/4] INSTALLING KLYX TUNNEL" -ForegroundColor Magenta
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

# Check if Klyx already installed
$klyxInstalled = Get-Command klyx -ErrorAction SilentlyContinue
if ($klyxInstalled) {
    Write-Host "  ⚠ Klyx already installed" -ForegroundColor Yellow
    Write-Host "  Updating to latest version..." -ForegroundColor Yellow
}

$klyxInstallerPath = "$TEMP_DIR\klyx-installer.ps1"

if (Download-File -Url $KLYX_INSTALLER -Output $klyxInstallerPath -Name "Klyx Installer") {
    Write-Host "  Running Klyx installer..." -ForegroundColor Cyan
    try {
        & $klyxInstallerPath
        Write-Host "  ✓ Klyx installed" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Klyx installer encountered an issue" -ForegroundColor Yellow
    }
}

# ====================================
# VERIFICATION
# ====================================
Write-Host ""
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  [VERIFICATION]" -ForegroundColor Yellow
Write-Host ""

# Refresh PATH for verification
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check Node.js
$nodeCheck = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCheck) {
    $nodeVer = node --version
    $npmVer = npm --version
    Write-Host "  ✓ Node.js: $nodeVer" -ForegroundColor Green
    Write-Host "  ✓ npm: $npmVer" -ForegroundColor Green
} else {
    Write-Host "  ✖ Node.js not found" -ForegroundColor Red
}

# Check Python
$pythonCheck = Get-Command python -ErrorAction SilentlyContinue
if ($pythonCheck) {
    $pythonVer = python --version
    Write-Host "  ✓ Python: $pythonVer" -ForegroundColor Green
    
    $pipCheck = Get-Command pip -ErrorAction SilentlyContinue
    if ($pipCheck) {
        $pipVer = pip --version
        Write-Host "  ✓ pip: installed" -ForegroundColor Green
    }
} else {
    Write-Host "  ✖ Python not found" -ForegroundColor Red
}

# Check Git
$gitCheck = Get-Command git -ErrorAction SilentlyContinue
if ($gitCheck) {
    $gitVer = git --version
    Write-Host "  ✓ Git: $gitVer" -ForegroundColor Green
} else {
    Write-Host "  ✖ Git not found" -ForegroundColor Red
}

# Check Klyx
$klyxCheck = Get-Command klyx -ErrorAction SilentlyContinue
if ($klyxCheck) {
    Write-Host "  ✓ Klyx: installed" -ForegroundColor Green
} else {
    Write-Host "  ✖ Klyx not found" -ForegroundColor Red
}

# Cleanup
Write-Host ""
Write-Host "  Cleaning up temporary files..." -ForegroundColor Cyan
Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  ✓ Cleanup complete" -ForegroundColor Green

# ====================================
# COMPLETION
# ====================================
Write-Host ""
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ✓✓✓ INSTALLATION COMPLETE! ✓✓✓" -ForegroundColor Green
Write-Host ""
Write-Host "  INSTALLED TOOLS:" -ForegroundColor Magenta
Write-Host "    • Node.js & npm" -ForegroundColor White
Write-Host "    • Python & pip" -ForegroundColor White
Write-Host "    • Git" -ForegroundColor White
Write-Host "    • Klyx Tunnel" -ForegroundColor White
Write-Host ""
Write-Host "  QUICK START:" -ForegroundColor Magenta
Write-Host ""
Write-Host "    Test Node.js:" -ForegroundColor White
Write-Host "    → node --version" -ForegroundColor Yellow
Write-Host ""
Write-Host "    Test Python:" -ForegroundColor White
Write-Host "    → python --version" -ForegroundColor Yellow
Write-Host ""
Write-Host "    Clone a repo:" -ForegroundColor White
Write-Host "    → git clone https://github.com/user/repo.git" -ForegroundColor Yellow
Write-Host ""
Write-Host "    Share a folder:" -ForegroundColor White
Write-Host "    → klyx folder C:\Files --name demo" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ⚠ IMPORTANT: Close and reopen PowerShell" -ForegroundColor Yellow
Write-Host "  to ensure all PATH changes take effect." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Press any key to finish..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
