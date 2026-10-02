#!/usr/bin/env bash
# Lab 1 — print key facts about images
# Usage: ./image_detective.sh [image...]
set -euo pipefail

images=("$@")
(( ${#images[@]} > 0 )) || images=(nginx:1.27-alpine python:3.12-slim)

for img in "${images[@]}"; do
    docker image inspect "$img" > /dev/null 2>&1 || docker pull -q "$img" > /dev/null
    echo "== $img"
    printf '  %-8s %s MB\n' "size:" "$(( $(docker image inspect -f '{{.Size}}' "$img") / 1024 / 1024 ))"
    printf '  %-8s %s\n' "cmd:" "$(docker image inspect -f '{{json .Config.Cmd}}' "$img")"
    printf '  %-8s %s\n' "ports:" "$(docker image inspect -f '{{json .Config.ExposedPorts}}' "$img")"
    printf '  %-8s %s\n' "layers:" "$(docker image inspect -f '{{len .RootFS.Layers}}' "$img")"
    echo "  env:"
    docker image inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$img" | sed '/^$/d; s/^/    /'
done
