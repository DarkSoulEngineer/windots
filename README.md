<div align="center">

# windots

**A modern Windows desktop environment.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GlazeWM](https://img.shields.io/badge/GlazeWM-v3.9-0EB0C1?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZD0iTTEyIDJMMyA3djEwbDkgNSA5LTVIN0wxMiAyeiIgZmlsbD0iIzBFQjBCMUEiLz48L3N2Zz4=)](https://github.com/glzr-io/glazewm)
[![Zebar](https://img.shields.io/badge/Zebar-v3.1-F472B6?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHJlY3Qgd2lkdGg9IjI0IiBoZWlnaHQ9IjI0IiByeD0iNCIgZmlsbD0iI0Y0NzJCNiIvPjwvc3ZnPg==)](https://github.com/glzr-io/zebar)
[![Wallust](https://img.shields.io/badge/Wallust-v3.4-A78BFA)](https://codeberg.org/explosion-mental/wallust)

Tiling window manager, status bar, and color scheme generator
all wired together for a seamless Windows experience.

![Desktop preview](assets/screenshots/full-desktop-terminal.png)

</div>

---

## What is this?

windots bundles [GlazeWM](https://github.com/glzr-io/glazewm) (tiling WM),
[Zebar](https://github.com/glzr-io/zebar) (status bar), and
[Walzr](https://github.com/DarkSoulEngineer/windots) (wallust fork for Windows)
into a single repo with ready-to-use configs, themes, and a one-line installer.

### Features

- **Tiling window management** with vim-style navigation
- **Neon-themed status bar** with cava audio visualizer, weather, battery, disk, and volume widgets
- **Automatic colorscheme generation** from any wallpaper image
- **Multi-monitor support** with per-monitor workspace binding
- **One-line installer** that sets up everything

---

## Screenshots

| | |
|:---:|:---:|
| ![Zebar bar](assets/screenshots/zebar-normal.png) | ![Power menu](assets/screenshots/power-menu.png) |
| *Zebar status bar* | *Power menu overlay* |
| ![Multi-window layout](assets/screenshots/multi-window-layout.png) | ![Brave on workspace](assets/screenshots/brave-workspace.png) |
| *Tiling multi-window layout* | *Brave browser on workspace 3* |

---

## Quick Install

Open **PowerShell as Administrator** and run:

```powershell
iex (iwr "https://raw.githubusercontent.com/DarkSoulEngineer/windots/main/installer/install.ps1" -UseBasicParsing).Content
```

<details>
<summary>What does the installer do?</summary>

1. Installs prerequisites (Chocolatey, Git, Rust MSVC toolchain, VS Build Tools)
2. Installs GlazeWM and Zebar via MSI
3. Clones this repo to `~/windots`
4. Copies GlazeWM config + profiles to `~/.glzr/glazewm/`
5. Copies Zebar theme + settings to `~/.glzr/zebar/`
6. Resolves all paths dynamically (no hardcoded usernames)
7. Builds and installs Walzr to `~/.cargo/bin/`
8. Launches GlazeWM (which auto-starts Zebar)

</details>

---

## Keybindings

### Navigation

| Binding | Action |
|---------|--------|
| `alt+h` / `alt+left` | Focus window left |
| `alt+l` / `alt+right` | Focus window right |
| `alt+k` / `alt+up` | Focus window up |
| `alt+j` / `alt+down` | Focus window down |

### Window Management

| Binding | Action |
|---------|--------|
| `alt+shift+h/j/k/l` | Move window in direction |
| `alt+t` | Toggle tiling |
| `alt+shift+space` | Toggle floating |
| `alt+f` | Toggle fullscreen |
| `alt+shift+t` | Toggle tiling direction |
| `alt+shift+q` | Close window |

### Workspaces

| Binding | Action |
|---------|--------|
| `alt+1`-`alt+0` | Switch to workspace |
| `alt+shift+1`-`alt+shift+0` | Move window to workspace |
| `alt+shift+a/d` | Move workspace between monitors |

### App Launchers

| Binding | Action |
|---------|--------|
| `alt+c` | Terminal (Windows Terminal) |
| `alt+b` | Browser (Brave) |
| `alt+e` | File Explorer |
| `alt+v` | VS Code |

### Modes

| Binding | Action |
|---------|--------|
| `alt+r` | Enter resize mode (h/j/k/l to resize, `alt+r` to exit) |
| `alt+d` | Enter passthrough mode (`alt+d` to exit) |

---

## Walzr

Walzr is a Rust CLI tool (fork of [wallust](https://codeberg.org/explosion-mental/wallust)) that extracts dominant colors from any wallpaper image and generates a full 16-color scheme. It can apply these colors directly to your desktop environment:

- **GlazeWM** - Updates window border accent colors to match your wallpaper
- **Zebar** - Injects accent colors into the bar theme CSS variables
- **Windows Terminal** - Adds a matching color scheme to your terminal profiles

```powershell
# Generate colorscheme from wallpaper
wallust run my_wallpaper.png

# Apply colors to GlazeWM borders + Zebar theme + Windows Terminal
wallust run my_wallpaper.png --glazewm --zebar
```

This means your entire desktop adapts its color palette to whatever wallpaper you set -- window borders, status bar accents, and terminal colors all stay in sync automatically.

---

## Project Structure

```
windots/
├── src/                          # Walzr source code (Rust)
├── themes/
│   ├── glazewm/
│   │   ├── config.yaml           # Main GlazeWM config
│   │   └── profiles/
│   │       ├── default.yaml      # Default: 8px gaps, 3 monitors
│   │       └── work.yaml         # Work: 4px gaps, 2 monitors
│   └── zebar/
│       ├── settings.json         # Zebar startup config
│       ├── cava-feeder.ps1       # Audio visualizer data feeder
│       └── zebar_neon_theme/     # Neon bar theme
│           ├── index.html
│           ├── styles.css
│           └── zpack.json
├── assets/screenshots/           # Desktop screenshots
├── installer/
│   └── install.ps1               # One-line installer
├── Cargo.toml
└── wallust.toml
```

---

## Configuration

### GlazeWM

Config is installed to `~/.glzr/glazewm/config.yaml`. Edit it directly or replace with a profile:

```powershell
# Switch to work profile (smaller gaps, 2 monitors)
Copy-Item ~/windots/themes/glazewm/profiles/work.yaml ~/.glzr/glazewm/config.yaml

# Switch back to default
Copy-Item ~/windots/themes/glazewm/profiles/default.yaml ~/.glzr/glazewm/config.yaml
```

### Zebar

Theme files are installed to `~/.glzr/zebar/zebar_neon_theme/`. Edit `styles.css` to customize colors.

### Walzr

Config is at `~/.config/wallust/wallust.toml`. Default uses the `fastresize` backend with `lch` color space.

---

## Related Projects

| Project | Description |
|---------|-------------|
| [GlazeWM](https://github.com/glzr-io/glazewm) | Tiling window manager for Windows |
| [Zebar](https://github.com/glzr-io/zebar) | Cross-platform desktop widgets |
| [Wallust](https://codeberg.org/explosion-mental/wallust) | Generate colorschemes from images |

---

## License

[MIT](LICENSE)
