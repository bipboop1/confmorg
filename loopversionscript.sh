#!/bin/bash

#sleep 60
sleep 2
cvlc -f -L ~/Documents/confmorg/lettre_x_songood1.mp4 &
cvlc -f -L ~/Documents/confmorg/avatarcadrage_sans_son.mp4 &
sleep 30
pkill vlc
sleep 3
reboot
