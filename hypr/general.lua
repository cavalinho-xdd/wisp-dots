-- General Settings & Decoration
-- Ref: Wisp DESIGN.md (flat UI, tonal layers, smooth borders)

local chunk = loadfile(os.getenv("HOME") .. "/.config/hypr/colors.lua")
local mcolors = chunk and chunk()
local border_colors = mcolors or {
    active_border = {
        colors = { "rgba(cba6f7ff)", "rgba(89b4faff)" },
        angle = 45
    },
    inactive_border = "rgba(45475aaa)"
}

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
        gaps_out = 12,
        border_size = 1,
        col = border_colors,
        layout = "dwindle"
    },
    decoration = {
        rounding = 30, -- Follows Wisp scale (8, 12, 16, 24)
        
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
