# windots

A unified Windows desktop environment powered by [GlazeWM](https://github.com/glzr-io/glazewm), [Zebar](https://github.com/glzr-io/zebar), and [Walzr](https://github.com/DarkSoulEngineer/windots) (wallust fork with Windows support).

## What's Included

| Component | Description |
|-----------|-------------|
| **Walzr** | CLI tool that generates colorschemes from wallpapers and applies them to GlazeWM, Zebar, and Windows Terminal |
| **GlazeWM Theme** | Tiling window manager config with vim-style keybindings, workspaces, and window rules |
| **Zebar Neon Theme** | Vibrant neon-themed top bar widget |
| **Installer** | One-liner PowerShell installer that sets up everything |

## Quick Install

Open **PowerShell as Administrator** and run:

```powershell
iex (iwr "https://raw.githubusercontent.com/DarkSoulEngineer/windots/main/installer/install.ps1" -UseBasicParsing).Content
```

## Manual Setup

### Prerequisites
- Windows 10/11
- Git
- Rust (MSVC toolchain)

### Install dependencies
1. Install [GlazeWM](https://github.com/glzr-io/glazewm/releases) via MSI
2. Install [Zebar](https://github.com/glzr-io/zebar/releases) via MSI

### Apply themes
```powershell
# GlazeWM config
Copy-Item themes\glazewm\config.yaml "$env:USERPROFILE\.glzr\glazewm\config.yaml"

# Zebar theme
Copy-Item themes\zebar\zebar_neon_theme "$env:USERPROFILE\.glzr\zebar\zebar_neon_theme" -Recurse
Copy-Item themes\zebar\settings.json "$env:USERPROFILE\.glzr\zebar\settings.json"
```

### Build Walzr
```powershell
cargo build --release
Copy-Item target\release\wallust.exe "$env:USERPROFILE\.cargo\bin\"
```

## Usage

```powershell
# Generate colorscheme from wallpaper
wallust run my_wallpaper.png

# Apply to GlazeWM + Zebar
wallust run my_wallpaper.png --glazewm --zebar
```

## Project Structure

```
windots/
├── src/                    # Walzr (wallust fork) source code
├── themes/
│   ├── glazewm/            # GlazeWM window manager config
│   │   └── config.yaml
│   └── zebar/              # Zebar bar theme
│       ├── zebar_neon_theme/
│       └── settings.json
├── installer/
│   └── install.ps1         # One-liner installer
├── Cargo.toml
├── wallust.toml
└── ...
```

## License

MIT
