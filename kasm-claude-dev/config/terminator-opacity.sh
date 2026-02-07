#!/bin/bash
# Watch for Terminator windows and apply 90% opacity
while true; do
  xdotool search --class "Terminator" | while read wid; do
    xprop -id $wid -f _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY 0xE6000000
  done
  sleep 1
done