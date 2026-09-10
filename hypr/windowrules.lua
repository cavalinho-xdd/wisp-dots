-- Window Rules

-- Wisp settings app should float and center
hl.window_rule({ match = { class = "^(org\\.quickshell)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.quickshell)$" }, size = "860 600" })
hl.window_rule({ match = { class = "^(org\\.quickshell)$" }, center = true })

-- Example rules for other typical popup apps
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })

-- Contextual Scratchpad Drawer
hl.window_rule({ match = { class = "^(wisp-scratchpad)$" }, float = true })
hl.window_rule({ match = { class = "^(wisp-scratchpad)$" }, size = "800 500" })
hl.window_rule({ match = { class = "^(wisp-scratchpad)$" }, move = "50% 80px" })
hl.window_rule({ match = { class = "^(wisp-scratchpad)$" }, workspace = "special:scratchpad" })
