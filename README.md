# Wisp Dots

A cohesive, slop-free dotfiles collection for the Wisp Shell ecosystem.

## Structure
- **hypr/**: Base Hyprland configuration tailored for Wisp. Clean animations, proper window rules.
- **matugen/**: Dynamic color templates for fanning out the Wisp palette to your entire system.
  - `kitty`
  - `fastfetch`
  - `discord` (Vencord/Vesktop)
  - `spotify` (Spicetify)
  - `hyprland` colors
- **kitty/**: Base Kitty configuration.
- **fastfetch/**: Base fastfetch configuration.

## Application Theming
Wisp uses `matugen` to extract a color palette from your wallpaper and inject it into your apps.
The templates in `matugen/templates/` are compiled into their respective config paths based on `matugen/config.toml`.

To apply colors:
```bash
matugen image /path/to/wallpaper.jpg -c ~/.config/wisp-dots/matugen/config.toml
```

*(Note: This repository is part of the Wisp ecosystem: `wisp-shell`, `wisp-cli`, and `wisp-dots`)*
