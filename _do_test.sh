#!/usr/bin/env bash

# Usage: ./_do_test.sh delays...
if [[ $# == 0 ]]; then
    # Default delays
    set -- $(seq 0.035 0.001 0.05)
fi

words=(
    jakld
    lfi
    judakljc
    pluwlkcjawkl
    lif
    gux
    priencx
    eho12
    da23x
)

tmux selectp -t '{last}' # Go to last pane, nvim is expected there
for delay in "$@"; do
    echo delay=$delay
    tmux send -l 'cc' # Clear line and enter insert mode
    for word in "${words[@]}"; do
        for ch in $(echo $word | fold -w1); do
            tmux send -l $ch
            sleep $delay
        done
        tmux send ' '
    done
    tmux send 'Escape' # Leave insert mode
done
tmux selectp -t '{last}' # Go back to this pane
