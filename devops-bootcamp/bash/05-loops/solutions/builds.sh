#!/usr/bin/env bash
# Lab 1 — build numbers with a C-style loop
for (( i = 1; i <= 10; i++ )); do
    if (( i % 5 == 0 )); then
        echo "Build #$i (release)"
    else
        echo "Build #$i"
    fi
done
