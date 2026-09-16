<div align="center">

# windots

**A modern Windows desktop environment.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GlazeWM](https://img.shields.io/badge/GlazeWM-v3.9-0EB0C1?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZD0iTTEyIDJMMyA3djEwbDkgNSA5LTVIN0wxMiAyeiIgZmlsbD0iIzBFQjBCMUEiLz48L3N2Zz4=)](https://github.com/glzr-io/glazewm)
[![yasb](https://img.shields.io/badge/yasb-v2.0.7-8B5CF6)](https://github.com/amnweb/yasb)

Tiling window manager, customizable status bar, and a one-line installer
for a seamless Windows experience.

![Desktop preview](assets/screenshots/full-desktop-terminal.png)

</div>

---

## What is this?

windots bundles [GlazeWM](https://github.com/glzr-io/glazewm) (tiling WM) and
[yasb](https://github.com/amnweb/yasb) (status bar) with ready-to-use configs,
themes, and a one-line installer.

### Features

- **Tiling window management** with vim-style navigation
- **Feature-rich status bar** with taskbar, audio visualizer, weather, volume, control center, and system tray widgets
- **Multi-monitor support** with per-monitor workspace binding
- **One-line installer** that sets up everything

---

## Screenshots

| | |
|:---:|:---:|
| ![Power menu](assets/screenshots/power-menu.png) | ![Multi-window layout](assets/screenshots/multi-window-layout.png) |
| *Power menu overlay* | *Tiling multi-window layout* |
| ![Brave on workspace](assets/screenshots/brave-workspace.png) | |
| *Brave browser on workspace 3* | |

---

## Quick Install

Open **PowerShell as Administrator** and run:

```powershell
iex (iwr "https://raw.githubusercontent.com/DarkSoulEngineer/windots/main/installer/install.ps1" -UseBasicParsing).Content
```

<details>
<summary>What does the installer do?</summary>

1. Installs prerequisites (Chocolatey, Git, Brave)
2. Installs GlazeWM via MSI
3. Clones this repo to `~/windots`
4. Copies GlazeWM config + profiles to `~/.glzr/glazewm/`
5. Resolves all paths dynamically (no hardcoded usernames)
6. Installs yasb via winget
7. Launches GlazeWM

</details>

> yasb watches `~/.config/yasb/config.yaml` and `~/.config/yasb/styles.css` for changes,
> so styling is entirely config-driven. See [Configuration](#configuration) to make it your own.

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

## Project Structure

```
windots/
├── themes/
│   └── glazewm/
│       ├── config.yaml           # Main GlazeWM config
│       └── profiles/
│           ├── default.yaml      # Default: 8px gaps, 3 monitors
│           └── work.yaml         # Work: 4px gaps, 2 monitors
├── assets/screenshots/           # Desktop screenshots
├── installer/
│   ├── install.ps1               # One-line installer
│   └── README.md
├── README.md
└── LICENSE
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

The installer also registers yasb in GlazeWM's `startup_commands`, so the status bar launches automatically when GlazeWM starts.

### yasb

Config is at `~/.config/yasb/config.yaml` (bars, widgets, and layout) and `~/.config/yasb/styles.css` (colors and styling). yasb watches both files, so edits apply live. The `:root` CSS variables (`--yasb-*`) in `styles.css` control the bar's colors — change them to restyle the whole bar.

---

## Related Projects

| Project | Description |
|---------|-------------|
| [GlazeWM](https://github.com/glzr-io/glazewm) | Tiling window manager for Windows |
| [yasb](https://github.com/amnweb/yasb) | Feature-rich, customizable status bar for Windows |

---

## License

[MIT](LICENSE)