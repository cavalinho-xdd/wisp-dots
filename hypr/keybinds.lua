-- Keybinds
-- Must use single-line hl.bind(...) calls for Wisp-shell parser compatibility.

-- Core
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"), { description = "Launch terminal" })
hl.bind("SUPER + Q", hl.dsp.killactive(), { description = "Close active window" })
hl.bind("SUPER + M", hl.dsp.exit(), { description = "Exit Hyprland" })
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar"), { description = "Launch file manager" })
hl.bind("SUPER + V", hl.dsp.togglefloating(), { description = "Toggle floating mode" })
hl.bind("SUPER + P", hl.dsp.pseudo(), { description = "Dwindle: Pseudo tiling" })
hl.bind("SUPER + J", hl.dsp.togglesplit(), { description = "Dwindle: Toggle split" })

-- Wisp Shell Integrations
hl.bind("SUPER + Space", hl.dsp.exec_cmd("wisp launcher"), { description = "Wisp: App Launcher" })

-- Move focus
hl.bind("SUPER + left", hl.dsp.movefocus("l"), { description = "Focus left" })
hl.bind("SUPER + right", hl.dsp.movefocus("r"), { description = "Focus right" })
hl.bind("SUPER + up", hl.dsp.movefocus("u"), { description = "Focus up" })
hl.bind("SUPER + down", hl.dsp.movefocus("d"), { description = "Focus down" })

-- Workspaces
hl.bind("SUPER + 1", hl.dsp.workspace("1"), { description = "Go to workspace 1" })
hl.bind("SUPER + 2", hl.dsp.workspace("2"), { description = "Go to workspace 2" })
hl.bind("SUPER + 3", hl.dsp.workspace("3"), { description = "Go to workspace 3" })
hl.bind("SUPER + 4", hl.dsp.workspace("4"), { description = "Go to workspace 4" })
hl.bind("SUPER + 5", hl.dsp.workspace("5"), { description = "Go to workspace 5" })
hl.bind("SUPER + 6", hl.dsp.workspace("6"), { description = "Go to workspace 6" })
hl.bind("SUPER + 7", hl.dsp.workspace("7"), { description = "Go to workspace 7" })
hl.bind("SUPER + 8", hl.dsp.workspace("8"), { description = "Go to workspace 8" })
hl.bind("SUPER + 9", hl.dsp.workspace("9"), { description = "Go to workspace 9" })
hl.bind("SUPER + 0", hl.dsp.workspace("10"), { description = "Go to workspace 10" })

-- Move to workspace
hl.bind("SUPER + SHIFT + 1", hl.dsp.movetoworkspace("1"), { description = "Move to workspace 1" })
hl.bind("SUPER + SHIFT + 2", hl.dsp.movetoworkspace("2"), { description = "Move to workspace 2" })
hl.bind("SUPER + SHIFT + 3", hl.dsp.movetoworkspace("3"), { description = "Move to workspace 3" })
hl.bind("SUPER + SHIFT + 4", hl.dsp.movetoworkspace("4"), { description = "Move to workspace 4" })
hl.bind("SUPER + SHIFT + 5", hl.dsp.movetoworkspace("5"), { description = "Move to workspace 5" })
hl.bind("SUPER + SHIFT + 6", hl.dsp.movetoworkspace("6"), { description = "Move to workspace 6" })
hl.bind("SUPER + SHIFT + 7", hl.dsp.movetoworkspace("7"), { description = "Move to workspace 7" })
hl.bind("SUPER + SHIFT + 8", hl.dsp.movetoworkspace("8"), { description = "Move to workspace 8" })
hl.bind("SUPER + SHIFT + 9", hl.dsp.movetoworkspace("9"), { description = "Move to workspace 9" })
hl.bind("SUPER + SHIFT + 0", hl.dsp.movetoworkspace("10"), { description = "Move to workspace 10" })

-- Media & Brightness (hardware keys)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { description = "Volume Up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { description = "Volume Down" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { description = "Toggle Mute" })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 5%+"), { description = "Brightness Up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { description = "Brightness Down" })
