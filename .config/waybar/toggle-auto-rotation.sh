#!/usr/bin/env bash

if pkill -f iio-niri; then
    notify-send "Auto-Rotation" "Disabled"
    printf '{ \"alt\": \"disable\" }'
else
    iio-niri &
    notify-send "Auto-Rotation" "Enabled"
    printf '{ \"alt\": \"enable\" }'
fi
