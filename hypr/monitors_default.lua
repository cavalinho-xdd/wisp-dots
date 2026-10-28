-- Default monitor rule: every output at its preferred mode, placed automatically.
-- Your real layout lives in monitors.lua, written by the nwg-displays GUI and
-- loaded after this file, so its per-output rules win.
-- monitors.lua is per machine and not tracked in git.
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
