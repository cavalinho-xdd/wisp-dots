-- General Settings & Decoration
-- Ref: Wisp DESIGN.md (flat UI, tonal layers, smooth borders)

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
        gaps_in = 6,
        gaps_out = 10,
        border_size = 0,
        col = {
            active_border = {
                colors = { "rgba(cba6f7ff)", "rgba(89b4faff)" },
                angle = 45
            },
            inactive_border = "rgba(45475aaa)"
        },
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
