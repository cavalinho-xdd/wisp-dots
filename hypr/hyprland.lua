-- Wisp Shell - Base Hyprland Configuration
-- This file is meant to be a clean, slop-free foundation.
-- Structured for wisp-shell compatibility.

require("monitors")
require("general")
require("animations")
require("windowrules")
require("keybinds")

-- --- Core Execution ---
-- Start the Wisp shell daemon
hl.exec_once("wisp start")
-- Start wallpaper daemon if present
hl.exec_once("swww-daemon || hyprpaper")
