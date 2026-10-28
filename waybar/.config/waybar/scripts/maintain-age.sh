#!/usr/bin/env bash
# Days since ~/scripts/maintain.sh last finished, read from the "System maintenance completed" lines
# it appends to ~/maintain.log. Turns red after a week. Hidden when the script has never run here.
log="$HOME/maintain.log"
line=$(grep 'System maintenance completed at' "$log" 2>/dev/null | tail -1)
[[ -n "$line" ]] || { echo '{"text":""}'; exit 0; }
when=$(date -d "${line##*completed at }" +%s 2>/dev/null) || { echo '{"text":""}'; exit 0; }
days=$(( ( $(date +%s) - when ) / 86400 ))
if (( days >= 7 )); then class=stale; else class=fresh; fi
printf '{"text":"󰁨 %dd","class":"%s","tooltip":"Last maintenance %dd ago · click to run it"}\n' "$days" "$class" "$days"
