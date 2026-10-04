#!/bin/bash
# User-level setup of the exhibition player (no admin rights needed).
# Requires VLC and xbindkeys:  sudo apt install vlc xbindkeys
# Run on the Pi from the folder containing this file:  bash install.sh
set -e
DEST="$HOME/exhibition"
AUTOSTART="$HOME/.config/autostart"

# 1. Install the scripts
mkdir -p "$DEST" "$HOME/Videos"
cp morgzbaff.sh stop.sh vlcrc.py "$DEST/"
chmod +x "$DEST/morgzbaff.sh" "$DEST/stop.sh"

# 2. Disable the old autostart entries (renamed, not deleted)
mkdir -p "$AUTOSTART"
for f in scrXpt-autostart.desktop lxrandr-autostart.desktop; do
    [ -f "$AUTOSTART/$f" ] && mv "$AUTOSTART/$f" "$AUTOSTART/$f.disabled"
done

# 3. Start the player when the desktop starts
cat > "$AUTOSTART/morgzbaff.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Exhibition player
Exec=$DEST/morgzbaff.sh
EOF

# 4. Keyboard shortcuts: Ctrl+Alt+Q stop, Ctrl+Alt+P play
#    (xbindkeys works whatever the window manager is)
cat > "$HOME/.xbindkeysrc" << EOF
"$DEST/stop.sh"
    Control+Alt + q
"$DEST/morgzbaff.sh"
    Control+Alt + p
EOF
cat > "$AUTOSTART/xbindkeys.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Exhibition keyboard shortcuts
Exec=xbindkeys
EOF
if command -v xbindkeys > /dev/null; then
    pkill -x xbindkeys || true
    DISPLAY="${DISPLAY:-:0}" xbindkeys
else
    echo "WARNING: xbindkeys is not installed, shortcuts won't work."
    echo "         Install it with:  sudo apt install xbindkeys"
fi

echo "Done. Videos go in $HOME/Videos as rabbit1.mp4 and rabbit2.mp4."
