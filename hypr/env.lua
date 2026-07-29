-- Environment variables for cursor, GTK, and Qt styling

-- hl.config({ env = {"K,V"} }) is the WRONG shape for Hyprland's Lua config
-- (that's the legacy hyprlang array style) -- it silently does nothing, no
-- error. The real Lua API is hl.env(key, value[, dbus]), one call per
-- variable. The optional third arg, when true, additionally makes Hyprland
-- run `systemctl --user import-environment` + `dbus-update-activation-
-- environment --systemd` for that var -- needed so D-Bus-activated services
-- and anything launched outside Hyprland's own exec tree (portals, app-menu
-- launches, qt6ct itself) see it too, not just Hyprland's direct children.
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
-- qtengine reads a real KDE .colors scheme (matugen-generated,
-- ~/.local/share/color-schemes/matugen.colors) so KColorScheme widgets
-- (Dolphin's file view etc), not just plain QWidgets, theme correctly.
-- qt6ct is still configured as a fallback (see matugen/config.toml) if
-- qtengine isn't installed.
-- Qt6 does not accept a ";"-separated fallback list (aborts on launch), so
-- this must stay a single value. The AUR qtengine package installs its Qt5
-- plugin build to /usr/lib/qt5/plugins, while Qt5 itself only searches
-- /usr/lib/qt/plugins by default (per `qmake-qt5 -query QT_INSTALL_PLUGINS`)
-- -- QT_PLUGIN_PATH adds the misplaced dir so Qt5 apps find it too.
hl.env("QT_QPA_PLATFORMTHEME", "qtengine", true)
hl.env("QT_PLUGIN_PATH", "/usr/lib/qt5/plugins", true)
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1", true)
hl.env("OZONE_PLATFORM", "wayland", true)

-- GPU-vendor-specific vars (e.g. NVIDIA's GBM_BACKEND/__GLX_VENDOR_LIBRARY_NAME
-- for portal screencasting) don't belong in the shared default -- add those
-- to hypr/local.lua instead, which is required (if present) at the end of
-- hyprland.lua and never committed to this repo.

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
end)
