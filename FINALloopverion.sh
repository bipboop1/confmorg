#!/bin/bash

sleep 60
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
vlc -L ~/Documents/confmorg/export91111111.mp4 &
pidL="$!"
vlc -L ~/Documents/confmorg/avatar_cadrage_911.mp4 &
pidA="$!"
sleep 2
nameL=$(wmctrl -lp | awk -vpid="$pidL" '$3==pid{print $1}')
nameA=$(wmctrl -lp | awk -vpid="$pidA" '$3==pid{print $1}')
sleep 0.1
wmctrl -ir "$nameA" -e 1,1281,1,1920,1080
sleep 0.1
wmctrl -ir "$nameL" -e 1,1,1,1280,720
sleep 1
xdotool key --window "$nameL" "f"
sleep 0.5
xdotool key --window "$nameA" "f"
sleep 0.2
exit 0
