#!/bin/sh
# Use the Catppuccin Frappé Breeze cursor on the SDDM login screen.
# Re-run after rebuilding the cursors (~/Developer/arch-desktop-dot-files/cursors/build-breeze-cursors.py).
set -eu

NAME=catppuccin-frappe-breeze-cursors
SRC="$HOME/.local/share/icons/$NAME"

# SDDM runs as its own user and can't read ~, so it needs a system copy.
sudo rm -rf "/usr/share/icons/$NAME"
sudo cp -r "$SRC" "/usr/share/icons/$NAME"
sudo chown -R root:root "/usr/share/icons/$NAME"
sudo install -Dm644 "$(dirname "$0")/astronaut.conf" /etc/sddm.conf.d/astronaut.conf
grep '^Cursor' /etc/sddm.conf.d/astronaut.conf
