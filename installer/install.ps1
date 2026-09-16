# ===============================================
# install.ps1
# windots unified installer
# Install Chocolatey + Git + Brave + GlazeWM + yasb,
# and applies all configs from the windots repo.
# ===============================================

# ------------------------------
# Ensure running as Admin
# ------------------------------
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator."
    exit
}

# ------------------------------
# Set execution policy and TLS
# ------------------------------
Set-ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ------------------------------
# Config
# ------------------------------
$WINDOTS_REPO = "https://github.com/DarkSoulEngineer/windots.git"
$WINDOTS_DIR = Join-Path $env:USERPROFILE "windots"
$GLZR_DIR = Join-Path $env:USERPROFILE ".glzr"

# ------------------------------
# Install Chocolatey if missing
# ------------------------------
$chocoExe = "$env:ProgramData\Chocolatey\bin\choco.exe"
if (-not (Test-Path $chocoExe)) {
    Write-Host "Installing Chocolatey..."
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    if (-not (Test-Path $chocoExe)) {
        Write-Error "Chocolatey installation failed. Install manually."
        exit
    }
}
if (-not ($env:Path -split ";" | Where-Object { $_ -eq "$env:ProgramData\Chocolatey\bin" })) {
    $env:Path = "$env:ProgramData\Chocolatey\bin;$env:Path"
}

# ------------------------------
# Install Git if missing
# ------------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git..."
    Start-Process -FilePath $chocoExe -ArgumentList "install git -y --no-progress" -Wait -NoNewWindow
    $gitCmdPath = "$env:ProgramFiles\Git\cmd"
    if (-not ($env:Path -split ";" | Where-Object { $_ -eq $gitCmdPath })) {
        $env:Path += ";$gitCmdPath"
    }
}

# ------------------------------
# Install Brave via Choco
# ------------------------------
if (-not (Get-Command brave -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Brave Browser..."
    Start-Process -FilePath $chocoExe -ArgumentList "install brave -y --no-progress" -Wait -NoNewWindow
} else {
    Write-Host "Brave Browser already installed. Skipping..."
}

# ------------------------------
# Define installation directories
# ------------------------------
$glzrBase = Join-Path $env:ProgramFiles "glzr.io"
$glazeInstallDir = Join-Path $glzrBase "GlazeWM"

New-Item -ItemType Directory -Force -Path $glzrBase | Out-Null

# ------------------------------
# Install GlazeWM via MSI
# ------------------------------
$glazeMsiUrl = "https://github.com/glzr-io/glazewm/releases/download/v3.9.1/standalone-glazewm-v3.9.1-x64.msi"
$glazeMsi = "$env:TEMP\glazewm-v3.9.1-x64.msi"
$glazeExe = Join-Path $glazeInstallDir "GlazeWM.exe"

if (-not (Test-Path $glazeExe)) {
    Write-Host "Downloading GlazeWM MSI..."
    Invoke-WebRequest -Uri $glazeMsiUrl -OutFile $glazeMsi

    Write-Host "Installing GlazeWM silently to $glazeInstallDir..."
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$glazeMsi`" TARGETDIR=`"$glazeInstallDir`" /quiet /norestart /log `"$env:TEMP\glazewm_install.log`"" -Wait

    if (Test-Path $glazeExe) {
        Write-Host "GlazeWM installed successfully via MSI."
    } else {
        Write-Warning "GlazeWM MSI install failed. Install manually from https://github.com/glzr-io/glazewm/releases"
    }
    Remove-Item $glazeMsi -Force
} else {
    Write-Host "GlazeWM already installed. Skipping MSI install."
}

# ==================================================
# Clone windots repo
# ==================================================
if (-not (Test-Path (Join-Path $WINDOTS_DIR ".git"))) {
    Write-Host "Cloning windots repo to $WINDOTS_DIR..."
    git clone $WINDOTS_REPO $WINDOTS_DIR
} else {
    Write-Host "windots repo already exists. Pulling latest..."
    Push-Location $WINDOTS_DIR
    git pull
    Pop-Location
}

# ==================================================
# Helper: Replace placeholder in a file
# ==================================================
function Update-FilePlaceholder {
    param([string]$FilePath, [string]$Placeholder, [string]$Replacement)
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        $content = $content.Replace($Placeholder, $Replacement)
        Set-Content -Path $FilePath -Value $content -NoNewline
    }
}

# ==================================================
# GlazeWM Setup
# ==================================================
$glazewmDir = Join-Path $GLZR_DIR "glazewm"
New-Item -ItemType Directory -Force -Path $glazewmDir | Out-Null

# Copy main config
Copy-Item (Join-Path $WINDOTS_DIR "themes\glazewm\config.yaml") (Join-Path $glazewmDir "config.yaml") -Force
Write-Host "GlazeWM config.yaml installed to $glazewmDir"

# Copy profiles
$profilesSrc = Join-Path $WINDOTS_DIR "themes\glazewm\profiles"
$profilesDest = Join-Path $glazewmDir "profiles"
if (Test-Path $profilesSrc) {
    New-Item -ItemType Directory -Force -Path $profilesDest | Out-Null
    Copy-Item "$profilesSrc\*" $profilesDest -Recurse -Force
    Write-Host "GlazeWM profiles installed to $profilesDest"
}

# Replace __VSCODE_PATH__ placeholder with actual VS Code path
$vsCodePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd" -replace '\\', '/'
$configPath = Join-Path $glazewmDir "config.yaml"
$defaultProfile = Join-Path $profilesDest "default.yaml"
$workProfile = Join-Path $profilesDest "work.yaml"

Update-FilePlaceholder -FilePath $configPath -Placeholder "__VSCODE_PATH__" -Replacement $vsCodePath
Update-FilePlaceholder -FilePath $defaultProfile -Placeholder "__VSCODE_PATH__" -Replacement $vsCodePath
Update-FilePlaceholder -FilePath $workProfile -Placeholder "__VSCODE_PATH__" -Replacement $vsCodePath

Write-Host "GlazeWM configs installed to $glazewmDir"

# ==================================================
# Install yasb (status bar) via winget
# ==================================================
$yasbExe = Join-Path $env:ProgramFiles "YASB\yasb.exe"
if (-not (Test-Path $yasbExe)) {
    Write-Host "Installing yasb (status bar) via winget..."
    winget install --id AmN.yasb --exact --accept-source-agreements --accept-package-agreements --disable-interactivity
    if (-not (Test-Path $yasbExe)) {
        Write-Warning "yasb may not have installed. Install manually: winget install AmN.yasb"
    }
} else {
    Write-Host "yasb already installed. Skipping."
}

# ==================================================
# Launch GlazeWM
# ==================================================
if (Test-Path $glazeExe) {
    Write-Host "`nLaunching GlazeWM..."
    Start-Process -FilePath $glazeExe -WorkingDirectory $glazeInstallDir
} else {
    Write-Warning "GlazeWM.exe not found."
}

Write-Host "`n=========================================="
Write-Host " windots installation complete!"
Write-Host "=========================================="
Write-Host " Repo: $WINDOTS_DIR"
Write-Host " GlazeWM config: $glazewmDir"
Write-Host " yasb config: $env:USERPROFILE\.config\yasb"
Write-Host ""
Write-Host " Profile toggle: win+ctrl+p"
Write-Host "=========================================="
