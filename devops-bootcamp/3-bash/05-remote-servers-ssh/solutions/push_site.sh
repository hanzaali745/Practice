#!/usr/bin/env bash
# Lab 3 — deploy a folder to a server with rsync
# Usage: ./push_site.sh [-n] SRC_DIR HOST:DEST_DIR
#   -n  dry run: show what WOULD change, change nothing
set -euo pipefail

usage() { echo "Usage: $0 [-n] SRC_DIR HOST:DEST_DIR" >&2; exit 2; }

dry_run=false
while getopts ":n" opt; do
    case "$opt" in
        n) dry_run=true ;;
        *) usage ;;
    esac
done
shift $(( OPTIND - 1 ))
(( $# == 2 )) || usage

src="$1"
dest="$2"
[[ -d $src ]] || { echo "ERROR: $src is not a directory" >&2; exit 1; }
[[ $dest == *:* ]] || { echo "ERROR: destination must look like HOST:/path" >&2; exit 2; }

args=(-az --delete --itemize-changes --exclude '.git' --exclude '*.log'
      -e "ssh -o BatchMode=yes -o ConnectTimeout=5")
$dry_run && args+=(--dry-run)

# "${src%/}/" → always exactly one trailing slash = copy the CONTENTS of src
changes=$(rsync "${args[@]}" "${src%/}/" "$dest")
count=$(grep -c '' <<< "$changes" || true)
[[ -z $changes ]] && count=0

echo "$changes"
echo "---"
echo "$count change(s) $($dry_run && echo 'would be made (dry run)' || echo 'made') -> $dest"
