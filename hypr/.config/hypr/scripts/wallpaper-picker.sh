#!/usr/bin/env bash
# Pick a wallpaper from a rofi thumbnail grid (SUPER+W in Hyprland; also works in Plasma).
# One pick sets both desktops, from either session:
#   Hyprland: hyprpaper.conf always; live via hyprctl when Hyprland is running
#   Plasma:   live via plasma-apply-wallpaperimage when plasmashell is running,
#             otherwise written into Plasma's config for the next Plasma login
#   --thumbs   only (re)build the thumbnail cache, e.g. after a `git pull` of the wallpaper repos
set -euo pipefail

WALLS="$HOME/Pictures/Wallpapers"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-picker"
CONF="$HOME/.config/hypr/hyprpaper.conf"
PLASMA_RC="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
THEME="$HOME/.config/rofi/wallpaper.rasi"

mkdir -p "$CACHE"

# All images under ~/Pictures/Wallpapers (both Catppuccin repos, the 4K renders, older picks)
mapfile -t files < <(find -L "$WALLS" -path '*/.git' -prune -o -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print | sort)

thumb_for() { printf '%s/%s.jpg' "$CACHE" "$(printf '%s' "$1" | md5sum | cut -c1-16)"; }

make_thumbs() {
    local f t
    for f in "${files[@]}"; do
        t=$(thumb_for "$f")
        [[ -s "$t" && "$t" -nt "$f" ]] && continue
        ffmpeg -loglevel error -y -i "$f" -frames:v 1 -vf "scale=384:216:force_original_aspect_ratio=increase,crop=384:216" -q:v 5 "$t" </dev/null || true
    done
}

if [[ "${1:-}" == --thumbs ]]; then
    make_thumbs
    exit 0
fi
make_thumbs

declare -A path_of
for f in "${files[@]}"; do
    name=${f#"$WALLS/"}
    path_of[${name%.*}]=$f
done

# rofi entries are "name\0icon\x1fthumbnail"; bash strings can't hold \0, so print them directly
menu() {
    local f name
    for f in "${files[@]}"; do
        name=${f#"$WALLS/"}
        printf '%s\0icon\x1f%s\n' "${name%.*}" "$(thumb_for "$f")"
    done
}

choice=$(menu | rofi -dmenu -i -show-icons -p "Wallpaper" -theme "$THEME") || exit 0
wall=${path_of[$choice]:-}
[[ -n "$wall" ]] || exit 0

# Hyprland
sed -i --follow-symlinks "s|^\(\s*path = \).*|\1$wall|" "$CONF"
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    hyprctl hyprpaper wallpaper ",$wall,cover" >/dev/null
fi

# Plasma
if pgrep -x plasmashell >/dev/null; then
    plasma-apply-wallpaperimage "$wall" >/dev/null
elif [[ -f "$PLASMA_RC" ]]; then
    # Every desktop containment that uses the image wallpaper plugin
    grep -oP '^\[Containments\]\[\K[0-9]+(?=\]\[Wallpaper\]\[org\.kde\.image\]\[General\]$)' "$PLASMA_RC" |
    while read -r id; do
        kwriteconfig6 --file "$PLASMA_RC" --group Containments --group "$id" --group Wallpaper \
            --group org.kde.image --group General --key Image "file://$wall"
    done
fi
notify-send -a Wallpaper -i "$(thumb_for "$wall")" "Wallpaper" "$choice"
