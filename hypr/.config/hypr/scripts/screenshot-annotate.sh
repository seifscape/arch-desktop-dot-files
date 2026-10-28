#!/usr/bin/env bash
# Region screenshot straight into satty for arrows, text and blur (CTRL+SHIFT+Print). Saves next
# to the normal screenshots and copies the result to the clipboard on exit.
if ! command -v satty >/dev/null; then
    notify-send "Screenshot annotate" "satty isn't installed: sudo pacman -S satty"
    exit 1
fi
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
hyprshot -m region --raw --silent | satty --filename - --early-exit \
    --output-filename "$dir/annotated-$(date +%Y%m%d-%H%M%S).png" --copy-command wl-copy
