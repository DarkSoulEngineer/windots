# windots Installer

One-liner installer for the **windots** desktop environment.

## Quick Install

Open **PowerShell as Administrator** and run:

```powershell
iex (iwr "https://raw.githubusercontent.com/DarkSoulEngineer/windots/main/installer/install.ps1" -UseBasicParsing).Content
```

## What it installs

- Chocolatey, Git, Rust (MSVC), VS Build Tools, Brave
- GlazeWM tiling window manager
- Zebar status bar
- windots configs (GlazeWM + Zebar themes)
- Walzr color scheme generator

## Manual Install

If you prefer to run the script directly:

```powershell
git clone https://github.com/DarkSoulEngineer/windots.git
cd windots\installer
.\install.ps1
```
