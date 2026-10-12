#!/bin/sh
# Fetch the two Catppuccin wallpaper collections into ~/Pictures/Wallpapers,
# or update them if they're already there, then render the vector ones at 4K
# and rebuild the picker's thumbnails. Needs git, librsvg (rsvg-convert), ffmpeg.
set -eu

WALLS="$HOME/Pictures/Wallpapers"
mkdir -p "$WALLS"

repo() {   # repo <github owner/name> <folder>
    if [ -d "$WALLS/$2/.git" ]; then
        git -C "$WALLS/$2" pull --ff-only
    else
        git clone --depth 1 "https://github.com/$1" "$WALLS/$2"
    fi
}
repo er2de2/catppuccin_walls        catppuccin_walls
repo zhichaoh/catppuccin-wallpapers catppuccin-wallpapers

# Most of these are 1920x1080; the SVG versions render sharp on a 4K screen.
mkdir -p "$WALLS/catppuccin_walls_4k"
for svg in "$WALLS"/catppuccin_walls/svg_file/*.svg; do
    out="$WALLS/catppuccin_walls_4k/$(basename "${svg%.svg}").png"
    [ -s "$out" ] || rsvg-convert -w 3840 "$svg" -o "$out"
done

"$HOME/.config/hypr/scripts/wallpaper-picker.sh" --thumbs
