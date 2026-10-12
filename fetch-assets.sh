#!/bin/sh
# Download the images this setup uses but doesn't redistribute: hyprwizrd's
# repo has no licence. Run after install.sh has linked ~/.config/hypr.
set -eu

B=https://raw.githubusercontent.com/hyprwizrd/hyprwizrd-dotfiles/main
MISC="$HOME/.config/hypr/misc"
WALLS="$HOME/Pictures/Wallpapers"
mkdir -p "$MISC" "$WALLS"

get() {   # get <path in hyprwizrd repo> <destination>; skips files already there
    [ -s "$2" ] || curl -fsSL "$B/$1" -o "$2"
    echo "ok  $2"
}

get .config/hypr/misc/light.png     "$MISC/light.png"        # lock screen (hyprlock)
get .config/hypr/misc/one_liner.png "$MISC/one_liner.png"    # Hyprland wallpaper
get .config/hypr/misc/cat-back.png  "$MISC/cat-back.png"
get .config/hypr/misc/one_liner.png "$WALLS/hyprwizrd-one-liner.png"   # for the picker and Plasma
get sddm_wallpaper/sddm-cat-back.png "$WALLS/hyprwizrd-sddm-cat.png"   # login screen (sddm/install-lampcat.sh)
