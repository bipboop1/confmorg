#!/bin/bash
# Exhibition launcher: two looping videos, one fullscreen on each screen.
# Works on X11 and Wayland, with any screen resolution.
# Stop everything with:  pkill -f morgzbaff.sh; pkill mpv

VIDEO_1="$HOME/Videos/video1.mp4"   # plays on SCREEN_1
VIDEO_2="$HOME/Videos/video2.mp4"   # plays on SCREEN_2

# Screen names (the HDMI port each screen is plugged into).
# Check with `xrandr` (X11) or `wlr-randr` (Wayland).
if [ -n "$WAYLAND_DISPLAY" ]; then
    SCREEN_1="HDMI-A-1"
    SCREEN_2="HDMI-A-2"
else
    SCREEN_1="HDMI-1"
    SCREEN_2="HDMI-2"
fi

LOG="$HOME/morgzbaff.log"
exec >>"$LOG" 2>&1
log() { echo "$(date '+%F %T') $*"; }

# Only allow one copy of this script to run at a time
exec 9>/tmp/morgzbaff.lock
flock -n 9 || { log "Already running, exiting."; exit 0; }

screen_ready() {
    if [ -n "$WAYLAND_DISPLAY" ]; then
        wlr-randr 2>/dev/null | grep -q "^$1 "
    else
        # Plugged in but not switched on by X11 (e.g. monitor powered on
        # after boot): enable it at its native resolution, beside screen 1.
        if xrandr --query 2>/dev/null | grep -Eq "^$1 connected [^(]*[0-9]+x[0-9]+\+"; then
            return 0
        elif xrandr --query 2>/dev/null | grep -q "^$1 connected"; then
            log "Enabling $1"
            if [ "$1" = "$SCREEN_2" ]; then
                xrandr --output "$1" --auto --right-of "$SCREEN_1"
            else
                xrandr --output "$1" --auto
            fi
            sleep 2
        fi
        return 1
    fi
}

play_forever() {  # $1 video, $2 screen
    local video="$1" screen="$2"
    while true; do
        if [ ! -f "$video" ]; then
            log "Missing file $video, retrying in 10s"
            sleep 10; continue
        fi
        if ! screen_ready "$screen"; then
            log "Waiting for screen $screen"
            sleep 2; continue
        fi
        log "Playing $video on $screen"
        mpv "$video" \
            --title="player-$screen" \
            --screen-name="$screen" --fs-screen-name="$screen" --fs \
            --loop-file=inf \
            --hwdec=auto-safe \
            --no-osc --osd-level=0 \
            --no-input-default-bindings \
            --cursor-autohide=always \
            --no-terminal
        log "Player on $screen stopped, restarting in 2s"
        sleep 2
    done
}

log "Starting"
play_forever "$VIDEO_1" "$SCREEN_1" &
play_forever "$VIDEO_2" "$SCREEN_2" &
wait
