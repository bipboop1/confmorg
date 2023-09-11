#!/bin/bash

vlc  lettre_x_songood1.mp4 &
pidL="$!"
sleep 1
vlc avatarcadrage_sans_son.mp4 &
pidA="$!"
sleep 1
nameL=$(wmctrl -lp | awk -vpid="$pidL" '$3==pid{print $1}')
nameA=$(wmctrl -lp | awk -vpid="$pidA" '$3==pid{print $1}')
wmctrl -ir "$nameA" -e 1,1921,1,1920,1080
sleep 3
wmctrl -ir "$nameL" -e 1,1,1,1920,1080
sleep 3
#xdotool key --window "$name" "f"
sleep 15
kill "$pidL" "$pidA"
exit 0
