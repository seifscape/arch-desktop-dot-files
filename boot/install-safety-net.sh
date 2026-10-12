#!/bin/sh
# A second way to boot when a kernel update goes wrong:
#  - linux-lts: an older, slower-moving kernel. It shows up in GRUB under
#    "Advanced options for Arch Linux"; the normal kernel stays the default.
#  - fallback initramfs for both kernels: built without autodetect, so it has
#    every driver, in case the normal image is missing one. Also silences the
#    "Skipping image 'fallback'" warning on every kernel update.
# Safe to re-run.
set -eu

sudo pacman -S --needed linux-lts

# Arch's linux.preset lists fallback but leaves its lines commented out;
# linux-lts.preset has the lines but leaves fallback off the list. Fix both.
for preset in /etc/mkinitcpio.d/linux.preset /etc/mkinitcpio.d/linux-lts.preset; do
    sudo sed -i -e "s/^PRESETS=.*/PRESETS=('default' 'fallback')/" \
                -e 's/^#fallback_image=/fallback_image=/' \
                -e 's/^#fallback_options=/fallback_options=/' "$preset"
done

# GRUB sorts kernels by version and puts linux-lts first, so the top entry
# (the one that boots by default) would be LTS. Pin the normal kernel there.
if ! grep -q '^GRUB_TOP_LEVEL=' /etc/default/grub; then
    printf '\n# Keep the normal kernel as the top (default) entry; linux-lts goes in Advanced options.\nGRUB_TOP_LEVEL="/boot/vmlinuz-linux"\n' \
        | sudo tee -a /etc/default/grub >/dev/null
fi

sudo mkinitcpio -P                                # rebuild every image, plymouth hook included
sudo grub-mkconfig -o /boot/grub/grub.cfg         # add the LTS entries to the menu

ls -lh /boot/vmlinuz-* /boot/initramfs-*
sudo grep -E "^\s*(menuentry|submenu) " /boot/grub/grub.cfg | cut -d"'" -f2
