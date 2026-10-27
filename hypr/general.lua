-- General Settings & Decoration
-- Ref: Wisp Ember DESIGN.md (no outlines, no drop shadows, the ember glows on what is active)

local chunk = loadfile(os.getenv("HOME") .. "/.config/hypr/colors.lua")
local mcolors = chunk and chunk()

-- The only wallpaper-derived colour; #8fd3ff is the shell's own fallback.
local ember = mcolors and mcolors.ember or "8fd3ff"

-- hyprland-lua currently has a bug parsing CGradientValueData strings.
-- We must pass a single CColor string or it throws "invalid color".
local active_str = "rgba(" .. ember .. "ff)"
local inactive_str = "rgba(20232aff)" -- ash-hi, only visible if a border is enabled in Settings

hl.config({
    input = {
        kb_layout = "cz",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true
        },
        sensitivity = 0
    },
    general = {
        gaps_in = 3,
        gaps_out = 11,
        border_size = 0,
        ['col.active_border'] = active_str,
        ['col.inactive_border'] = inactive_str,
        layout = "dwindle"
    },
    decoration = {
        rounding = 20, -- island radius
        rounding_power = 2, -- circular arcs, same as the shell's Qt corners

        active_opacity = 1.0,
        inactive_opacity = 0.8,

        blur = {
            enabled = true,
            size = 1,
            passes = 3,
            new_optimizations = true
        },

        shadow = {
            enabled = false
        },

        -- Ember glow on the active window only (shell: glowAlpha 0.22, glowBlur 22)
        glow = {
            enabled = true,
            range = 22,
            render_power = 3,
            color = "rgba(" .. ember .. "38)",
            color_inactive = "rgba(00000000)"
        }
    }
})
