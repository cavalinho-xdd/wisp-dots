-- Animations
-- Ref: Wisp Ember DESIGN.md
-- Enter springs with a small overshoot like the shell islands (BezierSpline 0.22, 1.18, 0.36, 1);
-- exits are short and plain.

-- Damping ratio ~0.68 (default "easy" spring is ~0.78): about 5% overshoot.
hl.curve("ember", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 21 })
hl.curve("easeOutQuint", { type = "bezier", points = { {0.22, 1}, {0.36, 1} } })
hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })

hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "ember" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "ember", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "easeOutQuint", style = "popin 92%" })

hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "easeOutQuint", style = "fade" })

hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.5, bezier = "linear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "linear" })
hl.animation({ leaf = "fadeGlow", enabled = true, speed = 3, bezier = "easeOutQuint" })

hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "easeOutQuint" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 4, spring = "ember", style = "slide" })
