#!/usr/bin/env bash
# Tailscale state for waybar: connected, or dim when it's stopped. Hidden when it isn't installed.
command -v tailscale >/dev/null || { echo '{"text":""}'; exit 0; }
state=$(tailscale status --json 2>/dev/null | grep -m1 '"BackendState"' | sed 's/.*: *"\([^"]*\)".*/\1/')
case "$state" in
    Running)
        peers=$(tailscale status 2>/dev/null | grep -c . || true)
        printf '{"text":"󱗼","class":"up","tooltip":"Tailscale connected · %s devices"}\n' "$peers" ;;
    *)
        printf '{"text":"󱗼","class":"down","tooltip":"Tailscale %s"}\n' "${state:-unavailable}" ;;
esac
