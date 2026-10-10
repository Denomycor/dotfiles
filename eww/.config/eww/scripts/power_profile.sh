#!/bin/bash

get_profile() {
    powerprofilesctl get
}

# initial state
get_profile

# listen for DBus PropertiesChanged on power-profiles-daemon
dbus-monitor --system \
    "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/net/hadess/PowerProfiles'" \
    2>/dev/null | \
    grep --line-buffered '"ActiveProfile"' | \
    while IFS= read -r _; do
        get_profile
    done
