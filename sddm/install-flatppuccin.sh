#!/bin/sh
# Switch the SDDM login screen (sddm-astronaut-theme) to the Flatppuccin style.
# Back to the black hole: ./install-flatppuccin.sh black_hole
set -eu

THEME=/usr/share/sddm/themes/sddm-astronaut-theme
STYLE="${1:-flatppuccin}"

if [ "$STYLE" = flatppuccin ]; then
    # SDDM runs as its own user and can't read ~, so the theme needs its own copy.
    sudo install -Dm644 "$HOME/Pictures/Wallpapers/flatppuccin_4k_macchiato.png" \
        "$THEME/Backgrounds/flatppuccin_4k_macchiato.png"
    sudo install -Dm644 "$(dirname "$0")/flatppuccin.conf" "$THEME/Themes/flatppuccin.conf"
fi

sudo sed -i "s|^ConfigFile=.*|ConfigFile=Themes/$STYLE.conf|" "$THEME/metadata.desktop"
grep '^ConfigFile' "$THEME/metadata.desktop"
