#!/usr/bin/env bash
# =====================================================================
# Wisp Dotfiles - Robust Installation Script
# Inspired by Hyde dotfiles and Caelestia's manifest.toml architecture.
#
# manifest.toml is the ONLY place packages/entries/hooks are declared --
# this script reads it via scripts/manifest.py rather than keeping a
# second, hand-maintained copy (the two drifted apart before; don't
# reintroduce a second list here).
# =====================================================================

set -e

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$XDG_CONFIG_HOME"
BACKUP_DIR="${HOME}/.config.bak/wisp_$(date +%Y%m%d_%H%M%S)"
MANIFEST_PY="$DOTS_DIR/scripts/manifest.py"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

msg() { echo -e "${BLUE}::${NC} $1"; }
msg_ok() { echo -e "${GREEN}::${NC} $1"; }
msg_warn() { echo -e "${YELLOW}::${NC} $1"; }
msg_err() { echo -e "${RED}::${NC} $1"; }

echo -e "${BLUE}"
cat << "EOF"
 _       __ _                 ____         __
| |     / /(_)_____ ____     / __ \ ____  / /_ _____
| | /| / // // ___// __ \   / / / // __ \/ __// ___/
| |/ |/ // /(__  )/ /_/ /  / /_/ // /_/ / /_ (__  )
|__/|__//_//____// .___/  /_____/ \____/\__//____/
                /_/
EOF
echo -e "${NC}Wisp Dotfiles Installer\n"

if ! python3 -c 'import tomllib' >/dev/null 2>&1; then
    msg_err "python3 with tomllib (3.11+) is required to read manifest.toml."
    exit 1
fi

# --- Argument parsing ---
# --noconfirm skips the optional-component prompt and passes through to the
# AUR helper. --enable/--disable take a comma-separated component list and,
# like caelestia-cli, suppress the interactive prompt when given explicitly.
NOCONFIRM=false
ENABLE_ARG=""
DISABLE_ARG=""
for arg in "$@"; do
    case "$arg" in
        --noconfirm) NOCONFIRM=true ;;
        --enable=*) ENABLE_ARG="${arg#--enable=}" ;;
        --disable=*) DISABLE_ARG="${arg#--disable=}" ;;
        -h|--help)
            echo "Usage: install.sh [--noconfirm] [--enable=comp,comp] [--disable=comp,comp]"
            exit 0
            ;;
        *) msg_warn "Unknown argument: $arg" ;;
    esac
done

MANIFEST_ARGS=()
[ -n "$ENABLE_ARG" ] && MANIFEST_ARGS+=(--enable "$ENABLE_ARG")
[ -n "$DISABLE_ARG" ] && MANIFEST_ARGS+=(--disable "$DISABLE_ARG")

is_enabled() {
    local c="$1" e
    for e in "${ENABLED_COMPONENTS[@]}"; do
        [ "$e" = "$c" ] && return 0
    done
    return 1
}

run_hooks() {
    local kind="$1" hook
    while IFS= read -r hook; do
        [ -n "$hook" ] || continue
        msg "Hook: $hook"
        eval "$hook" || msg_warn "hook failed: $hook"
    done < <(python3 "$MANIFEST_PY" hooks "$kind" "${MANIFEST_ARGS[@]}")
}

# 0. Component selection
# Only prompt when the user didn't already tell us what they want via flags --
# same rule caelestia-cli uses (explicit flags mean "don't ask me again").
if [ -z "$ENABLE_ARG" ] && [ -z "$DISABLE_ARG" ] && [ "$NOCONFIRM" != true ]; then
    mapfile -t OPTIONAL < <(python3 "$MANIFEST_PY" components | awk -F'\t' '$2 == 0 { print $1 }')
    if [ ${#OPTIONAL[@]} -gt 0 ]; then
        msg "Optional components available: ${OPTIONAL[*]}"
        read -r -p "Enable which of these? (comma-separated, blank for none): " reply
        reply="$(echo "$reply" | tr -d '[:space:]')"
        if [ -n "$reply" ]; then
            ENABLE_ARG="$reply"
            MANIFEST_ARGS=(--enable "$ENABLE_ARG")
        fi
    fi
fi

mapfile -t ENABLED_COMPONENTS < <(python3 "$MANIFEST_PY" enabled "${MANIFEST_ARGS[@]}")

# 1. Detect / bootstrap AUR Helper
AUR_HELPER=""
if command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
elif command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
elif command -v pacman >/dev/null 2>&1; then
    msg_warn "No AUR helper (paru/yay) found. Building paru from AUR..."
    sudo pacman -S --needed --noconfirm base-devel git
    BUILD_DIR="$(mktemp -d)"
    if git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$BUILD_DIR" >/dev/null 2>&1 \
        && (cd "$BUILD_DIR" && makepkg -si --noconfirm); then
        AUR_HELPER="paru"
        msg_ok "paru installed."
    else
        msg_warn "Failed to build paru automatically. Package installation will be skipped."
    fi
    rm -rf "$BUILD_DIR"
else
    msg_warn "Not on Arch (no pacman). Skipping package installation."
fi

# 2. Dependency detection + install (packages come from manifest.toml, not a
# second hardcoded list -- that duplication is what caused it to drift last time)
mapfile -t DESIRED < <(python3 "$MANIFEST_PY" packages "${MANIFEST_ARGS[@]}")
INSTALLED_PACKAGES=()
if [ ${#DESIRED[@]} -gt 0 ]; then
    msg "Checking ${#DESIRED[@]} package(s) declared in manifest.toml..."
    MISSING=()
    for p in "${DESIRED[@]}"; do
        pacman -Qi "$p" >/dev/null 2>&1 || MISSING+=("$p")
    done

    if [ ${#MISSING[@]} -eq 0 ]; then
        msg_ok "All manifest packages already installed."
    elif [ -n "$AUR_HELPER" ]; then
        msg "Missing: ${MISSING[*]}"
        msg "Installing via $AUR_HELPER..."
        $AUR_HELPER -S --needed --noconfirm "${MISSING[@]}" || msg_warn "Some packages failed to install."
        msg_ok "Packages installed."
    else
        msg_warn "Missing packages (no AUR helper to install them): ${MISSING[*]}"
    fi
    for p in "${DESIRED[@]}"; do
        pacman -Qi "$p" >/dev/null 2>&1 && INSTALLED_PACKAGES+=("$p")
    done
fi

# 2.5 Wisp Shell Core Dependency
# Not a pacman/AUR package (unpublished) -- bootstrapped by cloning into its
# real home (~/.local/share/wisp-shell, not /tmp) and running its own
# ./setup install, independent of the manifest package list. We check the
# install directory itself, not just `command -v wisp`, since a PATH-only
# check misses a half-finished/broken clone with no dependencies installed.
WISP_SHELL_DIR="$HOME/.local/share/wisp-shell"
if [ ! -d "$WISP_SHELL_DIR" ]; then
    msg_warn "Wisp Shell not found. Cloning to $WISP_SHELL_DIR..."
    mkdir -p "$(dirname "$WISP_SHELL_DIR")"
    git clone https://github.com/cavalinho-xdd/wisp-shell.git "$WISP_SHELL_DIR" >/dev/null 2>&1
    bash "$WISP_SHELL_DIR/setup" install
    msg_ok "Wisp Shell installed."
elif ! command -v wisp >/dev/null 2>&1; then
    msg_warn "Wisp Shell directory exists but 'wisp' isn't on PATH. Re-running its setup..."
    bash "$WISP_SHELL_DIR/setup" install
    msg_ok "Wisp Shell setup re-run."
else
    msg_ok "Wisp Shell is already installed."
fi

run_hooks post_package

# 3. Deploy configurations
# hypr is symlinked, not copied: wisp-shell's own settings app writes
# directly into ~/.config/hypr/*.lua live (see wisp-shell CLAUDE.md), so a
# copy-based deploy would silently overwrite those live edits on every
# reinstall/update. Symlinking makes ~/.config/hypr *be* this repo, so live
# edits land in the repo (and `git diff` here shows the real state) instead
# of getting clobbered. Everything else is plain-copied since wisp never
# edits those live.
msg "Deploying configurations..."
mkdir -p "$CONFIG_DIR"

deploy_symlink() {
    local comp="$1" src="$2" dest="$3"
    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        msg_ok "$comp already symlinked -> $dest"
        return
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        msg_warn "Backing up existing $comp to $BACKUP_DIR/$comp"
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/$comp"
    fi
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    msg_ok "Symlinked $comp -> $dest"
}

deploy_copy() {
    local comp="$1" src="$2" dest="$3"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        msg_warn "Backing up existing $comp to $BACKUP_DIR/$comp"
        mkdir -p "$BACKUP_DIR"
        cp -r "$dest" "$BACKUP_DIR/$comp"
    fi
    if [ -d "$src" ]; then
        mkdir -p "$dest"
        rsync -a "$src/" "$dest/"
    else
        mkdir -p "$(dirname "$dest")"
        # Write to a tempfile in the same dir then rename over dest -- an
        # in-place `cp` can leave a truncated file behind if interrupted
        # mid-write, `mv` within one filesystem is atomic.
        local tmp
        tmp="$(mktemp "$(dirname "$dest")/.$(basename "$dest").XXXXXX")"
        cp "$src" "$tmp"
        mv -f "$tmp" "$dest"
    fi
    msg_ok "Synced $comp -> $dest"
}

DEPLOYED_DESTS=()
while IFS=$'\t' read -r comp raw_src raw_dest; do
    [ -n "$comp" ] || continue
    src="$DOTS_DIR/$raw_src"
    dest="$(eval echo "$raw_dest")"

    if [ ! -e "$src" ]; then
        msg_warn "missing in wisp-dots, skipping: $raw_src"
        continue
    fi

    if [ "$comp" = "hypr" ]; then
        deploy_symlink "$comp" "$src" "$dest"
    else
        deploy_copy "$comp" "$src" "$dest"
    fi
    DEPLOYED_DESTS+=("$dest")
done < <(python3 "$MANIFEST_PY" entries "${MANIFEST_ARGS[@]}")
msg_ok "Configurations deployed."

# 4. Spicetify / Vesktop Setup (only if already present -- neither is
# installed by this script since both are optional manifest components)
msg "Checking optional integrations..."
if command -v spicetify >/dev/null 2>&1; then
    msg "Configuring Spicetify for Wisp/Matugen..."
    spicetify config current_theme Matugen color_scheme Matugen || true
    spicetify apply >/dev/null 2>&1 || true
    msg_ok "Spicetify configured."
fi

# 5. Bootstrapping dynamic themes via Matugen
msg "Bootstrapping Matugen colors..."
# matugen does not create nested output directories itself (verified: a
# template pointed at a not-yet-existing dir errors out rather than
# mkdir -p'ing it) -- template output dirs that don't already exist from a
# component deploy above need to be made ahead of time.
mkdir -p "$HOME/.local/share/color-schemes"
# wisp-shell ships no bundled default wallpaper (there is no assets/ dir in
# that repo) -- find whatever is actually the current wallpaper instead:
# wisp's own settings.json first (source of truth once wisp has run at least
# once), then the live awww/swww daemon, then just the first image in the
# user's wallpaper folder.
WP_PATH=""
WISP_SETTINGS="$XDG_CONFIG_HOME/wisp/settings.json"
if [ -f "$WISP_SETTINGS" ] && command -v jq >/dev/null 2>&1; then
    WP_PATH="$(jq -r '.colors.lastWallpaper // empty' "$WISP_SETTINGS" 2>/dev/null)"
fi
if [ -z "$WP_PATH" ] || [ ! -f "$WP_PATH" ]; then
    if command -v awww >/dev/null 2>&1; then
        WP_PATH="$(awww query 2>/dev/null | grep -oP "image: \K\S+" | head -1)"
    fi
fi
if [ -z "$WP_PATH" ] || [ ! -f "$WP_PATH" ]; then
    WALL_DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME")/Wallpapers"
    WP_PATH="$(find "$WALL_DIR" -maxdepth 1 -iregex '.*\.\(jpg\|jpeg\|png\)' 2>/dev/null | head -1)"
fi

if command -v matugen >/dev/null 2>&1; then
    if [ -n "$WP_PATH" ] && [ -f "$WP_PATH" ]; then
        matugen image "$WP_PATH" --source-color-index 0 -q >/dev/null 2>&1 || true
        msg_ok "Matugen theme applied from $WP_PATH."
    else
        msg_warn "No wallpaper found. Run 'matugen image <path>' later."
    fi
else
    msg_warn "Matugen not found! Please install it for dynamic colors."
fi

# 5.5. Qt/KDE apps (Dolphin, etc): activate the matugen-generated theme.
# qt5ct.conf/qt6ct.conf aren't matugen templates themselves (QSettings
# doesn't do variable expansion, so they need a real absolute $HOME baked
# in) -- matugen only regenerates the *content* they point at
# (colors/matugen.conf, qss/matugen-style.qss) on every wallpaper change.
msg "Configuring Qt platform theme (qtengine + qt5ct/qt6ct fallback)..."
for QTV in qt5ct qt6ct; do
    mkdir -p "$CONFIG_DIR/$QTV/colors" "$CONFIG_DIR/$QTV/qss"
    cat > "$CONFIG_DIR/$QTV/$QTV.conf" << EOF
[Appearance]
style=Fusion
color_scheme_path=$CONFIG_DIR/$QTV/colors/matugen.conf
custom_palette=true
standard_dialogs=default

[Interface]
stylesheets=$CONFIG_DIR/$QTV/qss/matugen-style.qss
EOF
done
# QT_QPA_PLATFORMTHEME=qtengine (hypr/env.lua) -- like all Hyprland 'env'
# values this only takes effect for a compositor that starts fresh, not one
# already running (e.g. this install script's own session, if re-run).
# hl.env() is the runtime equivalent -- apply it now too so it doesn't need
# a log out/in on top of the install.
if command -v hyprctl >/dev/null 2>&1; then
    hyprctl eval 'hl.env("QT_QPA_PLATFORMTHEME", "qtengine")' >/dev/null 2>&1 || true
fi
msg_ok "Qt platform theme configured (qtengine, qt5ct/qt6ct as fallback)."

# 5.6 Firefox userChrome.css (optional component). Not a manifest entry:
# Firefox profile dirs are randomly named (<8 random chars>.default-release),
# so there's no static dest to copy to -- profiles.ini has to be parsed to
# find the real one.
if is_enabled firefox; then
    msg "Deploying Firefox userChrome.css..."
    FF_ROOT="$HOME/.mozilla/firefox"
    FF_PROFILE_DIR=""
    if [ -f "$FF_ROOT/profiles.ini" ]; then
        # Modern profiles.ini has an [InstallXXXXXXXX] section whose Default=
        # is the real default profile dir; [ProfileN] sections also have a
        # Default=1 flag but that's legacy and not always kept in sync, so
        # the Install section wins when present.
        FF_PROFILE_NAME="$(awk -F= '
            /^\[Install/ { in_install=1; next }
            /^\[/ { in_install=0 }
            in_install && /^Default=/ { print $2; exit }
        ' "$FF_ROOT/profiles.ini")"
        if [ -n "$FF_PROFILE_NAME" ] && [ -d "$FF_ROOT/$FF_PROFILE_NAME" ]; then
            FF_PROFILE_DIR="$FF_ROOT/$FF_PROFILE_NAME"
        fi
    fi
    if [ -z "$FF_PROFILE_DIR" ]; then
        FF_PROFILE_DIR="$(find "$FF_ROOT" -maxdepth 1 -type d -iname "*.default*" 2>/dev/null | head -1)"
    fi
    if [ -n "$FF_PROFILE_DIR" ] && [ -d "$FF_PROFILE_DIR" ]; then
        mkdir -p "$FF_PROFILE_DIR/chrome"
        cp "$DOTS_DIR/firefox/userChrome.css" "$FF_PROFILE_DIR/chrome/userChrome.css"
        # user.js may already exist with unrelated prefs -- append our pref
        # only if it isn't already set, never overwrite the whole file.
        grep -q "legacyUserProfileCustomizations" "$FF_PROFILE_DIR/user.js" 2>/dev/null \
            || cat "$DOTS_DIR/firefox/user.js" >> "$FF_PROFILE_DIR/user.js"
        msg_ok "Firefox userChrome.css deployed to $(basename "$FF_PROFILE_DIR") (restart Firefox to apply)."
    else
        msg_warn "No Firefox profile found -- launch Firefox once, then re-run: install.sh --enable=firefox"
    fi
fi

# 6. Post-install hooks declared in manifest.toml (hyprctl reload, btop
# refresh, starting the wisp daemon, etc) -- see manifest.toml itself for
# the full, current list instead of duplicating it here.
msg "Running post-install hooks..."
run_hooks post_install

# 6.5 Write deployed-state JSON: what got enabled/installed/placed this run.
# Not read by this script -- groundwork for a future update/uninstall
# command that needs to know what to touch without re-deriving it,
# same role as caelestia-cli's DotsState.
msg "Recording install state..."
STATE_FILE="$XDG_CONFIG_HOME/wisp-dots/state.json"
mkdir -p "$(dirname "$STATE_FILE")"

STATE_PY="$(mktemp)"
cat > "$STATE_PY" <<'PYEOF'
import datetime
import json
import sys
from pathlib import Path

state_path, aur_helper = Path(sys.argv[1]), sys.argv[2]


def read_block():
    lines = []
    for line in sys.stdin:
        line = line.rstrip("\n")
        if line == "---":
            break
        if line:
            lines.append(line)
    return lines


enabled = read_block()
packages = read_block()
dests = read_block()

state_path.write_text(
    json.dumps(
        {
            "aur_helper": aur_helper,
            "enabled_components": enabled,
            "packages": packages,
            "deployed_dests": dests,
            "installed_at": datetime.datetime.now().isoformat(timespec="seconds"),
        },
        indent=2,
    )
    + "\n"
)
PYEOF

python3 "$STATE_PY" "$STATE_FILE" "$AUR_HELPER" <<STATEIN
$(printf '%s\n' "${ENABLED_COMPONENTS[@]}")
---
$(printf '%s\n' "${INSTALLED_PACKAGES[@]}")
---
$(printf '%s\n' "${DEPLOYED_DESTS[@]}")
---
STATEIN
rm -f "$STATE_PY"
msg_ok "State recorded at $STATE_FILE"

# Set fish as default shell if not already
if [[ "$SHELL" != *fish ]]; then
    msg_warn "Consider setting fish as your default shell: chsh -s \$(which fish)"
fi

msg "Applying GTK and Icon Themes via gsettings..."
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' || true
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
    msg_ok "GTK preferences configured."
fi

echo ""
msg_ok "Installation Complete! A backup of anything replaced is in $BACKUP_DIR."
echo -e "${GREEN}Welcome to Wisp.${NC}"
