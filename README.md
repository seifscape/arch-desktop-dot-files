# arch-desktop-dot-files

The desktop side of **sirius**, an Arch box (Beelink SER9 MAX, 4K screen) that runs both
Hyprland and KDE Plasma: window manager, bar, menus, notifications, wallpapers, lock and login
screens, boot splash. Catppuccin Frappé with a mauve accent throughout.

The terminal setup (zsh, Ghostty, tmux, nvim, fastfetch) is separate and shared with the Mac and
a Raspberry Pi: [linux-dot-files](https://github.com/seifscape/linux-dot-files), via chezmoi. This
repo is everything that only makes sense on a desktop.

## What's here

| Folder | Goes to | What |
|---|---|---|
| `hypr/` | `~/.config/hypr` | Hyprland (Lua config): `hyprwizrd.lua` holds the look and extra keys, plus hyprlock, hypridle, hyprpaper and `scripts/wallpaper-picker.sh`. `aurora.lua` is the previous look |
| `waybar/` | `~/.config/waybar` | Top bar: workspaces, clock, now playing, tray, network, volume, power |
| `rofi/` | `~/.config/rofi` | Launcher, power menu, Bluetooth menu, wallpaper grid |
| `dunst/` | `~/.config/dunst` | Notifications |
| `cava/` | `~/.config/cava` | Audio visualizer (the terminal full of bars) |
| `cliamp/` | `~/.config/cliamp` | Terminal music player, Catppuccin theme |
| `kde/` | `~/.local/share` | The hide-app KWin script (Meta+H) and the wallpaper-picker launcher |
| `fonts/` | `~/.local/share/fonts` | Feather icon font for the power menu |
| `sddm/` | `/usr/share/sddm`, `/etc/sddm.conf.d` | Login screen styles for sddm-astronaut-theme, cursor config, install and check scripts |
| `boot/` | `/usr/share/plymouth` | Boot splash installer |
| `cursors/` | `~/.local/share/icons` | Builds Catppuccin-coloured Breeze cursors |
| `docs/` | | The full notes: [`DESKTOP-THEME.md`](docs/DESKTOP-THEME.md) and [`BOOT-SETUP.md`](docs/BOOT-SETUP.md) |

## Install

```sh
sudo pacman -S --needed stow hyprland hyprlock hypridle hyprpaper waybar rofi dunst \
    cava hyprshot hyprpicker pavucontrol playerctl ffmpeg librsvg
yay -S --needed cliamp sddm-astronaut-theme   # from the AUR
git clone https://github.com/seifscape/arch-desktop-dot-files ~/Developer/arch-desktop-dot-files
~/Developer/arch-desktop-dot-files/install.sh
```

`install.sh` links each folder into `$HOME` with [GNU stow](https://www.gnu.org/software/stow/),
so `~/.config/hypr` and the rest point into this repo. Edit them in place and the changes show up
in `git status`. Anything already in the way is moved to `~/.local/state/arch-desktop-dot-files/`
first. It then downloads the images that aren't committed and, from a Plasma session, sets the
shortcuts below. Re-running it is safe.

The rest needs sudo, so it's run by hand:

| | |
|---|---|
| Wallpaper collections | `./wallpapers.sh`: clones two Catppuccin wallpaper repos into `~/Pictures/Wallpapers`, renders the SVGs at 4K |
| Login screen | `sddm/install-lampcat.sh` (lamp + cat) or `sddm/install-flatppuccin.sh`, then `sddm/install-cursor.sh`. `sddm/check.sh` says what an update reset |
| Boot splash | `boot/install-plymouth.sh arch-mac-style.zip` (download it first, see Credits) |
| GRUB | Vimix from [vinceliuice/grub2-themes](https://github.com/vinceliuice/grub2-themes); steps in `docs/BOOT-SETUP.md` |

## Keys

| | Hyprland | Plasma |
|---|---|---|
| Wallpaper picker | Super+W | Meta+Shift+W (Meta+W is Overview) |
| Lock | Super+L | |
| Power menu | Super+Esc | |
| Visualizer · music player | Super+A · Super+Shift+A | |
| Screenshot region · screen | Super+Print · Super+Shift+Print | |
| Colour picker | Super+Shift+P | |
| Minimize (⌘M) | | Meta+M |
| Hide app (⌘H) | | Meta+H |
| Tiling editor | | Meta+Shift+T (Meta+T is Ghostty's new tab) |

The wallpaper picker sets Hyprland and Plasma at once, from either session.

## Credits

- Look ported from [hyprwizrd/hyprwizrd-dotfiles](https://github.com/hyprwizrd/hyprwizrd-dotfiles)
  to Hyprland's Lua config. Its repo has no licence, so its images (lock screen lamp, cat
  wallpapers) aren't committed here; `fetch-assets.sh` downloads them from it.
- rofi launcher and power menu by [adi1090x](https://github.com/adi1090x/rofi), Bluetooth menu
  by [nickclyde](https://github.com/nickclyde/rofi-bluetooth). Author headers kept in the files.
- Login screen theme: [Keyitdev/sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme).
- Boot splash: arch-mac-style by tobilinuxer, from
  [opendesktop.org/p/2106821](https://www.opendesktop.org/p/2106821). Not redistributed here.
- Wallpapers: [er2de2/catppuccin_walls](https://github.com/er2de2/catppuccin_walls) and
  [zhichaoh/catppuccin-wallpapers](https://github.com/zhichaoh/catppuccin-wallpapers).
- Colours: [Catppuccin](https://catppuccin.com).
