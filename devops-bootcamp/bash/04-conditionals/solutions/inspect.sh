#!/usr/bin/env bash
# Lab 2 — file inspector
# Usage: ./inspect.sh <path>
path="${1:?Usage: $0 <path>}"

if [[ ! -e $path && ! -L $path ]]; then
    echo "$path does not exist"
    exit 1
fi

if [[ -L $path ]]; then
    echo "$path is a symlink -> $(readlink "$path")"
elif [[ -d $path ]]; then
    echo "$path is a directory"
elif [[ -f $path ]]; then
    echo "$path is a regular file ($(stat -c %s "$path") bytes)"
    [[ -s $path ]] || echo "  (empty)"
fi

[[ -r $path ]] && echo "  readable"   || echo "  NOT readable"
[[ -w $path ]] && echo "  writable"   || echo "  NOT writable"
[[ -x $path ]] && echo "  executable" || echo "  NOT executable"
