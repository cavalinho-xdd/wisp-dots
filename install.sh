#!/usr/bin/env bash
# =====================================================================
# Wisp Dotfiles - Robust Installation Script
# Inspired by Hyde dotfiles and ii-dots architecture.
# =====================================================================

set -e

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="${HOME}/.config.bak/wisp_$(date +%Y%m%d_%H%M%S)"

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

# 1. Detect AUR Helper
AUR_HELPER=""
if command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
elif command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
else
    msg_warn "No AUR helper (paru/yay) found. Skipping package installation."
fi

# 2. Package Installation
PACKAGES=(
    "hyprland" "xdg-desktop-portal-hyprland" "fish" "eza" "zoxide"
    "kitty" "fastfetch" "btop" "micro" "matugen-bin" "wl-clipboard"
    "ttf-jetbrains-mono-nerd" "jq" "ripgrep"
)

if [ -n "$AUR_HELPER" ]; then
    msg "Installing required packages via $AUR_HELPER..."
    $AUR_HELPER -S --needed --noconfirm "${PACKAGES[@]}" || msg_warn "Some packages failed to install."
    msg_ok "Packages installed."
fi

# 2.5 Wisp Shell Core Dependency
if ! command -v wisp >/dev/null 2>&1; then
    msg_warn "Wisp Shell not found. Cloning and installing from GitHub..."
    if [ -d "/tmp/wisp-shell" ]; then rm -rf "/tmp/wisp-shell"; fi
    git clone https://github.com/cavalinho-xdd/wisp-shell.git /tmp/wisp-shell >/dev/null 2>&1
    bash /tmp/wisp-shell/setup install
    rm -rf "/tmp/wisp-shell"
    msg_ok "Wisp Shell installed."
else
    msg_ok "Wisp Shell is already installed."
fi

# 3. Backup and Sync configurations
msg "Syncing configurations to $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$BACKUP_DIR"

COMPONENTS=("hypr" "fish" "kitty" "fastfetch" "btop" "micro" "matugen")

for comp in "${COMPONENTS[@]}"; do
    if [ -d "$DOTS_DIR/$comp" ]; then
        if [ -d "$CONFIG_DIR/$comp" ]; then
            msg_warn "Backing up existing $comp to $BACKUP_DIR/$comp"
            cp -r "$CONFIG_DIR/$comp" "$BACKUP_DIR/$comp"
        fi
        
        msg "Syncing $comp..."
        rsync -a "$DOTS_DIR/$comp/" "$CONFIG_DIR/$comp/"
    fi
done
msg_ok "Configurations synced."

# 4. Spicetify / Vesktop Setup (Automated logic if requested)
msg "Checking optional integrations..."
if command -v spicetify >/dev/null 2>&1; then
    msg "Configuring Spicetify for Wisp/Matugen..."
    spicetify config current_theme Matugen color_scheme Matugen || true
    spicetify apply >/dev/null 2>&1 || true
    msg_ok "Spicetify configured."
fi

# 5. Bootstrapping dynamic themes via Matugen
msg "Bootstrapping Matugen colors..."
WP_PATH="$DOTS_DIR/../wisp-shell/assets/default_wallpaper.jpg"

if command -v matugen >/dev/null 2>&1; then
    if [ -f "$WP_PATH" ]; then
        matugen image "$WP_PATH" >/dev/null 2>&1 || true
        msg_ok "Matugen theme applied from default wallpaper."
    else
        msg_warn "Default wallpaper not found. Run 'matugen image <path>' later."
    fi
else
    msg_warn "Matugen not found! Please install it for dynamic colors."
fi

# 6. Post-install Hooks
msg "Running post-install hooks..."
if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null || true
    msg_ok "Hyprland reloaded."
fi

killall -USR2 btop 2>/dev/null || true

# Set fish as default shell if not already
if [[ "$SHELL" != *fish ]]; then
    msg_warn "Consider setting fish as your default shell: chsh -s \$(which fish)"
fi

echo ""
msg_ok "Installation Complete! A backup of your old configs is in $BACKUP_DIR."
echo -e "${GREEN}Welcome to Wisp.${NC}"
