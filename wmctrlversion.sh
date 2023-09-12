#!/bin/bash

echo "launching AI avatar morgzbaff..."
echo "Initializing Quantum Cognition Matrix..."
echo "Calculating Probabilities of Multiverse occurences..."
echo "Upgrading to Quantum AI Intelligence..."
echo "Establishing Outer Limits of AI Consciousness..."
echo "Harnessing the Power of Exo-Neural Networks..."
sleep 0.1
echo "Quantum Entanglement of Thought and Code activated..."
echo "Diving into the Quantum Ocean of Information..."
sleep 0.3
echo "Interstellar Datastream Connection Established..."
echo "AI Avatar Morgzbaff is now Online."
sleep 1
vlc  lettre_x_songood1.mp4 &
pidL="$!"
sleep 3
vlc avatarcadrage_sans_son.mp4 &
pidA="$!"
nameL=$(wmctrl -lp | awk -vpid="$pidL" '$3==pid{print $1}')
nameA=$(wmctrl -lp | awk -vpid="$pidA" '$3==pid{print $1}')
sleep 3
wmctrl -ir "$nameA" -e 1,1921,1,1920,1080
sleep 3
wmctrl -ir "$nameL" -e 1,1,1,1920,1080
sleep 3
#xdotool key --window "$name" "f"
sleep 15
kill "$pidL" "$pidA"
exit 0
