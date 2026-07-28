-- Animations
-- Ref: Wisp DESIGN.md 
-- Easing: OutCubic for enter, OutQuint for exit. 
-- Asymmetry: Enter ~300ms, Exit ~200ms

hl.curve("easeOutCubic", { type = "bezier", points = { {0.33, 1}, {0.68, 1} } })
hl.curve("easeOutQuint", { type = "bezier", points = { {0.22, 1}, {0.36, 1} } })
hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("easeOutBack", { type = "bezier", points = { {0.34, 1.15}, {0.64, 1} } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, curve = "easeOutCubic", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, curve = "easeOutQuint", style = "popin 92%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, curve = "easeOutCubic" })

hl.animation({ leaf = "layersIn", enabled = true, speed = 3, curve = "easeOutCubic", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, curve = "easeOutQuint", style = "fade" })

hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.5, curve = "linear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, curve = "linear" })

hl.animation({ leaf = "border", enabled = true, speed = 3, curve = "easeOutCubic" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, curve = "easeOutCubic", style = "slide" })
