#!/usr/bin/env bash
# Tailscale logo for waybar's image module: prints the path of the green logo while connected and
# the dim one otherwise, then a tooltip line. Prints nothing when tailscale isn't installed.
icons="$HOME/.config/waybar/icons"
command -v tailscale >/dev/null || exit 0
state=$(tailscale status --json 2>/dev/null | grep -m1 '"BackendState"' | sed 's/.*: *"\([^"]*\)".*/\1/')
if [[ "$state" == Running ]]; then
    peers=$(tailscale status 2>/dev/null | grep -c . || true)
    printf '%s\nTailscale connected · %s devices\n' "$icons/tailscale-up.png" "$peers"
else
    printf '%s\nTailscale %s\n' "$icons/tailscale-down.png" "${state:-unavailable}"
fi
