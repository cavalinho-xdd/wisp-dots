-- General Settings & Decoration
-- Ref: Wisp DESIGN.md (flat UI, tonal layers, smooth borders)

local chunk = loadfile(os.getenv("HOME") .. "/.config/hypr/colors.lua")
local mcolors = chunk and chunk()

-- hyprland-lua currently has a bug parsing CGradientValueData strings.
-- We must pass a single CColor string or it throws "invalid color".
local active_str = mcolors and mcolors.active_border.colors[1] or "rgba(cba6f7ff)"
local inactive_str = mcolors and mcolors.inactive_border or "rgba(45475aaa)"

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
        gaps_in = 5,
        gaps_out = 11,
        border_size = 1,
        ['col.active_border'] = active_str,
        ['col.inactive_border'] = inactive_str,
        layout = "dwindle"
    },
    decoration = {
        rounding = 30, -- Follows Wisp scale (8, 12, 16, 24)
        
        active_opacity = 1.0,
        inactive_opacity = 0.8,

        blur = {
            enabled = true,
            size = 1,
            passes = 3,
            new_optimizations = true
        },

        -- Compositor shadow (permitted by DESIGN.md to give depth)
        shadow = {
            enabled = true,
            range = 16,
            render_power = 3,
            color = "rgba(00000055)"
        }
    }
})
