#!/usr/bin/env bash
# Bell for waybar from dunst: shows the waiting-notification count, dimmed when paused.
n=$(dunstctl count history 2>/dev/null || echo 0)
if [[ $(dunstctl is-paused 2>/dev/null) == true ]]; then
    echo "{\"text\":\"󰂛\",\"class\":\"paused\"}"
else
    echo "{\"text\":\"󰂚 $n\",\"class\":\"on\"}"
fi
