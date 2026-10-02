#!/usr/bin/env bash
# Lab 3 — interactive setup with read -p / -s and regex validation
set -euo pipefail

while true; do
    read -r -p "App name (lowercase, 3-21 chars): " app
    if [[ $app =~ ^[a-z][a-z0-9-]{2,20}$ ]]; then
        break
    fi
    echo "  ✗ '$app' is not valid, try again"
done

read -r -p "Environment [dev]: " env
env="${env:-dev}"

read -r -s -p "Database password: " password
echo

echo "----- summary -----"
echo "App:      $app"
echo "Env:      $env"
echo "Password: ${password//?/*}"     # replace every character with *
