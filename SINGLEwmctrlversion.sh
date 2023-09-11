#!/bin/bash

cvlc -f vidmorg.mp4 &
pid="$!"
sleep 5
name=$(wmctrl -lp | awk -vpid="$pid" '$3==pid{print $1}')
wmctrl -ir "$name" -e 1,1921,1,1920,1080
sleep 4
#xdotool key --window "$name" "f"
sleep 30
kill "$pid"
exit 0
