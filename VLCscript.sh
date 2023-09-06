#!/bin/bash

sleep 3

vlc vidmorgDELAY.mp4 --no-one-instance &
sleep 2
vlc vidmorg.mp4 --no-one-instance &

#for testing :
sleep 7
pkill vlc
#end testing

sleep 35

pkill vlc
