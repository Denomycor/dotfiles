#!/usr/bin/env bash

while true; do
  # Print the current formatted time immediately
  date +%H:%M
  
  # Calculate seconds remaining until the next minute (00s)
  SEC=$(date +%S)
  SLEEP_TIME=$((60 - 10#$SEC))
  
  # Sleep until the exact top of the minute
  sleep "$SLEEP_TIME"
done
