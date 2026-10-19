#!/usr/bin/env bash
# One command to check Hyprland and take the README screenshots.
# Run it inside Hyprland, from a Ghostty window:
#   ~/Developer/arch-desktop-dot-files/screenshots/take.sh          # checks, then screenshots
#   ~/Developer/arch-desktop-dot-files/screenshots/take.sh --check  # checks only
#
# Phase 1 checks the session (config errors, the bar, wallpaper, notifications, idle,
# the programs the keys launch), starts a lofi stream in cliamp so the bar and cava
# have something to show, and tests the floating-window rules. Phase 2 opens its own
# Ghostty windows with fastfetch + cava for the hero shot, then each menu on an empty
# workspace, grabs it with grim and closes it without choosing anything. It doesn't
# matter which terminal runs it. Results go to ~/Pictures/Screenshots/check.log.
# Another station: STREAM=https://... take.sh
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
# The night tint would colour the README shots, so it's off while they're taken (and back on after).
sunset_was_on=$(pgrep -x hyprsunset)
[[ -n "$sunset_was_on" ]] && pkill -x hyprsunset
trap '[[ -n "$sunset_was_on" ]] && (setsid hyprsunset >/dev/null 2>&1 &)' EXIT
STREAM="${STREAM:-https://play.streamafrica.net/lofiradio}"   # SomaFM, laut.fm and ilovemusic also work
home_ws=$(hyprctl activeworkspace -j 2>/dev/null | jq -r .id)
dispatch() { hyprctl dispatch "$1" >/dev/null 2>&1; }
# The Mac's shared Ghostty config asks for a 226x64-cell window, which overrides Hyprland's
# size rules, so each floating terminal gets an explicit size in cells (about 9.3 x 20 px).
float_term() {   # float_term <title> <cols> <rows> <command...>
    local title=$1 cols=$2 rows=$3; shift 3
    dispatch "hl.dsp.exec_cmd(\"ghostty --title=$title --window-width=$cols --window-height=$rows -e $*\")"
}
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
scale=$(hyprctl monitors -j 2>/dev/null | jq -r '.[0].scale')
[[ "$scale" == 2 || "$scale" == 2.0 ]] && ok "scale is 200%, like Plasma" || meh "scale is ${scale:-unknown}, Plasma uses 2"

say "Cursor (should be catppuccin-frappe-breeze-cursors, size 24, like Plasma)"
# hl.env sets variables after Hyprland starts, so they show up in what it launches, not in its own
# /proc environment. Launch a child and ask it.
tmp=$(mktemp)
dispatch "hl.dsp.exec_cmd(\"sh -c 'echo \$XCURSOR_THEME \$XCURSOR_SIZE > $tmp'\")"
sleep 1
read -r theme size < "$tmp"; rm -f "$tmp"
[[ "$theme" == catppuccin-frappe-breeze-cursors && "$size" == 24 ]] && ok "programs get: $theme, size $size" || bad "programs get: theme='${theme:-unset}' size='${size:-unset}'"
cursor_log="${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log"
cursor_msgs=$(grep -iE 'hyprcursor|xcursor' "$cursor_log" 2>/dev/null | tail -5)
[[ -n "$cursor_msgs" ]] && { say "  Hyprland's cursor messages:"; sed 's/^/    /' <<<"$cursor_msgs" | tee -a "$LOG"; }

say "Running"
for p in waybar hyprpaper dunst hypridle; do
    pgrep -x "$p" >/dev/null && ok "$p" || bad "$p is not running"
done
pgrep -f hyprpolkitagent >/dev/null && ok "polkit agent" || meh "no polkit agent"
hyprctl layers 2>/dev/null | grep -qi waybar && ok "bar is on screen" || bad "waybar has no layer on screen"
active=$(hyprctl hyprpaper listactive 2>&1)
if [[ "$active" == *": /"* ]]; then ok "wallpaper: $(basename "${active##*: }")"; else meh "wallpaper: ${active:-unknown}"; fi

say "Programs the keys launch"
for c in rofi cava cliamp grim hyprlock hyprshot hyprpicker pavucontrol playerctl fastfetch ghostty; do
    command -v "$c" >/dev/null && ok "$c" || bad "$c is missing"
done
notify-send -a Check "Hyprland check" "dunst is working" && ok "sent a test notification (look top-right)"

say "Music: cliamp playing $STREAM (workspace 9)"
pkill -x cliamp; sleep 1
dispatch 'hl.dsp.focus({ workspace = 9 })'; sleep 1
float_term cliamp 111 30 cliamp --auto-play "$STREAM"
sleep 8
if [[ "$(playerctl status 2>&1)" == Playing ]]; then
    ok "playing: $(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)"
else
    bad "cliamp is not playing the stream"
fi
case "$(window_float cliamp)" in
    floating) ok "cliamp opens floating" ;;
    tiled)    meh "cliamp opened but tiled (window rule not applied)" ;;
    *)        bad "cliamp window did not appear" ;;
esac
cliamp_size=$(hyprctl clients -j | jq -r '.[] | select(.title == "cliamp") | "\(.size[0])x\(.size[1])"' | head -1)
say "    cliamp window: $cliamp_size (rule asks for about 1056x648)"

say "Floating-window rule for cava (tested on workspace 9)"
float_term cava 121 20 cava
sleep 3
case "$(window_float cava)" in
    floating) ok "cava opens floating" ;;
    tiled)    meh "cava opened but tiled (window rule not applied)" ;;
    *)        bad "cava window did not appear" ;;
esac
pkill -x cava; sleep 1
dispatch "hl.dsp.focus({ workspace = ${home_ws:-1} })"

say ""
say "Checks: $pass passed, $fail failed, $warn to look at"
if [[ "${1:-}" == --check ]]; then say "Log: $LOG"; exit 0; fi

say ""
say "== Screenshots =="
say "Starting in 3 seconds. Hands off the keyboard for about 45 seconds."
sleep 3

# Hero: its own Ghostty window with fastfetch, cava tiled next to it, on an empty
# workspace. (A window titled "cava" would float, so this one is "visualizer".)
dispatch 'hl.dsp.focus({ workspace = 6 })'
sleep 1
dispatch "hl.dsp.exec_cmd(\"ghostty --title=hero -e sh -c 'clear; fastfetch; exec sleep 600'\")"
sleep 2
dispatch 'hl.dsp.exec_cmd("ghostty --title=visualizer -e cava")'
sleep 5
shot hyprland
pkill -x cava; pkill -f 'sleep 600'

# Menus on an empty workspace, so only the wallpaper is behind them.
dispatch 'hl.dsp.focus({ workspace = 7 })'
sleep 1
menu_shot rofi      "$HOME/.config/rofi/launchers/type-1/launcher.sh"  2
menu_shot powermenu "$HOME/.config/rofi/powermenu/type-2/powermenu.sh" 2
menu_shot picker    "$HOME/.config/hypr/scripts/wallpaper-picker.sh"   4

# A dunst notification and the SwayOSD volume pop-up, cropped (logical coordinates on the
# 4K screen at 2x). The OSD uses a custom value so the real volume doesn't change.
notify-send -a Hyprland "Hyprland" "Catppuccin Frappé notifications, shown by dunst"
sleep 1.5
grim -g "1421,52 499x112" "$OUT/notification.png" 2>>"$LOG" && ok "saved notification.png" || bad "grim failed for notification.png"
sleep 8
swayosd-client --custom-progress 0.6 --custom-progress-text "60%" --custom-icon audio-volume-high-symbolic
sleep 0.8
grim -g "672,806 576x154" "$OUT/osd.png" 2>>"$LOG" && ok "saved osd.png" || bad "grim failed for osd.png"

# cliamp has been playing on workspace 9 since the checks.
dispatch 'hl.dsp.focus({ workspace = 9 })'
sleep 2
shot cliamp

dispatch "hl.dsp.focus({ workspace = ${home_ws:-1} })"
say ""
say "Checks: $pass passed, $fail failed, $warn to look at"
say "Shots: $(find "$OUT" -maxdepth 1 -name '*.png' -printf '%f ' 2>/dev/null)"
say "cliamp keeps playing on workspace 9 (Super+9, then q to quit)."
say "Next: tell Claude \"shots are in\". The log is $LOG"
