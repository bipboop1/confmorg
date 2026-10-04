#!/bin/bash
# Prints diagnostic information about the Pi's display, audio and autostart setup.
# Run on the Pi:  bash pi-info.sh
export DISPLAY="${DISPLAY:-:0}"
B=/boot/firmware; [ -d "$B" ] || B=/boot

echo "== Model";        tr -d '\0' < /proc/device-tree/model; echo
echo "== OS";           grep PRETTY_NAME /etc/os-release; uname -r
echo "== mpv";          mpv --version | head -1
echo "== Screens";      xrandr --query | grep connected
echo "== Audio devices (mpv)"; mpv --audio-device=help
echo "== Audio server"; pactl info 2>&1 | grep -E 'Server Name|Default Sink'
echo "== Boot cmdline"; cat "$B/cmdline.txt"
echo "== Autostart entries"
for f in /etc/xdg/autostart/scrXpt.desktop ~/.config/autostart/*.desktop; do
    echo "--- $f"; cat "$f"
done
echo "== launch_script.sh"; cat ~/Documents/confmorg/launch_script.sh
echo "== Screen blanking";  xset q | grep -iA2 'screen saver\|dpms'
echo "== lightdm";          grep -s xserver-command /etc/lightdm/lightdm.conf
echo "== Power";            vcgencmd get_throttled
