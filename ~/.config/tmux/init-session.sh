#!/bin/bash

# Get the current session name
SESSION=$(tmux display-message -p '#S')

# Only run if this is the first window (to avoid running multiple times)
WINDOW_COUNT=$(tmux list-windows -t "$SESSION" | wc -l)
if [ "$WINDOW_COUNT" -gt 1 ]; then
    exit 0
fi

# Define your directories and window names here
# Format: "window_name:directory_path"
WINDOWS=(
    "lyft1:$HOME/src/Lyft-iOS"
    "lyft2:$HOME/src/Lyft-iOS2"
    "lyft3:$HOME/src/Lyft-iOS3"
    "lyft4:$HOME/src/Lyft-iOS4"
    "idl:$HOME/src/idl"
)

# Create windows for each directory
for i in "${!WINDOWS[@]}"; do
    IFS=':' read -r window_name directory <<< "${WINDOWS[$i]}"
    
    if [ "$i" -eq 0 ]; then
        # Rename the first window and change to the directory
        tmux rename-window -t "$SESSION:1" "$window_name"
        tmux send-keys -t "$SESSION:1" "cd '$directory'" Enter
        tmux send-keys -t "$SESSION:1" "clear" Enter
    else
        # Create new window with name and directory
        tmux new-window -t "$SESSION" -n "$window_name" -c "$directory"
        tmux send-keys -t "$SESSION:$window_name" "clear" Enter
    fi
done

# Select the first window
tmux select-window -t "$SESSION:1" 