<div align="center">
  <h1>Wisp Dotfiles</h1>
  <p>A cohesive, dynamically themed dotfiles collection for the Wisp Shell ecosystem.</p>
  <a href="#installation">Installation</a> •
  <a href="#dynamic-theming">Theming</a> •
  <a href="#repository-structure">Structure</a>
</div>

<br>

This repository provides the underlying system configurations that power the Wisp desktop experience. It integrates seamlessly with Hyprland and utilizes a centralized color-generation pipeline to ensure that all your applications share a unified, professional aesthetic.

## Table of Contents
- [Supported Environments](#supported-environments)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Automated Setup](#automated-setup)
- [Dynamic Theming](#dynamic-theming)
- [Repository Structure](#repository-structure)
- [License](#license)

## Supported Environments
Wisp Dotfiles natively configures and themes the following tools:
- **Desktop Environment**: Hyprland
- **Terminals**: Kitty, Foot
- **Shell & Prompts**: Fish, Starship
- **System Monitors**: Btop, Fastfetch
- **Text Editors**: Micro (via terminal inheritance)
- **Third-Party Apps**: Spotify (via Spicetify), Discord (via Vesktop/Vencord)

## Installation

### Prerequisites
Before installing, ensure your system is running a modern Arch-based distribution. The installation script relies on an AUR helper (`paru` or `yay`) to fetch required dependencies.

### Automated Setup
The repository includes a robust installation script designed to be safe and comprehensive. The installer will automatically:
1. Detect and install required system dependencies using your AUR helper.
2. Backup any of your existing configurations to `~/.config.bak/`.
3. Synchronize the Wisp configurations to your `~/.config` directory.
4. Clone and install the `wisp-shell` core components if they are not already present.
5. Generate your initial system colors and reload the desktop environment.

To install the entire Wisp ecosystem, run:
```bash
git clone https://github.com/cavalinho-xdd/wisp-dots.git ~/.config/wisp-dots
cd ~/.config/wisp-dots
chmod +x install.sh
./install.sh
```

## Dynamic Theming
Wisp abandons hardcoded colors. Instead, it uses **Matugen** to extract a color palette directly from your wallpaper and dynamically generate configurations for your entire system.

To change the look of your desktop and all supported applications simultaneously, execute:
```bash
matugen image /path/to/your/wallpaper.jpg
```
This single command will regenerate all templates and instantly apply the new color scheme across your operating system.

## Repository Structure
For advanced users looking to customize the environment:
- `hypr/`: Modular Hyprland configuration scripts natively written in Lua.
- `matugen/`: Contains the `config.toml` pipeline and the raw template files used to generate application themes.
- `fish/` & `kitty/`: Base shell and terminal configurations designed to inherit dynamic colors natively.

## License
This project is licensed under the MIT License.
