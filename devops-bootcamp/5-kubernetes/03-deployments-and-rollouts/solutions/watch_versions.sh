#!/usr/bin/env bash
# Lab 2 — call demo-app 5 times a second and print which version answered.
# Run `kubectl port-forward deploy/demo 8000:8000` in another terminal first.
set -uo pipefail

ok=0
failed=0
trap 'echo; echo "requests ok=$ok failed=$failed"; exit 0' INT

while true; do
    if reply=$(curl -s --max-time 1 localhost:8000/); then
        version=$(sed -n 's/.*"version": "\([^"]*\)".*/\1/p' <<< "$reply")
        printf '%s %s\n' "$(date +%T.%N | cut -c1-12)" "${version:-?}"
        (( ++ok ))
    else
        printf '%s FAILED\n' "$(date +%T.%N | cut -c1-12)"
        (( ++failed ))
    fi
    sleep 0.2
done
