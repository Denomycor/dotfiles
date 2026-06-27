#!/bin/bash
# scripts/listen_volume.sh

get_volume() {
  pactl get-sink-volume @DEFAULT_SINK@ \
    | head -n 1 \
    | awk -F'/' '{gsub(/ /,"",$2); gsub(/%/,"",$2); print $2}'
}

get_mute() {
  pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'
}

print_json() {
  local vol mute
  vol="$(get_volume)"     # like: 42%
  mute="$(get_mute)"      # yes/no

  if [ "$mute" = "yes" ]; then
    echo "{\"volume\":\"$vol\",\"muted\":true}"
  else
    echo "{\"volume\":\"$vol\",\"muted\":false}"
  fi
}

# initial output
print_json

# listen for changes
pactl subscribe | while read -r line; do
  case "$line" in
    *"on sink"*|*"on server"*)
      print_json
      ;;
  esac
done

