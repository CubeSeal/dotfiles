#!/usr/bin/env bash

# === CONFIGURATION ===
# IMPORTANT: Use an MP4 for the animation to save CPU/Battery
WALLPAPER_PATH="$HOME/Wallpapers/rainy-night-city.3840x2160.mp4"
SOCKET="/tmp/mpvpaper_socket"

if [[ $1 == '--start' ]]; then
    # Start mpvpaper in video mode on login
    mpvpaper -pf -o "--panscan=1.0 input-ipc-server=$SOCKET no-audio --loop-file=inf --hwdec=auto" ALL "$WALLPAPER_PATH"
    exit 0
elif [[ $1 == '--toggle' ]]; then
    echo "{\"command\": [\"cycle\", \"pause\"]}" | socat - $SOCKET 2>&1 > /dev/null
    exit 0
else
    echo "Usage: $0 [--start|--toggle]"
    exit 1
fi
