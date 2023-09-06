#!/bin/bash

sleep 3

vlc vidmorg.mp4 --no-one-instance &
sleep 1
vlc vidmorg.mp4 --no-one-instance &

sleep 35

pkill vlc
