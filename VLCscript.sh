#!/bin/bash

vlc vidmorg.mp4 --no-one-instance &
vlc vidmorg.mp4 --no-one-instance &

sleep 35

pkill vlc
