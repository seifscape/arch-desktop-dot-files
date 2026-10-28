#!/usr/bin/env bash
# Flip between the dwindle (tiling) and scrolling layouts (SUPER+SHIFT+L), Hyprland's built-in
# alternatives to plugins like hyprscrolling. Lasts until Hyprland reloads its config.
cur=$(hyprctl getoption general:layout | awk '/^str:/ {print $2}')
if [[ "$cur" == scrolling ]]; then next=dwindle; else next=scrolling; fi
hyprctl eval "hl.config({ general = { layout = \"$next\" } })" >/dev/null
notify-send -t 1500 "Layout" "$next"
