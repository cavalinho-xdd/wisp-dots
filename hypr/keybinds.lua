-- Keybinds
-- Must use single-line hl.bind(...) calls for Wisp-shell parser compatibility.

-- Core
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"), { description = "Launch terminal" })
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Close active window" })
hl.bind("SUPER + M", hl.dsp.exit(), { description = "Exit Hyprland" })
hl.bind("SUPER + E", hl.dsp.exec_cmd("dolphin"), { description = "Launch file manager" })
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating mode" })
hl.bind("SUPER + P", hl.dsp.layout("pseudo"), { description = "Dwindle: Pseudo tiling" })
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"), { description = "Dwindle: Toggle split" })

-- Wisp Shell Integrations
-- Absolute path: same PATH gap as hyprland.lua's "wisp start" -- exec_cmd's
-- spawn environment has no ~/.local/bin, so a bare "wisp" silently no-ops.
-- This static bind also wins over shell.qml's own runtime SUPER+Space
-- injection (first-bound-wins), so fixing this one is what actually matters.
hl.bind("SUPER + Space", hl.dsp.exec_cmd("$HOME/.local/bin/wisp launcher"), { description = "Wisp: App Launcher" })
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("$HOME/.local/bin/wisp screenshot"), { description = "Wisp: Screenshot area" })

-- Move focus
hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }), { description = "Focus left" })
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }), { description = "Focus right" })
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }), { description = "Focus up" })
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }), { description = "Focus down" })

-- Workspaces
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = 1 }), { description = "Go to workspace 1" })
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = 2 }), { description = "Go to workspace 2" })
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = 3 }), { description = "Go to workspace 3" })
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = 4 }), { description = "Go to workspace 4" })
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = 5 }), { description = "Go to workspace 5" })
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = 6 }), { description = "Go to workspace 6" })
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = 7 }), { description = "Go to workspace 7" })
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = 8 }), { description = "Go to workspace 8" })
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = 9 }), { description = "Go to workspace 9" })
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }), { description = "Go to workspace 10" })

-- Move to workspace
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }), { description = "Move to workspace 1" })
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }), { description = "Move to workspace 2" })
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }), { description = "Move to workspace 3" })
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }), { description = "Move to workspace 4" })
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }), { description = "Move to workspace 5" })
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }), { description = "Move to workspace 6" })
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }), { description = "Move to workspace 7" })
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }), { description = "Move to workspace 8" })
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }), { description = "Move to workspace 9" })
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }), { description = "Move to workspace 10" })

-- Mouse: hold SUPER + right-click to move a window, SUPER + left-click to
-- resize it. mouse:272 = left button, mouse:273 = right button (evdev codes,
-- unchanged by the lua config layer) -- verified live via hyprctl eval/binds
-- before writing this file.
hl.bind("SUPER + mouse:273", hl.dsp.window.drag(), { description = "Move window (drag)" })
hl.bind("SUPER + mouse:272", hl.dsp.window.resize(), { description = "Resize window (drag)" })

-- Send the focused window to the adjacent monitor, crossing monitor
-- boundaries (not just workspaces). monitor = "+1"/"-1" is relative to the
-- window's current monitor -- verified live (moved a test window DP-1<->DP-2
-- and back) before writing this file.
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ monitor = "-1" }), { description = "Move window to monitor on the left" })
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ monitor = "+1" }), { description = "Move window to monitor on the right" })

-- SUPER+CTRL+Left/Right steps to the adjacent workspace ID
-- (SUPER+SHIFT+CTRL+Left/Right does the same but drags the focused window
-- along). No builtin dispatcher does relative "next workspace", so this is
-- a small bound function instead of a dispatcher table -- hl.bind's
-- dispatcher param accepts a function (confirmed against
-- /usr/share/hypr/stubs/hl.meta.lua's
-- `bind fun(keys, dispatcher: HL.Dispatcher|function, opts)`), and
-- hl.get_active_monitor()/.active_workspace.id plus hl.dispatch(...) to
-- actually fire the resulting dispatcher were both verified live via
-- hyprctl eval before writing this file.
-- If you've set up a per-monitor workspace_rule with a fixed parity split
-- (see hypr/local.lua), change the `dir * 1` step below to `dir * 2` to
-- match it -- otherwise this will walk into the other monitor's range.
local function wisp_step_workspace(dir, move_window)
    return function()
        local mon = hl.get_active_monitor()
        if not mon or not mon.active_workspace then return end
        local target = mon.active_workspace.id + (dir * 1)
        if target < 1 then return end
        if move_window then
            hl.dispatch(hl.dsp.window.move({ workspace = target }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = target }))
        end
    end
end
hl.bind("SUPER + CTRL + left", wisp_step_workspace(-1, false), { description = "Previous workspace on this monitor" })
hl.bind("SUPER + CTRL + right", wisp_step_workspace(1, false), { description = "Next workspace on this monitor" })
hl.bind("SUPER + SHIFT + CTRL + left", wisp_step_workspace(-1, true), { description = "Move window to previous workspace on this monitor" })
hl.bind("SUPER + SHIFT + CTRL + right", wisp_step_workspace(1, true), { description = "Move window to next workspace on this monitor" })

-- Media & Brightness (hardware keys)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { description = "Volume Up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { description = "Volume Down" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { description = "Toggle Mute" })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 5%+"), { description = "Brightness Up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { description = "Brightness Down" })

-- Touchpad Gestures
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "up", action = "fullscreen" })
hl.gesture({ fingers = 4, direction = "down", action = "close" })
hl.gesture({ fingers = 3, direction = "up", action = "special", workspace_name = "" })
hl.gesture({ fingers = 3, direction = "down", action = "special", workspace_name = "" })
