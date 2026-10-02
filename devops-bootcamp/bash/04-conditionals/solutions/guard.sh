#!/usr/bin/env bash
# Lab 4 — validate environment and require confirmation for prod
# Usage: ./guard.sh <dev|staging|prod>
env="${1:-}"

if [[ ! $env =~ ^(dev|staging|prod)$ ]]; then
    echo "Usage: $0 <dev|staging|prod>" >&2
    exit 1
fi

if [[ $env == "prod" ]]; then
    read -r -p "You are targeting PRODUCTION. Type 'yes' to continue: " confirm
    if [[ $confirm != "yes" ]]; then
        echo "Aborted." >&2
        exit 1
    fi
fi

config="config/${env}.yml"
if [[ ! -f $config ]]; then
    echo "Config file $config not found" >&2
    exit 1
fi
echo "Loading $config for $env"
