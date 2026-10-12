#!/usr/bin/env bash
# Take the README screenshots in Hyprland. Run it from a Ghostty window:
#   ~/Developer/arch-desktop-dot-files/screenshots/take.sh
# This window becomes the hero shot (fastfetch + cava), then the script opens
# each menu on an empty workspace, grabs the screen with grim and closes the
# menu again without choosing anything. Shots go to ~/Pictures/Screenshots.
set -uo pipefail

OUT="$HOME/Pictures/Screenshots"
mkdir -p "$OUT"
[[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] || { echo "Run this inside Hyprland."; exit 1; }

dispatch() { hyprctl dispatch "$1" >/dev/null; }
shot() { grim "$OUT/$1.png" && echo "  saved $OUT/$1.png"; }
menu_shot() {   # menu_shot <name> <command> <seconds to wait>
    "$2" >/dev/null 2>&1 &
    sleep "$3"
    shot "$1"
    pkill -x rofi   # closes the menu with no choice made, so nothing happens
    sleep 1
}

echo "Start some music first (browser, Spotify...), so cava's bars move"
echo "and the bar shows the track. Hide anything personal."
read -rp "Press Enter when ready. " _

# 1. Hero: this terminal shows fastfetch, cava tiles next to it. (A window
#    titled "cava" floats by our rules, so this one gets another title.)
dispatch 'hl.dsp.exec_cmd("ghostty --title=visualizer -e cava")'
sleep 2
clear; fastfetch
sleep 4
shot hyprland
pkill -x cava

# 2-4. Menus on an empty workspace, so only the wallpaper is behind them.
dispatch 'hl.dsp.focus({ workspace = 9 })'
sleep 1
menu_shot rofi      "$HOME/.config/rofi/launchers/type-1/launcher.sh"  2
menu_shot powermenu "$HOME/.config/rofi/powermenu/type-2/powermenu.sh" 2
menu_shot picker    "$HOME/.config/hypr/scripts/wallpaper-picker.sh"   4

# 5. cliamp, floating on the same empty workspace. Left open for you to close (q).
dispatch 'hl.dsp.exec_cmd("ghostty --title=cliamp -e cliamp")'
sleep 3
shot cliamp

dispatch 'hl.dsp.focus({ workspace = 1 })'
echo
echo "Done: $(ls "$OUT" | tr '\n' ' ')"
echo "cliamp is still open on workspace 9 (Super+9, then q to quit)."
echo "Back in Claude Code: claude --continue, then say \"shots are in\"."
