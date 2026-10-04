#!/bin/bash

while true; do
	mpv ~/Documents/confmorg/vidmorg.mp4 &
	mpv_pid=$!
	mpv ~/Documents/confmorg/vidmorg.mp4 &
	mpv_pid2=$!
	sleep 35
	kill -INT $mpv_pid
	kill -INT $mpv_pid2
done

