#!/bin/bash

while true; do
	mpv --fs ~/Documents/confmorg/vidmorg.mp4 &
	mpv_pid=$!
	sleep 7
	kill -INT $mpv_pid
	sleep 1
done
