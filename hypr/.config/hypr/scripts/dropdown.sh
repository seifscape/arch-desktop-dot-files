#!/usr/bin/env bash
# Drop-down terminal on the special:dropdown workspace (SUPER+grave). First press starts a
# ghostty with the dev.seif.dropdown class (devtools.lua sends it to that workspace); after that
# the key just shows and hides it.
if hyprctl clients | grep -q 'class: dev.seif.dropdown'; then
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("dropdown")' >/dev/null
else
    ghostty --class=dev.seif.dropdown --title=dropdown >/dev/null 2>&1 &
fi
