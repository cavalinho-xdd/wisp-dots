-- Environment variables for cursor, GTK, and Qt styling

hl.config({
    env = {
        "XCURSOR_THEME,Bibata-Modern-Classic",
        "XCURSOR_SIZE,24",
        "QT_QPA_PLATFORMTHEME,qt6ct",
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1",
        "OZONE_PLATFORM,wayland"
    }
})

hl.exec_once("hyprctl setcursor Bibata-Modern-Classic 24")
