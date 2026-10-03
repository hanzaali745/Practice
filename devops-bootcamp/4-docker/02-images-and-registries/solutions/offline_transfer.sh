#!/usr/bin/env bash
# Lab 4 — move images to an "air-gapped" server with save/load
set -euo pipefail

images=(alpine:3.20 nginx:1.27-alpine)
archive="images-$(date +%Y%m%d).tar.gz"
trap 'rm -f "$archive"' EXIT

declare -A before
for img in "${images[@]}"; do
    docker pull -q "$img" > /dev/null
    before[$img]=$(docker image inspect -f '{{.Id}}' "$img")
done

docker save "${images[@]}" | gzip > "$archive"
echo "saved ${#images[@]} images to $archive ($(du -h "$archive" | cut -f1))"

docker rmi "${images[@]}" > /dev/null
echo "deleted local images"

gunzip -c "$archive" | docker load
for img in "${images[@]}"; do
    after=$(docker image inspect -f '{{.Id}}' "$img")
    if [[ $after == "${before[$img]}" ]]; then
        echo "✅ $img identical (${after:7:12})"
    else
        echo "❌ $img changed!" >&2
        exit 1
    fi
done
