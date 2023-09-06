#!/bin/bash

while true; do
	mpv ~/Documents/confmorg/vidmorg.mp4 &
	mpv_pid=$!
	sleep 40
	kill -INT $mpv_pid
	sleep 2
done
