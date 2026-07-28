-- Window Rules

-- Wisp settings app should float and center
hl.window_rule({ match = { class = "^(org\\.quickshell)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.quickshell)$" }, size = "860 600" })
hl.window_rule({ match = { class = "^(org\\.quickshell)$" }, center = true })

-- Example rules for other typical popup apps
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })
