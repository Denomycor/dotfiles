#!/bin/bash

BATTERY_PATH="$(upower -e | grep battery)"

print_json() {
    local charge state
    charge="$(upower -i "$BATTERY_PATH" | awk -F: '/percentage/ {gsub(/[ %]/,"",$2); print $2}')"
    state="$(upower -i "$BATTERY_PATH" | awk -F: '/state/ {gsub(/ /,"",$2); print $2}')"
    echo "{\"charge\":\"$charge\",\"state\":\"$state\"}"
}

# initial output
print_json

# listen for DBus PropertiesChanged on the battery device
dbus-monitor --system \
    "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='$BATTERY_PATH'" \
    2>/dev/null | \
    grep --line-buffered -E '"State"|"Percentage"' | \
    while IFS= read -r _; do
        print_json
    done
