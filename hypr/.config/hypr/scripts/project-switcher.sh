#!/usr/bin/env bash
# Pick a folder under ~/Developer in rofi (SUPER+O) and open it in a ghostty running a tmux
# session named after it. Picking the same project again re-attaches to its session.
ROOT="$HOME/Developer"
THEME="$HOME/.config/rofi/launchers/type-1/style-3.rasi"
pick=$(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -not -name '.*' -printf '%f\n' | sort \
    | rofi -dmenu -i -p Project -theme "$THEME") || exit 0
[[ -n "$pick" ]] || exit 0
session=${pick//[.:]/_}   # tmux session names can't contain . or :
exec ghostty --title="$pick" --working-directory="$ROOT/$pick" -e tmux new-session -A -s "$session"
