-- General Settings & Decoration
-- Ref: Wisp DESIGN.md (flat UI, tonal layers, smooth borders)

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true
        },
        sensitivity = 0
    },
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 2,
        ["col.active_border"] = "rgba(cba6f7ff) rgba(89b4faff) 45deg", -- Primary accent
        ["col.inactive_border"] = "rgba(45475aaa)", -- Surface alt
        layout = "dwindle"
    },
    decoration = {
        rounding = 16, -- Follows Wisp scale (8, 12, 16, 24)
        
        blur = {
            enabled = true,
            size = 8,
            passes = 3,
            new_optimizations = true
        },

        -- Compositor shadow (permitted by DESIGN.md to give depth)
        drop_shadow = true,
        shadow_range = 16,
        shadow_render_power = 3,
        ["col.shadow"] = "rgba(00000055)"
    }
})
