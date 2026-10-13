#!/usr/bin/env bash
# One command to check Hyprland and take the README screenshots.
# Run it inside Hyprland, from a Ghostty window:
#   ~/Developer/arch-desktop-dot-files/screenshots/take.sh          # checks, then screenshots
#   ~/Developer/arch-desktop-dot-files/screenshots/take.sh --check  # checks only
#
# Phase 1 checks the session: config errors, the bar, wallpaper, notifications,
# idle, the programs the keys launch, and the floating-window rules. Phase 2 puts
# fastfetch + cava on an empty workspace for the hero shot, then opens each menu
# on another empty workspace, grabs it with grim and closes it without choosing
# anything. Results go to ~/Pictures/Screenshots/check.log for Claude to read.
set -uo pipefail

OUT="$HOME/Pictures/Screenshots"
LOG="$OUT/check.log"
mkdir -p "$OUT"
: > "$LOG"
[[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] || { echo "Run this inside Hyprland, from Ghostty."; exit 1; }

pass=0; fail=0; warn=0
say()  { printf '%s\n' "$*" | tee -a "$LOG"; }
ok()   { say "  ✓ $*"; pass=$((pass+1)); }
bad()  { say "  ✗ $*"; fail=$((fail+1)); }
meh()  { say "  ! $*"; warn=$((warn+1)); }
dispatch() { hyprctl dispatch "$1" >/dev/null 2>&1; }
shot() { if grim "$OUT/$1.png" 2>>"$LOG"; then ok "saved $1.png"; else bad "grim failed for $1.png"; fi; }
# Closing rofi without choosing anything makes the menu scripts do nothing.
menu_shot() {   # menu_shot <name> <command> <seconds to wait>
    "$2" >/dev/null 2>&1 &
    sleep "$3"
    pgrep -x rofi >/dev/null && ok "$1 opened" || bad "$1 did not open"
    shot "$1"
    pkill -x rofi
    sleep 1
}
window_float() {   # window_float <title>: prints "floating" or "tiled" for a window with that title
    hyprctl clients -j 2>/dev/null | jq -r --arg t "$1" '.[] | select(.title == $t) | if .floating then "floating" else "tiled" end' | head -1
}

say "== Hyprland check, $(date '+%F %T') =="
say "$(hyprctl version 2>/dev/null | head -1)"

say "Config"
errs=$(hyprctl configerrors 2>&1)
if [[ -z "$errs" || "$errs" == *"no errors"* ]]; then ok "no config errors"; else bad "config errors: $errs"; fi
hyprctl monitors 2>/dev/null | grep -E '^Monitor|@' | sed 's/^/    /' | tee -a "$LOG"

say "Running"
for p in waybar hyprpaper dunst hypridle; do
    pgrep -x "$p" >/dev/null && ok "$p" || bad "$p is not running"
done
for p in nm-applet blueman-applet; do
    pgrep -x "$p" >/dev/null && ok "$p" || meh "$p is not running (tray icon)"
done
pgrep -f hyprpolkitagent >/dev/null && ok "polkit agent" || meh "no polkit agent"
hyprctl layers 2>/dev/null | grep -qi waybar && ok "bar is on screen" || bad "waybar has no layer on screen"
active=$(hyprctl hyprpaper listactive 2>&1)
if [[ "$active" == *flatppuccin* ]]; then ok "wallpaper: Flatppuccin"; else meh "wallpaper: ${active:-unknown}"; fi

say "Programs the keys launch"
for c in rofi cava cliamp grim hyprlock hyprshot hyprpicker pavucontrol playerctl fastfetch ghostty; do
    command -v "$c" >/dev/null && ok "$c" || bad "$c is missing"
done
notify-send -a Check "Hyprland check" "dunst is working" && ok "sent a test notification (look top-right)"
status=$(playerctl status 2>&1)
if [[ "$status" == Playing ]]; then ok "music: $(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)"; else meh "nothing is playing (cava's bars will be flat): ${status}"; fi

say "Floating-window rules (tested on workspace 9)"
dispatch 'hl.dsp.focus({ workspace = 9 })'; sleep 1
for app in cava cliamp; do
    dispatch "hl.dsp.exec_cmd(\"ghostty --title=$app -e $app\")"
    sleep 3
    case "$(window_float "$app")" in
        floating) ok "$app opens floating" ;;
        tiled)    meh "$app opened but tiled (window rule not applied)" ;;
        *)        bad "$app window did not appear" ;;
    esac
    pkill -x "$app"; sleep 1
done
dispatch 'hl.dsp.focus({ workspace = 1 })'

say ""
say "Checks: $pass passed, $fail failed, $warn to look at"
if [[ "${1:-}" == --check ]]; then say "Log: $LOG"; exit 0; fi

say ""
say "== Screenshots =="
say "Start music first, so cava's bars move and the bar shows the track. Hide anything personal."
read -rp "Press Enter when ready, then keep your hands off the keyboard (~30 s). " _

# Hero: move this terminal to its own empty workspace so only Ghostty, fastfetch
# and cava are in the picture, then cava tiles next to it. A window titled "cava"
# would float, so this one gets another title.
dispatch 'hl.dsp.window.move({ workspace = 8 })'
dispatch 'hl.dsp.focus({ workspace = 8 })'
sleep 1
dispatch 'hl.dsp.exec_cmd("ghostty --title=visualizer -e cava")'
sleep 2
clear; fastfetch
sleep 4
shot hyprland
pkill -x cava

# Menus on an empty workspace, so only the wallpaper is behind them.
dispatch 'hl.dsp.focus({ workspace = 9 })'
sleep 1
menu_shot rofi      "$HOME/.config/rofi/launchers/type-1/launcher.sh"  2
menu_shot powermenu "$HOME/.config/rofi/powermenu/type-2/powermenu.sh" 2
menu_shot picker    "$HOME/.config/hypr/scripts/wallpaper-picker.sh"   4

# cliamp, floating on the same empty workspace. Left open; quit it with q.
dispatch 'hl.dsp.exec_cmd("ghostty --title=cliamp -e cliamp")'
sleep 3
shot cliamp

dispatch 'hl.dsp.focus({ workspace = 8 })'
say ""
say "Checks: $pass passed, $fail failed, $warn to look at"
say "Shots: $(find "$OUT" -maxdepth 1 -name '*.png' -printf '%f ' 2>/dev/null)"
say "cliamp is still open on workspace 9 (Super+9, then q to quit)."
say "Next: cd ~/Developer && claude --continue, then say \"shots are in\". The log is $LOG"
