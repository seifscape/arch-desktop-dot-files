# My desktop theme: Catppuccin Frappé (Plasma: aurora · Hyprland: hyprwizrd)

The look from [flickowoa/dotfiles (aurora)](https://github.com/flickowoa/dotfiles/tree/aurora),
rebuilt for current Hyprland (Lua config) and applied to Plasma as well.
Set up on 2026-10-08. Boot/login setup is in `BOOT-SETUP.md`.

These configs live in [arch-desktop-dot-files](https://github.com/seifscape/arch-desktop-dot-files)
(`~/Developer/arch-desktop-dot-files`) and are symlinked into place by its `install.sh`, so edits
in `~/.config` land in the repo. The terminal setup is separate: `linux-dot-files`, via chezmoi.

Palette: Catppuccin **Frappé** (switched from Mocha on 2026-10-12: easier on the eyes), accent **Mauve**. Signature gradient: mauve → blue → teal
(`#cba6f7` → `#89b4fa` → `#94e2d5`).

The configs from before the first change (2026-10-08) weren't kept.

## TODO

- [x] Icons: Papirus-Dark set in Plasma (`/usr/lib/plasma-changeicons Papirus-Dark`).
- [x] Mauve folder color: `sudo papirus-folders -C cat-frappe-mauve --theme Papirus-Dark`
- Not needed: `brightnessctl` (laptop backlights only; this is an external DisplayPort monitor).
  External monitor brightness uses DDC/CI: Plasma's tray slider, or `ddcutil` in Hyprland.
- [x] Hyprland autostart: `firefox` → `chromium`.

## Wallpaper

Current (since 2026-10-12): hyprwizrd's one-line cat, `~/Pictures/Wallpapers/hyprwizrd-one-liner.png`
(1920×1080, also at `~/.config/hypr/misc/one_liner.png`). Used by the Plasma desktop and hyprpaper.
The lock screen (hyprlock) and the SDDM login screen use the lamp + cat image.

Previous: `~/Pictures/Wallpapers/flatppuccin_4k_macchiato.png` (3840×2160), and before that
`aurora.jpg`. To go back: `plasma-apply-wallpaperimage <path>` and change the path in `hyprpaper.conf`.

**Collections** (in `~/Pictures/Wallpapers/`, update with `git pull` in each, then
`~/.config/hypr/scripts/wallpaper-picker.sh --thumbs`):
- `catppuccin_walls/`: [er2de2/catppuccin_walls](https://github.com/er2de2/catppuccin_walls), ~216, mostly 1920×1080
- `catppuccin-wallpapers/`: [zhichaoh/catppuccin-wallpapers](https://github.com/zhichaoh/catppuccin-wallpapers), ~240 (os, landscapes, waves, mandelbrot, minimalistic, ...)
- `catppuccin_walls_4k/`: the 16:9 SVGs from er2de2 rendered at 3840×2160 (`rsvg-convert -w 3840`)

**Picker**: `SUPER+W` in Hyprland (or run `~/.config/hypr/scripts/wallpaper-picker.sh` in Plasma) opens a
rofi thumbnail grid of everything under `~/Pictures/Wallpapers/`. One pick sets **both desktops** from
either session: it always saves `hyprpaper.conf` (and applies live in Hyprland), and it sets Plasma live with
`plasma-apply-wallpaperimage` or, when Plasma isn't running, writes `Image=` in
`~/.config/plasma-org.kde.plasma.desktop-appletsrc` for the next Plasma login. Lock and login screens stay the lamp.
Theme: `~/.config/rofi/wallpaper.rasi`. Thumbnails: `~/.cache/wallpaper-picker/`.

The SDDM login screen uses the lamp + cat style (since 2026-10-12). Details and revert
steps: `BOOT-SETUP.md` → SDDM login screen.

## Hyprland (hyprwizrd look, since 2026-10-12)

The Hyprland session now uses the look from
[hyprwizrd/hyprwizrd-dotfiles](https://github.com/hyprwizrd/hyprwizrd-dotfiles), ported to the Lua
config. Plasma, the SDDM screen and the Flatppuccin wallpaper there are unchanged. The aurora-era
waybar, hyprlock and hyprpaper configs weren't kept; `aurora.lua` is.

| File | What |
|---|---|
| `~/.config/hypr/hyprwizrd.lua` | **All the hyprwizrd styling**: blue → mauve borders, rounding 4, small gaps, light shadows/blur, floating btop/nmtui/pavucontrol, extra keys |
| `~/.config/hypr/hyprland.lua` | Loads `hyprwizrd.lua` at the bottom. Launcher → rofi, notifications → dunst, starts hypridle. Terminal ghostty, Catppuccin cursor, Qt apps use Plasma colors |
| `~/.config/hypr/hyprpaper.conf` | Wallpaper: one-line cat (`misc/one_liner.png`, 1920×1080) |
| `~/.config/hypr/hyprlock.conf` | Lock screen: hanging lamp over a cat (`misc/light.png`), password box in the light |
| `~/.config/hypr/hypridle.conf` | Lock after 3 min, screen off after 7. No auto-suspend (box is reached over SSH) |
| `~/.config/waybar/` | hyprwizrd top bar: Arch logo (opens launcher), workspaces, clock, tray/bluetooth/memory/network/volume/power. Battery removed; network opens nmtui |
| `~/.config/rofi/` | Launcher (`launchers/type-1`), power menu (`powermenu/type-2`, needs the `feather` font in `~/.local/share/fonts`), Bluetooth menu |
| `~/.config/dunst/dunstrc` | Notifications (mauve frame) |
| `~/.config/cava/` | Music visualizer, Catppuccin gradient teal → blue → mauve → pink (`SUPER+A`, floating). `shaders/` incl. Winamp-style spectrum, used only with cava's SDL output |
| `~/.config/cliamp/` | Music player (`SUPER+SHIFT+A`, floating). `config.toml`: theme catppuccin, ClassicPeak visualizer, file browser in `~/Music`. `themes/catppuccin.toml` overrides the built-in theme with exact Frappé colours. Media keys work over MPRIS; the bar shows the track (mpris module, any player) |
| `~/.config/fastfetch/` | Not in this repo: managed by chezmoi from [linux-dot-files](https://github.com/seifscape/linux-dot-files). `config.jsonc` is the Mac's boxed layout, `logo.txt` the per-machine Catppuccin Arch logo |

- **Back to aurora** (partly possible): in `hyprland.lua` change `require("hyprwizrd")` to `require("aurora")`,
  `dunst` → `mako` and the menu back to `wofi --show drun`. `aurora.lua` is in this repo, and the old `mako` and
  `wofi` configs are still in `~/.config` (not tracked here). The old waybar, hyprlock and hyprpaper configs are gone;
  get them from [flickowoa/dotfiles, aurora branch](https://github.com/flickowoa/dotfiles/tree/aurora).
- **Check the config after editing** (prints `config ok` or the exact errors):
  `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`
- Keys: `SUPER+Q` terminal, `SUPER+R` launcher, `SUPER+E` files, `SUPER+C` close,
  `SUPER+L` lock, `SUPER+Escape` power menu, `SUPER+Print` / `SUPER+SHIFT+Print` screenshot region / screen,
  `SUPER+SHIFT+P` colour picker, `SUPER+A` music visualizer (cava), `SUPER+SHIFT+A` music player (cliamp), `SUPER+W` wallpaper picker, `SUPER+M` exit.

## Terminal (Ghostty + shell)

Managed by chezmoi from [seifscape/linux-dot-files](https://github.com/seifscape/linux-dot-files)
(applied 2026-10-09). Shared files (Ghostty `config`, aliases, tmux, Starship, nvim, ...) are pulled
from [macos-dot-files](https://github.com/seifscape/macos-dot-files), so the terminal matches the Mac.

- Ghostty uses the Mac config (`~/.config/ghostty/config`, theme **Catppuccin Frappe**).
  The Arch `config.ghostty` from the first theming pass was removed by chezmoi.
- Edit shared files on the Mac and push, then run `chezmoi update` here.
- Edit Linux-only files in `~/Developer/linux-dot-files` and push, then run `chezmoi update`.
- **App icon:** `macos-icon`/`macos-custom-icon` in the shared config only work on macOS. On Linux
  the Catppuccin icon is set with a user override of the launcher entry:
  `~/.local/share/applications/com.mitchellh.ghostty.desktop` (copy of the system file with
  `Icon=~/.local/share/icons/ghostty-catppuccin-macchiato-large.png`: the 1024px PNG from
  `catppuccin-macchiato.icns` in macos-dot-files, with the macOS padding cropped off and scaled to 512px). If a Ghostty update changes the system
  `.desktop` file, re-copy it and set `Icon=` again.
- Git identity and the gh push helper live in `~/.gitconfig.local`. chezmoi owns `~/.gitconfig`
  and would drop anything added there.
- `dev-updates.sh` prints "Newer versions are available" on shell start when mise pins are behind.
  Run `mise upgrade --bump` to update them (decide on the Mac, since it shares the pins).

## Plasma

Installed with the official [catppuccin/kde](https://github.com/catppuccin/kde) installer
(clone in `~/Developer/catppuccin-kde`), user-level only (`~/.local/share`), no sudo:

- Global theme `Catppuccin-Frappe-Mauve`, color scheme, splash screen. Its "Modern" window
  decorations are installed but not used (macOS-style buttons); see **Window decorations** below.
- Cursors (since 2026-10-10): `catppuccin-frappe-breeze-cursors` in `~/.local/share/icons`, used by
  Plasma, Hyprland (`hyprland.lua`) and GTK (gsettings), at size 24 everywhere (the build also includes a 28 size). These are the stock Breeze shapes recolored
  with Frappé colors (Base body, Text outline, Mauve accents), built by
  `python3 -I ~/Developer/arch-desktop-dot-files/cursors/build-breeze-cursors.py frappe` (`mocha` still builds the old set). Rerun it after a Breeze update, then
  `plasma-apply-cursortheme catppuccin-frappe-breeze-cursors`. The global theme was installed with these cursors
  (`-c`), so re-applying it keeps them. The Mocha sets are still installed.
- Wallpaper (since 2026-10-09): `~/Pictures/Wallpapers/flatppuccin_4k_macchiato.png`, set with
  `plasma-apply-wallpaperimage ~/Pictures/Wallpapers/flatppuccin_4k_macchiato.png`.
  Also used by hyprpaper and hyprlock. The previous one, `aurora.jpg`, is kept in the same folder.
  (changing wallpaper or re-applying a global theme can reset it; just rerun that)
- Lock screen (since 2026-10-09): Flatppuccin wallpaper, set in `~/.config/kscreenlockerrc`
  (`[Greeter][Wallpaper][org.kde.image][General]` `Image=`). Earlier the aurora wallpaper was
  tried there and reverted. To go back to Plasma's default, delete `~/.config/kscreenlockerrc`,
  or change it in System Settings → Security & Privacy → Screen Locking → Appearance.

Re-install / update:
```
cd ~/Developer/catppuccin-kde && git pull
./install.sh -q -c ~/.local/share/icons/catppuccin-frappe-breeze-cursors 3 4 1
```
(`3 4 1` = Frappé, Mauve, Modern. `-c` uses our own Breeze cursors, so the global theme carries them
and the installer doesn't need `unzip`.)

Back to stock: System Settings → Colors & Themes → Global Theme → Breeze.

### Window decorations: Klassy (set up 2026-10-09)

Replaced Catppuccin's Aurorae decorations: "Modern" has macOS-like buttons and "Classic" is full
traffic lights. Now using [Klassy](https://github.com/paulmcauley/klassy) (AUR `klassy`) with the
[catppuccin-klassy](https://github.com/helenclx/catppuccin-klassy) Frappé button colors.

- Config: `~/.config/klassy/klassyrc`. Deliberately not in chezmoi: it's desktop-only, and the
  Klassy settings window rewrites it. It contains:
  - `[Windeco]` `ButtonIconStyle=StyleFluent`, `DrawTitleBarSeparator=false`
  - `[ButtonColors]` the contents of `themes/catppuccin-frappe.txt` from catppuccin-klassy,
    plus `LockButtonColorsActiveInactive=false` (keeps the theme's faded inactive colors)
- KWin: `kwinrc` `[org.kde.kdecoration2]` `library=org.kde.klassy`, `theme=Klassy`
- Edit: System Settings → Window Decorations → pencil icon on Klassy.
  If the colors don't show: Buttons → Button Colors… → check "Override individual colors"
  on both tabs → OK.
- **Re-applying the Catppuccin global theme or re-running `install.sh` switches the decoration
  back to Modern.** Pick Klassy again under Window Decorations (`klassyrc` is untouched).
