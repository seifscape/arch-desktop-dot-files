#!/usr/bin/env bash
# Run ~/scripts/maintain.sh in a floating ghostty (SUPER+SHIFT+U) and keep it open at the end so
# the summary can be read. The script lives outside this repo, so skip with a note if it's missing.
script="$HOME/scripts/maintain.sh"
if [[ ! -x "$script" ]]; then
    notify-send "Maintenance" "$script not found"
    exit 1
fi
exec ghostty --title=maintain --window-width=120 --window-height=36 -e \
    bash -c "\"$script\"; echo; read -r -p 'Press Enter to close ' _"
