#!/usr/bin/env bash
# Running container count for waybar, names in the tooltip. Hidden when docker isn't installed or
# its daemon is down.
command -v docker >/dev/null || { echo '{"text":""}'; exit 0; }
names=$(docker ps --format '{{.Names}}' 2>/dev/null) || { echo '{"text":""}'; exit 0; }
n=$(grep -c . <<<"$names" || true)
tip=$(head -15 <<<"$names" | paste -sd'|' | sed 's/|/\\n/g')
printf '{"text":"󰡨 %d","class":"running","tooltip":"%d running\\n%s"}\n' "$n" "$n" "$tip"
