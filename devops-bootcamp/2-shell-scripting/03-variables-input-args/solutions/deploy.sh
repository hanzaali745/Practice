#!/bin/sh
# Lab 3 — print the docker command that would deploy an app
# Usage: sh deploy.sh <app> [env] [version]
set -eu

if [ $# -lt 1 ]; then
    echo "Usage: $0 <app> [env] [version]" >&2
    exit 2
fi

app="$1"
env="${2:-dev}"
version="${3:-${DEFAULT_VERSION:-latest}}"
registry="${REGISTRY:-registry.example.com}"

echo "docker run -d --name $app-$env -e APP_ENV=$env $registry/$app:$version"
