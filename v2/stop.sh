#!/bin/bash
# Stops the exhibition player (the launcher first, so it can't restart the players).
# The pattern only matches the running launcher itself, not other commands
# that merely mention its name.
pkill -f '^(/bin/)?bash .*[m]orgzbaff\.sh$'
pkill -x 'morgzplayer[12]'
pkill -x vlc
sleep 2

# Give both screens back to the desktop (X doesn't always take them back itself)
export DISPLAY="${DISPLAY:-:0}"
xrandr --output HDMI-1 --off --output HDMI-2 --off 2>/dev/null
sleep 1
xrandr --output HDMI-1 --auto --pos 0x0 --primary --output HDMI-2 --auto --right-of HDMI-1 2>/dev/null

echo "$(date '+%F %T') Stopped by stop.sh" >> "$HOME/morgzbaff.log"
