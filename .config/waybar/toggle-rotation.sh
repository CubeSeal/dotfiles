#!/usr/bin/env bash

current_monitor_orientation=$(niri msg outputs | awk -F': ' '/Transform/ {print $2}' | grep -Po '^(\d|\w)+')
echo $current_monitor_orientation
output=$(niri msg outputs | head -n 1 | sed 's/.*(\(.*\))/\1/' )

if [[ $current_monitor_orientation == "normal" ]]; then
    niri msg output $output transform 90
    printf 'Switched to 90degrees"\n'
    exit 0
elif [[ $current_monitor_orientation == "90" ]]; then
    niri msg output $output transform 180
    printf 'Switched to 180degrees"\n'
    exit 0
elif [[ $current_monitor_orientation == "180" ]]; then
    niri msg output $output transform 270
    printf 'Switched to 270degrees"\n'
    exit 0
elif [[ $current_monitor_orientation == "270" ]]; then
    niri msg output $output transform normal
    printf 'Switched to normal"\n'
    exit 0
fi
