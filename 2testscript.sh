#!/bin/bash

while true; do
sleep 3
export DISPLAY=:0
sleep 1
vlc vidmorg.mp4 &
sleep 1
export DISPLAY=:0
vlc blue.mp4 &
sleep 10
pkill vlc
done
exit 0
