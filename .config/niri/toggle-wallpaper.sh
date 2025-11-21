#!/usr/bin/env bash

ANIMATED_WALLPAPER_PATH="$HOME/Wallpapers/Archlefirth.gif"
STATIC_WALLPAPER_PATH="$HOME/Wallpapers/Archlefirth.png"

CURRENT_WALLPAPER=$(swww query | awk -F'image: ' 'NR == 1 {print $2}')

if [[ "$CURRENT_WALLPAPER" == "$STATIC_WALLPAPER_PATH" ]]; then
    swww img -a "$ANIMATED_WALLPAPER_PATH"
    printf "Now displaying animated wallpaper.\n"
else
    swww img -a "$STATIC_WALLPAPER_PATH"
    printf "Now displaying static wallpaper.\n"
fi
