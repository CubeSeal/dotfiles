#!/usr/bin/env bash

ANIMATED_WALLPAPER_PATH="$HOME/Wallpapers/Archlefirth.gif"
STATIC_WALLPAPER_PATH="$HOME/Wallpapers/Archlefirth.png"

CURRENT_WALLPAPER=$(swww query | awk -F'image: ' '{print $2}')

if [[ "$CURRENT_WALLPAPER" == "$STATIC_WALLPAPER_PATH" ]]; then
    swww img "$ANIMATED_WALLPAPER_PATH"
else
    swww img "$STATIC_WALLPAPER_PATH"
fi
