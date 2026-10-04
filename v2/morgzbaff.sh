#!/bin/bash
# Exhibition launcher for Raspberry Pi OS (X11).
# Plays two videos in sync with VLC, one fullscreen on each HDMI screen,
# starting both again from the beginning, together, each time they end.
#
# How it stays reliable, even after a power cut:
# - Raspberry Pi OS's VLC decodes in hardware and, in fullscreen, draws
#   directly on its HDMI output, in front of everything else on the desktop.
# - The script asks the kernel which program is drawing on each HDMI output.
#   That is the proof each player is fullscreen on the right screen. Each
#   player runs under its own name (morgzplayer1, morgzplayer2) to tell them apart.
# - Players are set up one after the other on freshly reset screens, paused,
#   then started at the same moment through VLC's remote control.
# - A watchdog checks every 2 seconds. If a player crashes or loses its
#   screen, both are restarted cleanly, in sync.
# Keyboard: Ctrl+Alt+Q stops everything, Ctrl+Alt+P starts it again.

VIDEO_1="$HOME/Videos/rabbit1.mp4"  # on HDMI 1 (port next to the power socket), with sound
VIDEO_2="$HOME/Videos/rabbit2.mp4"  # on HDMI 2, silent

SCREEN_1="HDMI-1"
SCREEN_2="HDMI-2"
SCREEN_MODE="1920x1080"             # resolution sent to the screens (TVs upscale)
SCREEN_RATE="50"                    # refresh rate in Hz (50 suits 25 fps videos)

# Sync fine-tuning, in seconds (e.g. 0.1). If one video consistently runs
# ahead of the other, delay its start by that amount. Leave the other at 0.
DELAY_1="0"
DELAY_2="0"

export DISPLAY="${DISPLAY:-:0}"
HERE="$(dirname "$(readlink -f "$0")")"

# Log to a file, keeping it from growing forever
LOG="$HOME/morgzbaff.log"
if [ -f "$LOG" ] && [ "$(stat -c%s "$LOG")" -gt 1000000 ]; then
    mv -f "$LOG" "$LOG.old"
fi
exec >>"$LOG" 2>&1
log() { echo "$(date '+%F %T') $*"; }

# Only allow one copy of this script to run at a time
exec 9>/tmp/morgzbaff.lock
flock -n 9 || { log "Already running, exiting."; exit 0; }

WORKDIR="/tmp/morgzbaff"
VIDEOS=("" "$VIDEO_1" "$VIDEO_2")
SCREENS=("" "$SCREEN_1" "$SCREEN_2")
EXTRA_OPTS=("" "" "--no-audio")
NUMBERS=(0 0 1)          # VLC's fullscreen screen number for each player (0 = first)
RC_PORTS=(0 43211 43212) # VLC remote control ports (local only)
PIDS=(0 0 0)

# ---------- Screens ----------

# The kernel's display state file (needs passwordless sudo, standard on Pi OS)
DRI_STATE=$(sudo -n sh -c 'grep -l HDMI-A-1 /sys/kernel/debug/dri/*/state' 2>/dev/null | head -1)

# Prints the programs drawing on a screen, according to the kernel,
# e.g. "Xorg" (desktop), "morgzplayer1" (player 1), or nothing (screen off)
screen_owner() {
    sudo -n cat "$DRI_STATE" 2>/dev/null | awk -v conn="${1/HDMI-/HDMI-A-}" '
        /^plane\[/     { kind = "plane"; name = $2; next }
        /^connector\[/ { kind = "conn";  name = $2; next }
        /^[a-z]/       { kind = "" }
        kind == "plane" && /crtc=/        { sub(/.*crtc=/, ""); plane_crtc[name] = $0 }
        kind == "plane" && /allocated by/ { sub(/.*= /, "");    plane_owner[name] = $0 }
        kind == "conn"  && /crtc=/        { sub(/.*crtc=/, ""); conn_crtc[name] = $0 }
        END {
            c = conn_crtc[conn]
            if (c == "" || c == "(null)") exit
            for (p in plane_crtc)
                if (plane_crtc[p] == c && plane_owner[p] != "") printf "%s ", plane_owner[p]
        }'
}

# Is player n drawing on its own screen?
on_its_screen() {
    [ -z "$DRI_STATE" ] && return 0     # can't check: trust the player
    [[ "$(screen_owner "${SCREENS[$1]}")" == *"morgzplayer$1"* ]]
}

# Switch both screens off and on again in X, at SCREEN_MODE/SCREEN_RATE,
# screen 1 on the left and screen 2 on its right. This cleans up after a
# player that stopped: X does not always take its screen back by itself.
reset_screens() {
    local args=() screen pos
    for screen in "$SCREEN_1" "$SCREEN_2"; do
        xrandr --query 2>/dev/null | grep -q "^$screen connected" && args+=(--output "$screen" --off)
    done
    [ ${#args[@]} -gt 0 ] && xrandr "${args[@]}"
    sleep 1

    args=()
    for screen in "$SCREEN_1" "$SCREEN_2"; do
        xrandr --query 2>/dev/null | grep -q "^$screen connected" || { log "Screen $screen not detected"; continue; }
        [ "$screen" = "$SCREEN_1" ] && pos="0x0" || pos="${SCREEN_MODE%x*}x0"
        if xrandr --query | awk -v out="$screen" -v mode="$SCREEN_MODE" -v rate="$SCREEN_RATE" '
                $1 == out { inside = 1; next } /^[^ ]/ { inside = 0 }
                inside && $1 == mode { for (i = 2; i <= NF; i++) if ($i ~ "^" rate "\\.") found = 1 }
                END { exit !found }'; then
            args+=(--output "$screen" --mode "$SCREEN_MODE" --rate "$SCREEN_RATE" --pos "$pos")
        else
            args+=(--output "$screen" --auto --pos "$pos")
        fi
    done
    [ ${#args[@]} -gt 0 ] && xrandr "${args[@]}"
    sleep 2
}

# ---------- Players ----------

alive() { [ "${PIDS[$1]}" -gt 0 ] && kill -0 "${PIDS[$1]}" 2>/dev/null; }

# Send a remote control command to one or more players at the same moment
# Usage: rc "command" 1 [2]
rc() {
    local cmd="$1" ports=() n; shift
    for n in "$@"; do ports+=("${RC_PORTS[n]}"); done
    python3 "$HERE/vlcrc.py" "$cmd" "${ports[@]}" 2>/dev/null
}

# Prints a player's state: playing, paused, stopped, or nothing if unreachable
player_state() {
    rc status "$1" | sed -n 's/.*( state \([a-z]*\) ).*/\1/p'
}

stop_players() {
    local n i
    for n in 1 2; do
        alive "$n" && kill "${PIDS[n]}" 2>/dev/null
    done
    for i in $(seq 10); do
        alive 1 || alive 2 || break
        sleep 0.5
    done
    for n in 1 2; do
        alive "$n" && kill -9 "${PIDS[n]}" 2>/dev/null
        PIDS[n]=0
    done
    pkill -9 -x 'morgzplayer[12]' 2>/dev/null
    sleep 1
}

# Start player n, paused on the first frame, and wait for its remote control
launch_player() {
    local n="$1" video="${VIDEOS[$1]}" i
    if [ ! -f "$video" ]; then
        log "Missing file $video"
        return 1
    fi
    log "Launching player $n: $video"
    # Run VLC under its own name, with a fresh private settings folder, so
    # leftovers from a power cut or from the other player can't interfere.
    mkdir -p "$WORKDIR"
    ln -sf "$(command -v vlc)" "$WORKDIR/morgzplayer$n"
    rm -rf "$WORKDIR/config$n"; mkdir -p "$WORKDIR/config$n"
    XDG_CONFIG_HOME="$WORKDIR/config$n" "$WORKDIR/morgzplayer$n" "$video" \
        -I qt --qt-minimal-view --no-qt-fs-controller \
        --no-qt-privacy-ask --no-qt-error-dialogs \
        --no-qt-system-tray --no-qt-recentplay \
        --no-qt-video-autoresize --no-embedded-video \
        --qt-fullscreen-screennumber="${NUMBERS[n]}" --fullscreen \
        --start-paused --no-loop --play-and-pause --no-random \
        --no-video-title-show --no-osd \
        --no-one-instance --no-metadata-network-access \
        --extraintf rc --rc-host "127.0.0.1:${RC_PORTS[n]}" \
        --verbose=0 ${EXTRA_OPTS[n]} < /dev/null &
    PIDS[n]=$!

    for i in $(seq 20); do
        sleep 1
        [ "$(player_state "$n")" = paused ] && return 0
        alive "$n" || { log "Player $n quit unexpectedly"; return 1; }
    done
    log "Player $n did not become ready"
    return 1
}

# Let player n play briefly so it takes over its screen, then pause it again
take_screen() {
    local n="$1" screen="${SCREENS[$1]}" other i
    [ "$n" = 1 ] && other="$SCREEN_2" || other="$SCREEN_1"
    rc pause "$n" > /dev/null
    for i in $(seq 20); do
        sleep 1
        if on_its_screen "$n"; then
            rc pause "$n" > /dev/null
            log "Player $n is fullscreen on $screen"
            return 0
        fi
        alive "$n" || { log "Player $n quit unexpectedly"; return 1; }
    done
    if [[ "$(screen_owner "$other")" == *"morgzplayer$n"* ]]; then
        log "Player $n went to the wrong screen ($other), will use the other screen number"
        NUMBERS[n]=$((1 - NUMBERS[n]))
    else
        log "Player $n did not appear on $screen (it shows: $(screen_owner "$screen"))"
    fi
    return 1
}

# Rewind both players and start them at the same moment
play_in_sync() {
    local n
    for n in 1 2; do
        [ "$(player_state "$n")" = playing ] && rc pause "$n" > /dev/null
    done
    rc "seek 0" 1 2 > /dev/null
    sleep 2     # let both load their first frames
    if [ "$DELAY_1" = 0 ] && [ "$DELAY_2" = 0 ]; then
        rc pause 1 2 > /dev/null
    elif [ "$DELAY_1" = 0 ]; then
        rc pause 1 > /dev/null; sleep "$DELAY_2"; rc pause 2 > /dev/null
    else
        rc pause 2 > /dev/null; sleep "$DELAY_1"; rc pause 1 > /dev/null
    fi
    sleep 1
    for n in 1 2; do
        [ "$(player_state "$n")" = playing ] || { log "Player $n did not start playing"; return 1; }
    done
    log "Both videos playing in sync from the start"
}

# Clean start of both players, retrying until it works
start_all() {
    local attempt=1 delay
    while true; do
        stop_players
        reset_screens
        if launch_player 1 && take_screen 1 &&
           launch_player 2 && take_screen 2 &&
           play_in_sync; then
            return
        fi
        delay=$(( attempt < 5 ? attempt * 3 : 15 ))
        log "Start attempt $attempt failed, retrying in ${delay}s"
        sleep "$delay"
        attempt=$((attempt + 1))
    done
}

# ---------- Main ----------

log "Starting"
[ -z "$DRI_STATE" ] && log "WARNING: can't read the kernel's display state, screen checks disabled"

# Never blank the screens
xset s off s noblank 2>/dev/null
xset -dpms 2>/dev/null

# Wait for the desktop to be fully up, so nothing opens on top of the videos
for i in $(seq 60); do
    pgrep -x mutter > /dev/null && pgrep -x lxpanel > /dev/null && break
    sleep 1
done
sleep 5

start_all

# Watchdog: restart both players in sync at the end of the videos,
# and cleanly if anything goes wrong
one_ended_since=0
unreachable=0
while true; do
    sleep 2
    problem=""
    for n in 1 2; do
        if ! alive "$n"; then
            problem="Player $n stopped"
        elif ! on_its_screen "$n"; then
            problem="Player $n is no longer on ${SCREENS[n]} (it shows: $(screen_owner "${SCREENS[n]}"))"
        fi
    done
    if [ -n "$problem" ]; then
        log "$problem, restarting both players"
        start_all; one_ended_since=0; continue
    fi

    s1=$(player_state 1); s2=$(player_state 2)
    if [ -z "$s1" ] || [ -z "$s2" ]; then
        unreachable=$((unreachable + 1))
        if [ "$unreachable" -ge 5 ]; then
            log "A player stopped answering, restarting both players"
            start_all; unreachable=0; one_ended_since=0
        fi
        continue
    fi
    unreachable=0

    if [ "$s1" != playing ] && [ "$s2" != playing ]; then
        log "End of the videos, starting them again"
        play_in_sync || start_all
        one_ended_since=0
    elif [ "$s1" != playing ] || [ "$s2" != playing ]; then
        # One has ended, the other should follow within a moment
        [ "$one_ended_since" = 0 ] && one_ended_since=$(date +%s)
        if [ $(( $(date +%s) - one_ended_since )) -ge 20 ]; then
            log "Only one video ended (states: $s1 / $s2), resynchronising"
            play_in_sync || start_all
            one_ended_since=0
        fi
    else
        one_ended_since=0
    fi
done
