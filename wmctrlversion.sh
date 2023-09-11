#!/bin/bash

vlc  lettre_x_songood1.mp4 &
pid="$!"
sleep 5
vlc avatarcadrage_sans_son.mp4 &
pid="$!2"
sleep 5
name=$(wmctrl -lp | awk -vpid="$pid" '$3==pid{print $1}')
name2=$(wmctrl -lp | awk -vpid="$pid" '$3==pid{print $1}')
wmctrl -ir "$name2" -e 1,1921,1,1920,1080
sleep 5
wmctrl -ir "$name" -e 1,1,1,1920,1080
sleep 4
#xdotool key --window "$name" "f"
sleep 30
kill "$pid"
killall vlc
exit 0
