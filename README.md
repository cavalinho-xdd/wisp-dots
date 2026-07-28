# Wisp Dotfiles (wisp-dots)

A cohesive, dynamically themed dotfiles collection for the Wisp Shell ecosystem.

This repository provides the underlying system configurations that power the Wisp desktop experience. It integrates seamlessly with Hyprland and utilizes a centralized color-generation pipeline to ensure that all your applications share a unified, professional aesthetic.

## Architecture & Theming

Wisp uses a declarative approach to configuration and theming:
- **Hyprland Configurations**: A modular, Lua-based configuration setup for Hyprland that handles animations, window rules, and keybindings natively.
- **Dynamic Theming (Matugen)**: The core of the Wisp visual experience. Instead of hardcoded colors, Wisp uses Matugen to extract color palettes from your wallpaper and dynamically generate configurations for your entire system.

Currently supported dynamic applications include:
- Kitty & Foot Terminals
- Starship Shell Prompt
- Btop Resource Monitor
- Fastfetch
- Micro Text Editor (via terminal inheritance)
- Spotify (via Spicetify)
- Discord (via Vesktop/Vencord)

## Installation

The repository includes a robust installation script designed to be safe and intuitive for both beginners and advanced users.

The installer will automatically:
1. Detect and install required system dependencies using your AUR helper.
2. Backup any of your existing configurations before making changes.
3. Synchronize the Wisp configurations to your system.
4. Clone and install the `wisp-shell` core components if they are not already present.
5. Generate your initial system colors and reload the desktop environment.

To install the entire Wisp ecosystem, run:

```bash
git clone https://github.com/cavalinho-xdd/wisp-dots.git
cd wisp-dots
chmod +x install.sh
./install.sh
```

## Post-Installation Usage

After installation, your entire system's theme is bound to your wallpaper. To change the look of your desktop and all supported applications simultaneously, use the Matugen CLI:

```bash
matugen image /path/to/your/wallpaper.jpg
```

This single command will regenerate all templates and instantly apply the new color scheme across your operating system.

## Repository Structure

For advanced users looking to customize the environment:
- `/hypr/`: Modular Hyprland configuration scripts.
- `/matugen/`: Contains the `config.toml` pipeline and the raw template files used to generate application themes.
- `/fish/` & `/kitty/`: Base shell and terminal configurations designed to inherit dynamic colors natively.
