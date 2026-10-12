#!/bin/sh
# Check whether the Catppuccin login screen survived updates (no sudo needed).
# Prints what to re-run for anything that was reset.
T=/usr/share/sddm/themes/sddm-astronaut-theme
DIR="$(cd "$(dirname "$0")" && pwd)"
ok=1

# The chosen style is lamp + cat (since 2026-10-12). For Flatppuccin, use install-flatppuccin.sh
# and swap lampcat.conf / hyprwizrd-sddm-cat.png / install-lampcat.sh below for its files.
if ! grep -q '^ConfigFile=Themes/lampcat.conf' "$T/metadata.desktop" 2>/dev/null \
   || [ ! -f "$T/Themes/lampcat.conf" ] || [ ! -f "$T/Backgrounds/hyprwizrd-sddm-cat.png" ]; then
    echo "Login style was reset.     Fix: $DIR/install-lampcat.sh"; ok=0
elif ! cmp -s "$T/Themes/lampcat.conf" "$DIR/lampcat.conf"; then
    echo "Login style is out of date (lampcat.conf changed). Fix: $DIR/install-lampcat.sh"; ok=0
fi
if ! grep -q '^CursorTheme=catppuccin-frappe-breeze-cursors' /etc/sddm.conf.d/astronaut.conf 2>/dev/null \
   || ! grep -q '^CursorSize=48' /etc/sddm.conf.d/astronaut.conf 2>/dev/null \
   || [ ! -d /usr/share/icons/catppuccin-frappe-breeze-cursors ]; then
    echo "Login cursor was reset.    Fix: $DIR/install-cursor.sh"; ok=0
fi
# System Settings → Login Screen (SDDM) writes these; they override astronaut.conf.
for f in /etc/sddm.conf /etc/sddm.conf.d/kde_settings.conf; do
    if [ -f "$f" ] && grep -qE '^(Current|CursorTheme|CursorSize)=' "$f"; then
        echo "$f sets the theme or cursor and overrides astronaut.conf (System Settings writes it). Fix: delete those lines, or the file if it has nothing else"; ok=0
    fi
done
[ "$ok" = 1 ] && echo "Login screen OK: lamp + cat style + Catppuccin Frappé cursor."
