# windots

A unified Windows desktop environment powered by [GlazeWM](https://github.com/glzr-io/glazewm), [Zebar](https://github.com/glzr-io/zebar), and [Walzr](https://github.com/DarkSoulEngineer/windots) (wallust fork with Windows support).

## What's Included

| Component | Description |
|-----------|-------------|
| **Walzr** | CLI tool that generates colorschemes from wallpapers and applies them to GlazeWM, Zebar, and Windows Terminal |
| **GlazeWM Theme** | Tiling window manager config with vim-style keybindings, profile system (default/work), multi-monitor workspaces |
| **Zebar Neon Theme** | Vibrant neon-themed top bar with cava audio visualizer, weather, battery, disk usage, volume controls |
| **Installer** | One-liner PowerShell installer that sets up everything |

## Quick Install

Open **PowerShell as Administrator** and run:

```powershell
iex (iwr "https://raw.githubusercontent.com/DarkSoulEngineer/windots/main/installer/install.ps1" -UseBasicParsing).Content
```

## What the Installer Does

1. Installs prerequisites (Chocolatey, Git, Rust, VS Build Tools, Brave)
2. Installs GlazeWM and Zebar via MSI
3. Clones this repo to `~/windots`
4. Copies configs to `~/.glzr/glazewm/` and `~/.glzr/zebar/`
5. Replaces hardcoded paths with your actual install location
6. Builds and installs Walzr to `~/.cargo/bin/`
7. Launches GlazeWM

## Project Structure

```
windots/
├── src/                        # Walzr (wallust fork) source code
├── themes/
│   ├── glazewm/
│   │   ├── config.yaml         # Main GlazeWM config
│   │   └── profiles/
│   │       ├── default.yaml    # Default profile (8px gaps, 3 monitors)
│   │       └── work.yaml       # Work profile (4px gaps, 2 monitors)
│   └── zebar/
│       ├── settings.json       # Zebar startup settings
│       ├── cava-feeder.ps1     # Cava audio data feeder script
│       └── zebar_neon_theme/   # Neon bar theme with cava visualizer
├── installer/
│   └── install.ps1             # One-liner installer
├── Cargo.toml                  # Rust project config
├── wallust.toml                # Walzr default config
└── ...
```

## Keybindings

| Binding | Action |
|---------|--------|
| `alt+h/j/k/l` | Navigate windows (vim) |
| `alt+shift+h/j/k/l` | Move windows |
| `alt+1-9,0` | Switch workspace |
| `alt+shift+1-9,0` | Move window to workspace |
| `alt+t` | Toggle tiling |
| `alt+f` | Toggle fullscreen |
| `alt+r` | Enter resize mode |
| `alt+d` | Enter passthrough mode |
| `alt+c` | Open terminal |
| `alt+b` | Open browser |
| `alt+e` | Open file explorer |
| `alt+v` | Open VS Code |
| `win+ctrl+p` | Toggle profile (default/work) |

## Walzr Usage

```powershell
# Generate colorscheme from wallpaper
wallust run my_wallpaper.png

# Apply to GlazeWM + Zebar
wallust run my_wallpaper.png --glazewm --zebar
```

## License

MIT
