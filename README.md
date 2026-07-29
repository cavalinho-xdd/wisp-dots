<div align="center">
  <h1>Wisp Dotfiles</h1>
  <p>A cohesive, dynamically themed dotfiles collection for the Wisp Shell ecosystem.</p>
  <a href="#installation">Installation</a> •
  <a href="#customizing-your-install">Customization</a> •
  <a href="#dynamic-theming">Theming</a> •
  <a href="#repository-structure">Structure</a>
</div>

<br>

This repository provides the underlying system configurations that power the Wisp desktop experience: a Hyprland config written against wisp-shell's own Lua config layer, plus a Matugen pipeline that themes every other supported app from your wallpaper's color palette. `install.sh` deploys all of it, installs the packages it depends on, and bootstraps [wisp-shell](https://github.com/cavalinho-xdd/wisp-shell) itself if it isn't already on your machine.

The Hyprland config shipped here is a generic default — it makes no assumptions about how many monitors you have or what they're named. Anything specific to your own machine (GPU-vendor env vars, per-monitor workspace layout, extra autostart apps) is meant to live in a local override file that this repo never commits — see [Customizing your install](#customizing-your-install).

## Table of Contents
- [Supported Environments](#supported-environments)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Automated Setup](#automated-setup)
  - [Install Flags](#install-flags)
  - [Components](#components)
- [Customizing Your Install](#customizing-your-install)
- [Dynamic Theming](#dynamic-theming)
- [Wisp Shell Integration](#wisp-shell-integration)
- [Repository Structure](#repository-structure)
- [Known Limitations](#known-limitations)
- [License](#license)

## Supported Environments
Wisp Dotfiles natively configures and themes the following tools:
- **Desktop Environment**: Hyprland (Lua config, see [Wisp Shell Integration](#wisp-shell-integration))
- **Terminal**: Kitty
- **Shell & Prompt**: Fish, Starship
- **System Monitors**: Btop, Fastfetch
- **Text Editor**: Micro
- **Qt/KDE apps** (Dolphin, etc.): qtengine (primary), qt5ct/qt6ct (fallback)
- **GTK apps**: adw-gtk3-dark + Papirus-Dark icons + Bibata-Modern-Classic cursors, applied via `gsettings`
- **Clipboard**: `wl-clipboard` + `cliphist`
- **Optional**: Spotify (via Spicetify), Discord (via Vesktop), Firefox (`userChrome.css`)

## Installation

### Prerequisites
- A booted, network-connected Arch Linux (or Arch-based) install with `git` and `base-devel` available.
- You do **not** need to install Hyprland yourself first — it's declared as a package in this repo's manifest and gets installed for you.
- An AUR helper (`paru` or `yay`) is preferred but not required — if neither is found, the installer builds `paru` from the AUR automatically.

### Automated Setup
```bash
git clone https://github.com/cavalinho-xdd/wisp-dots.git ~/.config/wisp-dots
cd ~/.config/wisp-dots
./install.sh
```
Reboot (or log out and back in) once it finishes.

The installer will:
1. Detect your AUR helper, or build `paru` if you have none.
2. Install every package declared by the components you enabled, via `manifest.toml`.
3. Clone `wisp-shell` to `~/.local/share/wisp-shell` and run its own setup, if it isn't already installed.
4. Back up anything it would overwrite to `~/.config.bak/wisp_<timestamp>/`, then deploy configs to `~/.config`.
5. Generate your initial Matugen color scheme from your current (or first-found) wallpaper.
6. Configure the Qt platform theme and GTK/icon/cursor settings.
7. Run each component's post-install hooks (e.g. `hyprctl reload`).

### Install Flags
```bash
./install.sh [--noconfirm] [--enable=comp,comp] [--disable=comp,comp]
```
- `--noconfirm` — skip the optional-component prompt, install defaults only.
- `--enable=spotify,discord,firefox` — also install specific optional components.
- `--disable=btop,micro` — skip specific default components.
- Passing `--enable`/`--disable` explicitly also skips the interactive prompt.

Re-running `install.sh` later is safe — it's idempotent (existing symlinks/packages are detected and skipped) and re-backs-up anything it would otherwise clobber.

### Components
| Component | Default | Notes |
|---|---|---|
| `hypr` | yes | Hyprland config, symlinked (see below) |
| `matugen` | yes | wallpaper → color pipeline |
| `qt-theme` | yes | qtengine + qt5ct/qt6ct fallback |
| `fish` | yes | shell, prompt, greeting |
| `kitty` | yes | terminal |
| `fastfetch` | yes | |
| `btop` | yes | |
| `micro` | yes | |
| `clipboard` | yes | `wl-clipboard`, `cliphist` |
| `tools` | yes | curl, git, jq, lazygit, bat, ripgrep, ydotool, xdg-user-dirs |
| `spotify` | no | Spicetify + Matugen theme + marketplace |
| `discord` | no | Vesktop |
| `firefox` | no | `userChrome.css`, profile auto-detected via `profiles.ini` |

Run `python3 scripts/manifest.py components` to print this list straight from `manifest.toml` (source of truth).

## Customizing Your Install
Two files exist specifically for machine-local state that this repo never ships or commits (both are in `.gitignore`):

- **`hypr/local.lua`** — required (if present) at the end of `hyprland.lua`. Put GPU-vendor env vars (`hl.env(...)`), real monitor names/layout (`hl.monitor`, `hl.workspace_rule`), and any personal autostart commands here. `install.sh` touches this file into existence (empty) on first install so `hyprland.lua`'s require never breaks — but it's gitignored, so it stays yours only.
- **`hypr/keybinds_custom.lua`** — written to at runtime by wisp-shell's Settings → Keybinds → Add keybind. Also recreated empty (header comment only) by `install.sh` on first install, also gitignored.

Because `hypr/` is deployed as a **symlink** (`~/.config/hypr` → this repo's `hypr/`), both files simply live inside the repo directory on disk without ever being tracked by git — `git status` in `~/.config/wisp-dots` will always show them as clean/ignored, not as changes to commit.

## Dynamic Theming
Wisp abandons hardcoded colors. Instead, it uses **Matugen** to extract a color palette directly from your wallpaper and dynamically generate configurations for your entire system — Kitty, Fastfetch, Btop, Starship, qtengine, qt5ct/qt6ct, and (if enabled) Spicetify/Vesktop.

To change the look of your desktop and all supported applications simultaneously:
```bash
matugen image /path/to/your/wallpaper.jpg
```
This regenerates all templates in `matugen/config.toml` and instantly reapplies the new color scheme.

## Wisp Shell Integration
This repo is designed to be used with [wisp-shell](https://github.com/cavalinho-xdd/wisp-shell)'s quickshell-based widgets, and its Hyprland config is written specifically against wisp-shell's Lua config layer (`hl.*`), **not** classic hyprlang `.conf`/`$variable` syntax. A few things to know if you're editing this config by hand:

- `hl.env(name, value[, dbus])` is the correct way to set environment variables — `hl.config({ env = {...} })` is a silent no-op, it does nothing and raises no error.
- wisp-shell's Settings app writes live edits directly into `general.lua` (gaps/border/rounding/blur), `animations.lua` (the global animation toggle), and `keybinds_custom.lua` (rebinds) — it parses these files with fixed regexes, so if you hand-edit the surrounding syntax (e.g. renaming `gaps_in` or restructuring the `blur = {...}` table), Settings will silently stop being able to apply changes there. Stick to editing values, not shapes, if you want Settings to keep working.
- `hypr/` is symlinked rather than copied specifically so these live Settings edits land in the repo (and are visible via `git diff`/`git status`) instead of being silently overwritten on the next `install.sh` run.

## Repository Structure
- `hypr/` — Hyprland config, written in Lua (`hl.*` API). See [Wisp Shell Integration](#wisp-shell-integration).
- `matugen/` — `config.toml` pipeline plus the raw templates it renders.
- `qtengine/`, `fish/`, `kitty/`, `fastfetch/`, `btop/`, `micro/`, `firefox/` — per-app config, deployed by `install.sh`.
- `manifest.toml` — single source of truth for packages, deploy entries, and install/update hooks per component.
- `scripts/manifest.py` — reads `manifest.toml` for `install.sh`.
- `install.sh` — the installer described above.

## Known Limitations
- `matugen/templates/hyprland-colors.conf` generates classic hyprlang `$variable` syntax, which the Lua-based Hyprland config doesn't read — Hyprland's own border colors are currently static, not wallpaper-driven. Everything else in the Dynamic Theming list above works.
- No `install.sh uninstall`/`update` subcommand yet. Each run writes what it did to `~/.config/wisp-dots/state.json`, which is groundwork for one, but nothing currently reads that file back.

## License
This project is licensed under the MIT License.
