#!/bin/bash

# Session name
SESSION="main"

# Check if session already exists
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
    # Create new session with first window
    tmux new-session -d -s $SESSION -n "lyft1" -c "$HOME/src/Lyft-iOS"
    
    # Create additional windows
    tmux new-window -t $SESSION -n "lyft2" -c "$HOME/src/Lyft-iOS2"
    tmux new-window -t $SESSION -n "lyft3" -c "$HOME/src/Lyft-iOS3"
    tmux new-window -t $SESSION -n "lyft4" -c "$HOME/src/Lyft-iOS4"
    tmux new-window -t $SESSION -n "idl" -c "$HOME/src/idl"
    
    # Select first window
    tmux select-window -t $SESSION:1
fi

# Attach to session
tmux attach-session -t $SESSION 