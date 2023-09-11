#!/bin/bash

sleep 2
cvlc -f -L lettre_x_songood1.mp4 &
cvlc -f -L avatarcadrage_sans_son.mp4 &
sleep 60
pkill vlc
