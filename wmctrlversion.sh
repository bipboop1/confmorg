#!/bin/bash

echo "launching AI avatar morgzbaff..."
echo "Initializing Quantum Cognition Matrix..."
echo "Calculating Probabilities of Multiverse occurences..."
echo "Upgrading to Quantum AI Intelligence..."
echo "Establishing Outer Limits of AI Consciousness..."
echo "Harnessing the Power of Exo-Neural Networks..."
echo "Quantum Entanglement of Thought and Code activated..."
echo "Diving into the Quantum Ocean of Information..."
echo "Interstellar Datastream Connection Established..."
echo "AI Avatar Morgzbaff is now Online."
vlc  lettre_x_songood1.mp4 &
pidL="$!"
sleep 1
vlc avatarcadrage_sans_son.mp4 &
pidA="$!"
sleep 1
nameL=$(wmctrl -lp | awk -vpid="$pidL" '$3==pidL{print $1}')
nameA=$(wmctrl -lp | awk -vpid="$pidA" '$3==pidA{print $1}')
wmctrl -ir "$nameA" -e 1,1921,1,1920,1080
sleep 3
wmctrl -ir "$nameL" -e 1,1,1,1920,1080
sleep 3
#xdotool key --window "$name" "f"
sleep 15
kill "$pidL" "$pidA"
exit 0
