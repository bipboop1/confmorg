#!/bin/bash

while true; do
	sleep 3

#vlc vidmorgDELAY.mp4 --no-one-instance &
#sleep 2
	vlc -f vidmorg.mp4 &
	vlc -f vidmorg2.mp4 &

#for testing :
#sleep 7
#pkill vlc
#exit 0
#end testing

	sleep 35

	pkill vlc
done

exit 0
