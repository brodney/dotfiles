#!/bin/bash

# Get the current session name
SESSION=$(tmux display-message -p '#S')

# Only run if this is the first window (to avoid running multiple times)
WINDOW_COUNT=$(tmux list-windows -t "$SESSION" | wc -l | tr -d ' ')
if [ "$WINDOW_COUNT" -gt 1 ]; then
    exit 0
fi

# Add a small delay to ensure tmux is fully initialized
sleep 0.5

# Define directories for each window
DIRECTORIES=(
    "$HOME/src/Lyft-iOS"
    "$HOME/src/Lyft-iOS2"
    "$HOME/src/Lyft-iOS3"
    "$HOME/src/Lyft-iOS4"
)

# Get the first window index (works regardless of base-index setting)
FIRST_WINDOW=$(tmux list-windows -t "$SESSION" -F "#{window_index}" | head -n1)

# Set up the first window
tmux rename-window -t "$SESSION:$FIRST_WINDOW" "lyft1"
tmux send-keys -t "$SESSION:$FIRST_WINDOW" "cd '${DIRECTORIES[0]}'" Enter

# Create 3 more windows
for i in {1..3}; do
    tmux new-window -t "$SESSION" -n "lyft$((i+1))" -c "${DIRECTORIES[$i]}"
done

# Select the first window
tmux select-window -t "$SESSION:$FIRST_WINDOW" 