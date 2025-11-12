#!/bin/bash

# Get the current session name
SESSION=$(tmux display-message -p '#S')

# Only run if this is the first window (to avoid running multiple times)
WINDOW_COUNT=$(tmux list-windows -t "$SESSION" | wc -l)
if [ "$WINDOW_COUNT" -gt 1 ]; then
    exit 0
fi

# Set the default directory for all windows (change this to your preferred path)
DEFAULT_DIR="$HOME"

# Create 4 windows, all starting in the same directory
tmux rename-window -t "$SESSION:1" "1"
tmux send-keys -t "$SESSION:1" "cd '$DEFAULT_DIR'" Enter
tmux send-keys -t "$SESSION:1" "clear" Enter

for i in {2..4}; do
    tmux new-window -t "$SESSION" -n "$i" -c "$DEFAULT_DIR"
    tmux send-keys -t "$SESSION:$i" "clear" Enter
done

# Select the first window
tmux select-window -t "$SESSION:1" 