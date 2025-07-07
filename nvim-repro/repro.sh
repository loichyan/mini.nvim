#!/usr/bin/env bash
INTERVAL=${INTERVAL:-"0.05"}
test_file="nvim-repro/test.txt"
while true; do
    for _ in $(seq 10); do echo "$RANDOM"; done >"$test_file"
    git add "$test_file"
    sleep "$INTERVAL"
done
