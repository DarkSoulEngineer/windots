# ===============================================
# install.ps1
# Walzr (windots) unified installer
# Installs Chocolatey + Git + Rust (MSVC only),
# Visual Studio Build Tools, GlazeWM, Zebar,
# and applies all themes from the windots repo.
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
# Install Rust via rustup
# ------------------------------
$cargoBin = "$env:USERPROFILE\.cargo\bin"
if (-not ($env:Path -split ";" | Where-Object { $_ -eq $cargoBin })) {
    $env:Path = "$cargoBin;$env:Path"
    [Environment]::SetEnvironmentVariable("PATH", "$cargoBin;" + [Environment]::GetEnvironmentVariable("PATH", "User"), "User")
}
if (-not (Test-Path "$cargoBin\rustc.exe")) {
    Write-Host "Installing Rust via rustup..."
    $rustupExe = "$env:TEMP\rustup-init.exe"
    Invoke-WebRequest -Uri https://win.rustup.rs/x86_64 -OutFile $rustupExe
    Start-Process -FilePath $rustupExe -ArgumentList "-y" -Wait
}
$rustupPath = Join-Path $cargoBin "rustup.exe"

# ------------------------------
# Configure Rust for MSVC only
# ------------------------------
Write-Host "Installing MSVC toolchain..."
& $rustupPath install stable-x86_64-pc-windows-msvc
& $rustupPath default stable-x86_64-pc-windows-msvc

# ------------------------------
# Install Visual Studio Build Tools and Brave via Choco
# ------------------------------
$vsWhere = "$env:ProgramFiles(x86)\Microsoft Visual Studio\Installer\vswhere.exe"
$vsInstalled = $false
if (Test-Path $vsWhere) {
    $vsInstalled = (& $vsWhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath) -ne ""
}
if (-not $vsInstalled) {
    Write-Host "Installing Visual Studio Build Tools..."
    Start-Process -FilePath $chocoExe -ArgumentList 'install visualstudio2022buildtools -y --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive --locale en-US"' -Wait -NoNewWindow
} else {
    Write-Host "Visual Studio Build Tools already installed. Skipping..."
}

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
$zebarInstallDir = Join-Path $glzrBase "Zebar"

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
        Write-Warning "MSI install failed. Attempting source build..."
        Remove-Item $glazeMsi -Force
        $glazeSrcDir = Join-Path $env:USERPROFILE ".glzr\glazewm"
        if (-not (Test-Path (Join-Path $glazeSrcDir ".git"))) {
            git clone https://github.com/glzr-io/glazewm.git $glazeSrcDir
        }
        Write-Host "Building GlazeWM from source..."
        Push-Location $glazeSrcDir
        cargo build --release --locked
        if ($LASTEXITCODE -ne 0) {
            Write-Error "GlazeWM build failed."
            Pop-Location
            exit
        }
        Pop-Location
        Copy-Item "$glazeSrcDir\target\release\GlazeWM.exe" $glazeInstallDir -Force
    }
    Remove-Item $glazeMsi -Force
} else {
    Write-Host "GlazeWM already installed. Skipping MSI install."
}

# ------------------------------
# Install Zebar MSI
# ------------------------------
$zebarMsiUrl = "https://github.com/glzr-io/zebar/releases/download/v3.1.1/zebar-v3.1.1-opt1-x64.msi"
$zebarMsi = "$env:TEMP\zebar-v3.1.1-opt1-x64.msi"
$zebarExe = Join-Path $zebarInstallDir "Zebar.exe"

if (-not (Test-Path $zebarExe)) {
    Write-Host "Downloading Zebar MSI..."
    Invoke-WebRequest -Uri $zebarMsiUrl -OutFile $zebarMsi

    Write-Host "Installing Zebar silently to $zebarInstallDir..."
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$zebarMsi`" TARGETDIR=`"$zebarInstallDir`" /quiet /norestart /log `"$env:TEMP\zebar_install.log`"" -Wait

    if (Test-Path $zebarExe) {
        Write-Host "Zebar installed successfully."
    } else {
        Write-Warning "Zebar installation may have failed. Check logs at $env:TEMP\zebar_install.log"
    }
    Remove-Item $zebarMsi -Force
} else {
    Write-Host "Zebar already installed. Skipping MSI install."
}

# Add Zebar to PATH
if (-not ($env:Path -split ";" | Where-Object { $_ -eq $zebarInstallDir })) {
    $env:Path = "$zebarInstallDir;$env:Path"
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if (-not ($userPath -split ";" | Where-Object { $_ -eq $zebarInstallDir })) {
        [Environment]::SetEnvironmentVariable("PATH", "$zebarInstallDir;$userPath", "User")
    }
}

# ===============================
# Clone windots repo and apply themes
# ===============================
$userProfile = $env:USERPROFILE
$windotsDir = Join-Path $env:TEMP "windots"
$windotsRepoUrl = "https://github.com/DarkSoulEngineer/windots.git"

if (-not (Test-Path (Join-Path $windotsDir ".git"))) {
    Write-Host "Cloning windots repo..."
    git clone $windotsRepoUrl $windotsDir
} else {
    Write-Host "windots repo already cloned. Pulling latest..."
    Push-Location $windotsDir
    git pull
    Pop-Location
}

# ================== Zebar Theme Setup ==================
$zebarDir = Join-Path $userProfile ".glzr\zebar"
New-Item -ItemType Directory -Force -Path $zebarDir | Out-Null

# Copy zebar theme
$zebarThemeSrc = Join-Path $windotsDir "themes\zebar\zebar_neon_theme"
$zebarThemeDest = Join-Path $zebarDir "zebar_neon_theme"
if (Test-Path $zebarThemeSrc) {
    Copy-Item -Path $zebarThemeSrc -Destination $zebarThemeDest -Recurse -Force
    Write-Host "Zebar neon theme installed to $zebarThemeDest"
}

# Copy settings.json
$zebarSettingsSrc = Join-Path $windotsDir "themes\zebar\settings.json"
$zebarSettingsDest = Join-Path $zebarDir "settings.json"
if (Test-Path $zebarSettingsSrc) {
    Copy-Item -Path $zebarSettingsSrc -Destination $zebarSettingsDest -Force
    Write-Host "Zebar settings.json installed to $zebarDir"
}

# ================== GlazeWM Theme Setup ==================
$glazewmDir = Join-Path $userProfile ".glzr\glazewm"
New-Item -ItemType Directory -Force -Path $glazewmDir | Out-Null

$glazewmConfigSrc = Join-Path $windotsDir "themes\glazewm\config.yaml"
$glazewmConfigDest = Join-Path $glazewmDir "config.yaml"
if (Test-Path $glazewmConfigSrc) {
    Copy-Item -Path $glazewmConfigSrc -Destination $glazewmConfigDest -Force
    Write-Host "GlazeWM config.yaml installed to $glazewmDir"
}

# ================== Build and install Walzr ==================
Write-Host "Building Walzr from source..."
Push-Location $windotsDir
cargo build --release
if ($LASTEXITCODE -eq 0) {
    $walzrBin = Join-Path $windotsDir "target\release\wallust.exe"
    $walzrDest = Join-Path $cargoBin "wallust.exe"
    if (Test-Path $walzrBin) {
        Copy-Item $walzrBin $walzrDest -Force
        Write-Host "Walzr installed to $walzrDest"
    }
} else {
    Write-Warning "Walzr build failed. You can build it manually later with: cargo build --release"
}
Pop-Location

# ================== Launch GlazeWM ==================
if (Test-Path $glazeExe) {
    Write-Host "`nLaunching GlazeWM (it will auto-launch Zebar)..."
    Start-Process -FilePath $glazeExe -WorkingDirectory $glazeInstallDir
} else {
    Write-Warning "GlazeWM.exe not found."
}

Write-Host "`nInstallation process complete! GlazeWM, Zebar, and Walzr are ready."
Write-Host "Repo cloned to: $windotsDir"
