#!/bin/bash

while true; do
sleep 3
#export DISPLAY=:0
sleep 1
vlc lettre_x_songood1.mp4 &
sleep 1
#export DISPLAY=:0
vlc avatarcadrage_sans_son.mp4 &
sleep 20
pkill vlc
done
exit 0
