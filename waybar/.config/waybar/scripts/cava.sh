#!/usr/bin/env bash
# Streams a 12-bar cava visualizer to waybar as JSON, one line per frame. Empty while nothing plays.
# Waybar has no built-in cava module in Arch's build, so cava's raw ASCII output (digits 0-7,
# ';'-separated) is mapped onto block characters here.
# sed needs a UTF-8 locale for the block characters, and waybar's environment may not set one
export LC_ALL=C.UTF-8
command -v cava >/dev/null || { echo '{"text":""}'; exit 0; }
cleanup() { pkill -P $$ 2>/dev/null || true; }
trap cleanup EXIT INT TERM
cava -p "$(dirname "$0")/cava.conf" 2>/dev/null \
  | sed -u -e 's/;//g' -e 'y/01234567/▁▂▃▄▅▆▇█/' \
           -e 's/.*/{"text":"&","class":"active"}/' \
           -e 's/"text":"▁*","class":"active"/"text":"","class":"idle"/' &
wait
