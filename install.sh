#!/bin/sh
# Link this repo's configs into $HOME with GNU stow, fetch the images that
# aren't committed, and set the Plasma shortcuts. Safe to re-run.
# The login screen and boot splash need sudo, so they're separate: see README.
set -eu
cd "$(dirname "$0")"

PACKAGES="hypr waybar rofi dunst cava cliamp kde fonts"

command -v stow >/dev/null || { echo "Install stow first: sudo pacman -S --needed stow"; exit 1; }

# stow refuses to replace real files, so move what's in the way to a backup.
# Folders this repo owns outright move whole, so stow can link the folder itself
# (a program that rewrites a file then writes into the repo, not over a link).
# Shared folders like ~/.local/share/applications only lose the files we provide.
BACKUP="$HOME/.local/state/arch-desktop-dot-files/backup-$(date +%Y%m%d-%H%M%S)"
OWNED=".config/hypr .config/waybar .config/rofi .config/dunst .config/cava .config/cliamp
       .local/share/kwin/scripts/hide-app"
stash() {   # stash <path relative to $HOME>
    if [ -e "$HOME/$1" ] && [ ! -L "$HOME/$1" ]; then
        mkdir -p "$BACKUP/$(dirname "$1")"
        mv "$HOME/$1" "$BACKUP/$1"
    fi
}
for d in $OWNED; do stash "$d"; done
stash .local/share/applications/wallpaper-picker.desktop
stash .local/share/fonts/Icomoon-Feather.ttf
[ -d "$BACKUP" ] && echo "Moved existing files to $BACKUP"

stow --target="$HOME" --restow $PACKAGES
fc-cache -f >/dev/null

./fetch-assets.sh
if command -v kwriteconfig6 >/dev/null && gdbus introspect --session -d org.kde.kglobalaccel -o /kglobalaccel >/dev/null 2>&1; then
    kbuildsycoca6 >/dev/null 2>&1 || true
    ./kde-shortcuts.sh
else
    echo "Plasma isn't running: run ./kde-shortcuts.sh from a Plasma session."
fi
echo "Done. Wallpaper collections: ./wallpapers.sh"
