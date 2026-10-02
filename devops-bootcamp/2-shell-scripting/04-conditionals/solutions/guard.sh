#!/bin/sh
# Lab 4 — validate the environment and require confirmation for prod
# Usage: sh guard.sh <dev|staging|prod>
env="${1:-}"

case "$env" in
    dev|staging|prod) ;;                        # valid → do nothing, continue
    *)
        echo "Usage: $0 <dev|staging|prod>" >&2
        exit 2
        ;;
esac

if [ "$env" = "prod" ]; then
    printf "You are targeting PRODUCTION. Type 'yes' to continue: "
    read -r confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted." >&2
        exit 1
    fi
fi

config="config/$env.yml"
if [ ! -f "$config" ]; then
    echo "Config file $config not found" >&2
    exit 1
fi
echo "Loading $config for $env"
