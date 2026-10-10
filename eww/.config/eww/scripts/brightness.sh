#!/bin/bash

get_brightness() {
    brightnessctl -m | cut -d, -f4 | tr -d '%'
}

# initial state
get_brightness

udevadm monitor --udev --subsystem-match=backlight | \
    while IFS= read -r _; do
        get_brightness
    done
