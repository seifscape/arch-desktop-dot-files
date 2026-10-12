#!/bin/sh
# Install the arch-mac-style Plymouth boot splash from its downloaded zip.
# The theme (by tobilinuxer) isn't in this repo because it has no licence:
# download it from https://www.opendesktop.org/p/2106821 first.
#   ./install-plymouth.sh ~/Downloads/arch-mac-style.zip
# Back to the motherboard logo: sudo plymouth-set-default-theme -R bgrt
set -eu

ZIP=${1:?usage: $0 path/to/arch-mac-style.zip}
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
unzip -q "$ZIP" -d "$TMP"
SRC=$(dirname "$(find "$TMP" -name arch-mac-style.plymouth | head -1)")

sudo pacman -S --needed plymouth cantarell-fonts   # the theme's font
sudo rm -rf /usr/share/plymouth/themes/arch-mac-style
sudo cp -r "$SRC" /usr/share/plymouth/themes/arch-mac-style
# -R rebuilds the initramfs. Needs the plymouth hook in /etc/mkinitcpio.conf (see docs/BOOT-SETUP.md).
sudo plymouth-set-default-theme -R arch-mac-style
