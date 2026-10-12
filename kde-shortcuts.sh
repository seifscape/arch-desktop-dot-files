#!/bin/sh
# Plasma shortcuts that act like the Mac's, plus the wallpaper picker.
# Sets them through KDE's shortcut service (live, no logout); KDE saves them
# in ~/.config/kglobalshortcutsrc, which isn't in this repo because KDE
# rewrites it all the time. Change them later in System Settings -> Shortcuts.
set -eu

# Qt key codes: Meta 0x10000000, Shift 0x02000000, then the key.
META=268435456; SHIFT=33554432
key() { echo $(( META + $1 )); }

set_keys() {   # set_keys <component> <action> <component name> <action name> <codes...>
    id="[\"$1\",\"$2\",\"$3\",\"$4\"]"; shift 4
    codes=$(echo "$@" | tr ' ' ',')
    gdbus call --session -d org.kde.kglobalaccel -o /kglobalaccel \
        -m org.kde.KGlobalAccel.doRegister "$id" >/dev/null
    gdbus call --session -d org.kde.kglobalaccel -o /kglobalaccel \
        -m org.kde.KGlobalAccel.setForeignShortcut "$id" "[$codes]" >/dev/null
}

PGDOWN=$(key 16777239); M=$(key 77); W=$(key 87)

# Meta+M minimizes (like Cmd+M); Meta+PgDown is KDE's default and stays.
set_keys kwin "Window Minimize" KWin "Minimize Window" "$M" "$PGDOWN"
# Meta+T belongs to Ghostty's new tab (like Cmd+T), so the tiling editor moves to Meta+Shift+T.
set_keys kwin "Edit Tiles" KWin "Toggle Tiles Editor" $(( $(key 84) + SHIFT ))
# Meta+Shift+W opens the wallpaper picker; Meta+W stays Plasma's Overview.
set_keys wallpaper-picker.desktop _launch "Wallpaper Picker" "Wallpaper Picker" $(( W + SHIFT ))
kwriteconfig6 --file kglobalshortcutsrc --group services --group wallpaper-picker.desktop \
    --key _launch "Meta+Shift+W"

# Meta+H (hide app, like Cmd+H) comes from the hide-app KWin script; enable it.
kwriteconfig6 --file kwinrc --group Plugins --key hide-appEnabled true
qdbus6 org.kde.KWin /KWin reconfigure

echo "Set: Meta+M minimize, Meta+H hide app, Meta+Shift+T tiling editor, Meta+Shift+W wallpaper picker"
