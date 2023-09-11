#!/bin/bash

sleep 1
vlc -f lettre_x_songood1.mp4 &
vlc -f avatarcadrage_sans_son.mp4 &
sleep 10
pkill vlc
