#!/usr/bin/env bash
#
# volume_backup.sh — back up / restore a Docker volume with a throwaway container
# Usage: volume_backup.sh backup  VOLUME DIR
#        volume_backup.sh restore ARCHIVE VOLUME
#
set -euo pipefail

usage() { sed -n '3,5p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

backup() {
    local volume="$1" dir="$2"
    docker volume inspect "$volume" > /dev/null 2>&1 || { echo "no such volume: $volume" >&2; exit 1; }
    mkdir -p "$dir"
    local dir_abs file
    dir_abs="$(cd "$dir" && pwd)"
    file="$volume-$(date +%Y%m%d-%H%M%S).tar.gz"
    docker run --rm -v "$volume":/source:ro -v "$dir_abs":/backup alpine:3.20 \
        tar -czf "/backup/$file" -C /source .
    echo "$dir/$file"
}

restore() {
    local archive="$1" volume="$2"
    [[ -f $archive ]] || { echo "no such file: $archive" >&2; exit 1; }
    local dir_abs name
    dir_abs="$(cd "$(dirname "$archive")" && pwd)"
    name="$(basename "$archive")"
    docker volume create "$volume" > /dev/null
    docker run --rm -v "$volume":/target -v "$dir_abs":/backup:ro alpine:3.20 \
        sh -c "rm -rf /target/* && tar -xzf /backup/$name -C /target"
    echo "restored $archive into volume $volume"
}

case "${1:-}" in
    backup)  [[ $# -eq 3 ]] || usage; backup "$2" "$3" ;;
    restore) [[ $# -eq 3 ]] || usage; restore "$2" "$3" ;;
    *)       usage ;;
esac
