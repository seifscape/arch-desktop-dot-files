#!/bin/sh
# Switch the SDDM login screen (sddm-astronaut-theme) to the lamp + cat style (hyprwizrd).
# Back to Flatppuccin: ./install-flatppuccin.sh
set -eu

THEME=/usr/share/sddm/themes/sddm-astronaut-theme

# SDDM runs as its own user and can't read ~, so the theme needs its own copy.
sudo install -Dm644 "$HOME/Pictures/Wallpapers/hyprwizrd-sddm-cat.png" \
    "$THEME/Backgrounds/hyprwizrd-sddm-cat.png"
sudo install -Dm644 "$(dirname "$0")/lampcat.conf" "$THEME/Themes/lampcat.conf"

sudo sed -i "s|^ConfigFile=.*|ConfigFile=Themes/lampcat.conf|" "$THEME/metadata.desktop"
grep '^ConfigFile' "$THEME/metadata.desktop"
