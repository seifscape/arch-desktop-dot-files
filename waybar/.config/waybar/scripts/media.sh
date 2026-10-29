#!/usr/bin/env bash
# Now playing for waybar: "󰐊 Title · Artist", from whatever player speaks MPRIS (cliamp, Spotify,
# a browser). Waybar polls this every couple of seconds. It replaces waybar's own `mpris` module,
# which segfaults in libplayerctl when a player quits (pressing q in cliamp killed the whole bar).
esc() { local s=${1//\\/\\\\}; printf '%s' "${s//\"/\\\"}"; }
cut_to() { local s=$1 n=$2; (( ${#s} > n )) && s="${s:0:n-1}…"; printf '%s' "$s"; }

status=$(playerctl status 2>/dev/null)
case "$status" in
    Playing) icon="󰐊"; class=playing ;;
    Paused)  icon="󰏤"; class=paused ;;
    *)       echo '{"text":"","class":"stopped"}'; exit 0 ;;
esac

title=$(playerctl metadata title 2>/dev/null)
artist=$(playerctl metadata artist 2>/dev/null)
album=$(playerctl metadata album 2>/dev/null)
player=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)

text="$icon $(cut_to "$title" 26)"
[[ -n "$artist" ]] && text+=" · $(cut_to "$artist" 20)"
tip="$player: $title"; [[ -n "$artist" ]] && tip+=" — $artist"; [[ -n "$album" ]] && tip+=" ($album)"
printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$(esc "$text")" "$class" "$(esc "$tip")"
