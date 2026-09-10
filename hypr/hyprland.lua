-- Wisp Shell - Base Hyprland Configuration
-- This file is meant to be a clean, slop-free foundation.
-- Structured for wisp-shell compatibility.

require("env")
require("monitors")
require("general")
require("animations")
require("windowrules")
require("keybinds")
-- wisp Settings > Keybinds > Add keybind writes here, and hypr/local.lua
-- holds per-machine overrides (GPU-vendor env vars, extra monitors,
-- personal autostart apps). Neither is shipped by this repo (gitignored) --
-- manifest.toml's hypr post_install hook recreates keybinds_custom.lua with
-- just its header comment; local.lua stays empty until you add to it.
-- pcall both so a fresh install (before that hook has ever run, or before
-- you've written a local.lua) doesn't error.
pcall(require, "windowrules_custom")
pcall(require, "keybinds_custom")
pcall(require, "local")

-- --- Core Execution ---
-- Start the Wisp shell daemon
hl.on("hyprland.start", function()
    -- Absolute path: exec_cmd's spawn environment does not carry
    -- ~/.local/bin on PATH, so a bare "wisp" silently fails to launch here
    -- even though it resolves fine from an interactive shell.
    hl.exec_cmd("$HOME/.local/bin/wisp start")
    -- Start wallpaper daemon if present. awww is the actively-maintained
    -- swww fork installed on this system — prefer it, fall back to swww
    -- proper or hyprpaper if either is what's actually installed.
    hl.exec_cmd("awww-daemon || swww-daemon || hyprpaper")
    -- awww doesn't auto-restore on launch like hyprpaper's config file does;
    -- it caches the last-set image and needs an explicit restore call once
    -- the daemon is up.
    hl.exec_cmd("sleep 1 && awww restore")
    -- Contextual Scratchpad
    hl.exec_cmd("[workspace special:scratchpad silent] kitty --class wisp-scratchpad micro ~/scratchpad.txt")
end)
