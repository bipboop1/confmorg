#!/bin/bash

while true; do
sleep 3
vlc -f vidmorg.mp4 &
sleep 10
pkill vlc
done
exit 0
