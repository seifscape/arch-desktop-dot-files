#!/usr/bin/env bash
# Bell for waybar from dunst: an outlined bell, crossed out while paused. The number of
# notifications in dunst's history is in the tooltip.
n=$(dunstctl count history 2>/dev/null || echo 0)
if [[ $(dunstctl is-paused 2>/dev/null) == true ]]; then
    echo "{\"text\":\"󰂛\",\"class\":\"paused\",\"tooltip\":\"Paused · $n in history\"}"
else
    echo "{\"text\":\"󰂜\",\"class\":\"on\",\"tooltip\":\"$n in history\"}"
fi
