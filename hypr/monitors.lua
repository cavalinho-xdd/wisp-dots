-- Monitors configuration
-- Kept generic on purpose -- this ships to machines with any number of
-- monitors under any output names. Per-monitor workspace assignment
-- (hl.workspace_rule with real output names like DP-1/DP-2) is
-- machine-specific: put it in hypr/local.lua instead of here.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1
})
