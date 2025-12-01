#!/usr/bin/env bash
#Requirements: mpvpaper, ffmpeg, swww

# === CONFIGURATION ===
# IMPORTANT: Use an MP4 for the animation to save CPU/Battery
WALLPAPER_PATH="$HOME/Wallpapers/rainy-night-city.3840x2160.mp4"
# Using robust extension stripping (works for .mp4, .mkv, etc)
STATIC_PATH="${WALLPAPER_PATH%.*}.png"

function start_swww_daemon {
    if ! pgrep -x "swww-daemon" > /dev/null; then
        printf "swww is not running. Starting swww...\n"
        swww-daemon &
        sleep 1
    fi
}

if [ ! -f "$WALLPAPER_PATH" ]; then
    printf "Wallpaper video not found at $WALLPAPER_PATH\n"
    exit 1
fi

if [[ $1 == '--start' ]]; then


    if [ ! -f "$STATIC_PATH" ]; then
        printf "Creating static wallpaper image from video...\n"
        ffmpeg -y -i "$WALLPAPER_PATH" -vframes 1 -f image2 "$STATIC_PATH" > /dev/null 2>&1
    fi

    start_swww_daemon
    
    exit 0

elif [[ $1 == '--toggle' ]]; then
    
    # We use -f to match the filename to ensure we don't kill unrelated instances
    if pgrep -f "mpvpaper.*$WALLPAPER_PATH" > /dev/null; then
        printf "Stopping animated wallpaper...\n"
        start_swww_daemon
        pkill mpvpaper
    else
        printf "Starting animated wallpaper...\n"
        # Using the optimized flags (GPU usage + Fill screen)
        mpvpaper -pf -o "no-audio --loop-file=inf --hwdec=auto --panscan=1.0" ALL "$WALLPAPER_PATH"
        sleep 1
        pkill swww-daemon
    fi

    exit 0
else
    echo "Usage: $0 [--start|--toggle]"
    exit 1
fi
