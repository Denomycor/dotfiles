#!/usr/bin/env bash

get_wifi_info() {
    # Get active connection info formatted as 'SSID:SIGNAL'
    local info
    info=$(nmcli -t -f active,ssid,signal dev wifi | grep '^yes' | cut -d: -f2,3)

    if [ -n "$info" ]; then
        local ssid
        local signal
        ssid=$(echo "$info" | cut -d: -f1)
        signal=$(echo "$info" | cut -d: -f2)

        # Output as valid JSON
        printf '{"ssid": "%s", "signal": %s}\n' "$ssid" "$signal"
    else
        # Fallback JSON when disconnected
        echo '{"ssid": "Disconnected", "signal": 0}'
    fi
}

# Initial state on start
get_wifi_info

# Event loop on NetworkManager state changes
nmcli monitor | while read -r _; do
    get_wifi_info
done
