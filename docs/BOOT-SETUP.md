# My boot setup (GRUB, Plymouth, SDDM, yay)

Notes on what was changed on this machine (Arch + Windows dual boot, 4K screen).
Set up on 2026-10-08.

## TODO

- [x] **LTS kernel installed** (2026-10-12) as a real safety net. If a kernel
      update breaks boot, pick it from GRUB's "Advanced options".
- [x] **Fallback initramfs enabled** for both kernels (2026-10-12), which also
      ends the "Skipping image 'fallback'" warning on kernel updates.
- [ ] **Make an Arch ISO USB** as a last resort (boot it, then `arch-chroot`
      to repair). Needs a spare stick; writing the image wipes it.

Both were done by [`boot/install-safety-net.sh`](../boot/install-safety-net.sh) (safe to re-run).
Two surprises it handles:

- `linux.preset` listed `fallback` but had its image lines commented out, while
  `linux-lts.preset` had the lines but left `fallback` off `PRESETS`.
- GRUB sorts kernels by version and put `linux-lts` first, which would have
  made LTS the default boot. `GRUB_TOP_LEVEL="/boot/vmlinuz-linux"` in
  `/etc/default/grub` keeps the normal kernel as the top entry.

Resulting menu: **Arch Linux** (normal kernel, default), **Advanced options**
(linux and linux-lts, each with a fallback entry), **Windows Boot Manager**.
All Arch entries show Vimix's Arch icon.

Why both: the fallback initramfs is the same kernel with every driver
included, which helps if hardware or drivers change. The LTS kernel is a
different kernel, which helps if a new kernel update is broken. That's the
more common problem on Arch. `linux-lts` uses the same mkinitcpio hooks, so it
gets the Plymouth splash too. The default boot entry stays the normal kernel.

## What was done

| Change | Where |
|---|---|
| Vimix theme installed (4K, color icons) | `/boot/grub/themes/vimix` |
| `GRUB_THEME` and `GRUB_GFXMODE=3840x2160,auto` set by the installer | `/etc/default/grub` |
| `splash` added to `GRUB_CMDLINE_LINUX_DEFAULT` | `/etc/default/grub` |
| `plymouth` hook added after `kms` | `/etc/mkinitcpio.conf` |
| `GRUB_DISABLE_BOOTNEXT=true` (removes the duplicate firmware entries: Windows x2, USB, CD/DVD, Network...) | `/etc/default/grub` |
| UEFI Firmware Settings entry hidden (`chmod -x`) | `/etc/grub.d/30_uefi-firmware` |
| "Advanced options" submenu given the Arch icon | `/etc/grub.d/10_linux` |

Resulting menu: **Arch Linux**, **Advanced options for Arch Linux**, **Windows Boot Manager**.
Windows is added by os-prober (`GRUB_DISABLE_OS_PROBER=false`).

## Plymouth (boot splash)

Theme: **arch-mac-style** (macOS-style Arch logo + progress bar), from
https://www.opendesktop.org/p/2106821 (by tobilinuxer, v1.1).
The theme has no licence, so it isn't in this repo: download the zip from that page and run
`boot/install-plymouth.sh path/to/arch-mac-style.zip`. sirius keeps its copy in `~/Developer/plymouth-arch-mac-style/`.

| Change | Where |
|---|---|
| Theme copied | `/usr/share/plymouth/themes/arch-mac-style` |
| `cantarell-fonts` installed (theme font) | pacman |
| `MODULES=(amdgpu)` for early GPU init (smoother splash) | `/etc/mkinitcpio.conf` |
| Theme set with `sudo plymouth-set-default-theme -R arch-mac-style` | |

- Switch back to the motherboard-logo theme: `sudo plymouth-set-default-theme -R bgrt`
- List installed themes: `plymouth-set-default-theme -l`
- The author notes this theme may add a few seconds to boot vs `bgrt`.
- If the logo looks too small on 4K, Plymouth scaling can be forced
  (`DeviceScale=2` under `[Daemon]` in `/etc/plymouth/plymouthd.conf`, then
  rebuild with `sudo mkinitcpio -P`).
- To update the theme: download the new zip, replace the folder in
  `/usr/share/plymouth/themes/`, rerun the `-R` command.

## yay (AUR helper)

Installed `yay-bin` 13.0.1 from the AUR (built in `~/Developer/yay-bin`).
After this, yay updates itself along with everything else.

- `yay` - update the whole system, AUR included
- `yay <name>` - search and install interactively
- `yay -S <pkg>` - install a package
- Always glance at the PKGBUILD of AUR packages before installing.

## SDDM login screen

Theme: **sddm-astronaut-theme** (AUR), style **lampcat** (since 2026-10-12; before that flatppuccin, then black_hole).

Upstream: https://github.com/Keyitdev/sddm-astronaut-theme

Before this, SDDM had no config, so it fell back to its plain built-in theme.

| Change | Where |
|---|---|
| Theme installed with `yay -S sddm-astronaut-theme` | `/usr/share/sddm/themes/sddm-astronaut-theme` |
| Config: theme + on-screen keyboard + 2x scale for 4K + cursor | `/etc/sddm.conf.d/astronaut.conf` (source copy: `~/Developer/arch-desktop-dot-files/sddm/astronaut.conf`) |
| Cursor `catppuccin-frappe-breeze-cursors` (system copy, since 2026-10-10), installed with `~/Developer/arch-desktop-dot-files/sddm/install-cursor.sh`. Re-run it after rebuilding the cursors | `/usr/share/icons/catppuccin-frappe-breeze-cursors` |

Install the config with:

```
sudo install -Dm644 ~/Developer/arch-desktop-dot-files/sddm/astronaut.conf /etc/sddm.conf.d/astronaut.conf
```

(`/etc/sddm.conf.d/` didn't exist. A plain `cp` would create a *file* with that name.)

- Preview without logging out:
  `sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/`
- Other styles: black_hole, cyberpunk, hyprland_kath, jake_the_dog,
  japanese_aesthetic, pixel_sakura, pixel_sakura_static,
  post-apocalyptic_hacker, purple_leaves. Switch with:
  `sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/<style>.conf|' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop`
  (A theme update resets this to astronaut. Re-run it with `black_hole`, or run
  `install-flatppuccin.sh` if you switched to Flatppuccin, after `yay` updates it.)
- Wrong size on the login screen: change `QT_SCREEN_SCALE_FACTORS=2` in the
  config, then re-install it with the command above.
- Back to the KDE look: delete `/etc/sddm.conf.d/astronaut.conf` and pick
  Breeze in System Settings → Colors & Themes → Login Screen (SDDM).

### Lamp + cat style (2026-10-12)

`~/Developer/arch-desktop-dot-files/sddm/lampcat.conf` is `flatppuccin.conf` with hyprwizrd's lamp + cat background
(`~/Pictures/Wallpapers/hyprwizrd-sddm-cat.png`, 1920×1080) and Catppuccin **Frappé** colors (Mocha until 2026-10-12), to
match the hyprlock lock screen. The login form is on the left, the lamp on the right.

Install (asks for the sudo password): `~/Developer/arch-desktop-dot-files/sddm/install-lampcat.sh`
Back to Flatppuccin: `~/Developer/arch-desktop-dot-files/sddm/install-flatppuccin.sh`
After a `yay` update of the theme, re-run `install-lampcat.sh`.

### Flatppuccin style (installed 2026-10-10)

Prepared on 2026-10-09 to match the desktop wallpaper. `~/Developer/arch-desktop-dot-files/sddm/flatppuccin.conf` is
`black_hole.conf` with the Flatppuccin Macchiato wallpaper and Catppuccin Macchiato colors (mauve
login button, pink hover). Same layout, font, clock and on-screen keyboard as the black hole.

Install it (in Konsole; it asks for the sudo password):
```
~/Developer/arch-desktop-dot-files/sddm/install-flatppuccin.sh
```
Preview without logging out:
```
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/
```
**Revert to the black hole:**
```
~/Developer/arch-desktop-dot-files/sddm/install-flatppuccin.sh black_hole
```
This only switches `ConfigFile=` in the theme's `metadata.desktop` back to `Themes/black_hole.conf`.
To also delete the two copied files:
```
sudo rm /usr/share/sddm/themes/sddm-astronaut-theme/Themes/flatppuccin.conf \
        /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/flatppuccin_4k_macchiato.png
```
How it works: SDDM runs as its own user and can't read `~`, so the script copies the wallpaper into
the theme's `Backgrounds/` and the style into `Themes/`. Neither file belongs to the package, so theme
updates keep them; only `metadata.desktop` gets reset (re-run the script after a theme update).

## After an SDDM or login theme update

If the login screen goes back to the astronaut style or the old cursor, check what was reset (no sudo):

```
~/Developer/arch-desktop-dot-files/sddm/check.sh
```

It prints `Login screen OK` or the exact fix for each problem. What can be reset, and the fix:

| What gets reset | When | Fix (in a terminal; asks for sudo) |
|---|---|---|
| Style goes back to astronaut: `ConfigFile=` in `metadata.desktop`, the only file here a package owns | `sddm-astronaut-theme` update (`yay`) | `~/Developer/arch-desktop-dot-files/sddm/install-flatppuccin.sh` |
| Theme or cursor changed: System Settings writes `/etc/sddm.conf.d/kde_settings.conf`, which overrides `astronaut.conf` | Picking a login theme or clicking "Apply Plasma Settings" in System Settings → Login Screen (SDDM) | Delete the `Current=` / `Cursor…=` lines from that file, or the whole file if it has nothing else |
| Login cursor is out of date | After rebuilding the cursors (`~/Developer/arch-desktop-dot-files/cursors/build-breeze-cursors.py`) | `~/Developer/arch-desktop-dot-files/sddm/install-cursor.sh` |

Updates to the `sddm` package keep everything: `/etc/sddm.conf.d/astronaut.conf`, the copied
style and wallpaper, and `/usr/share/icons/catppuccin-frappe-breeze-cursors` don't belong to
any package. (Checked with `pacman -Qo` on 2026-10-10.)

## After a GRUB package update

`pacman` overwrites the files in `/etc/grub.d/`, so two tweaks get undone
(the UEFI entry comes back, and the Advanced options icon disappears). Re-apply:

```
sudo chmod -x /etc/grub.d/30_uefi-firmware
sudo sed -i '/gnulinux-advanced-/s/\\\$menuentry_id_option/${CLASS} &/' /etc/grub.d/10_linux
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Run the `sed` only once per update: running it twice adds the class twice
(harmless, but messy).

Everything in `/etc/default/grub` and `/etc/mkinitcpio.conf` survives updates.

## Updating the theme

```
cd ~/Developer/grub2-themes
git pull
sudo ./install.sh -b -t vimix -s 4k
```

## Removing the theme

```
cd ~/Developer/grub2-themes
sudo ./install.sh -r -t vimix
```

## Notes

- Run `sudo` commands in a real terminal, not with `!` inside Claude Code: sudo
  can't prompt for a password there and fails with "access denied".
- Paste long commands one at a time; long lines can get split when pasting.
- Fallback initramfs: enabling it in `/etc/mkinitcpio.d/linux.preset` needs
  BOTH `'fallback'` in `PRESETS=(...)` AND the `fallback_image=` /
  `fallback_options=` lines uncommented. Otherwise mkinitcpio prints
  "No image or UKI specified. Skipping image 'fallback'". After changing it:
  `sudo mkinitcpio -P` then `sudo grub-mkconfig -o /boot/grub/grub.cfg`.
  With a fallback, "Advanced options" gets a real recovery entry.
