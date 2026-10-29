#!/usr/bin/env bash
# Outline bell when dunst's history is empty, bell with a dot while it holds notifications,
# sleeping bell while paused.
n=$(dunstctl count history 2>/dev/null || echo 0)
if [[ $(dunstctl is-paused 2>/dev/null) == true ]]; then
    echo "{\"text\":\"󰂠\",\"class\":\"paused\",\"tooltip\":\"Paused · $n in history\"}"
elif (( n > 0 )); then
    echo "{\"text\":\"󰅸\",\"class\":\"unread\",\"tooltip\":\"$n in history\"}"
else
    echo "{\"text\":\"󰂜\",\"class\":\"on\",\"tooltip\":\"No notifications\"}"
fi
