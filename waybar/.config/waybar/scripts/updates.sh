#!/usr/bin/env bash
# Pending package updates for waybar: official repos (checkupdates, which uses its own sync db so
# it never touches the real one) plus AUR (yay -Qua). Polled every 30 minutes.
repo=$(checkupdates 2>/dev/null | wc -l)
aur=$(yay -Qua 2>/dev/null | wc -l)
n=$((repo + aur))
if (( n > 0 )); then class=pending; else class=uptodate; fi
printf '{"text":"󰅟 %d","class":"%s","tooltip":"%d repo · %d AUR"}\n' "$n" "$class" "$repo" "$aur"
