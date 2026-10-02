#!/bin/sh
# Lab 2 — file inspector
# Usage: sh inspect.sh <path>
path="${1:?Usage: $0 <path>}"

if [ ! -e "$path" ] && [ ! -L "$path" ]; then
    echo "$path does not exist"
    exit 1
fi

if [ -L "$path" ]; then
    echo "$path is a symlink"
elif [ -d "$path" ]; then
    echo "$path is a directory"
elif [ -f "$path" ]; then
    echo "$path is a regular file ($(wc -c < "$path") bytes)"
    [ -s "$path" ] || echo "  (empty)"
fi

if [ -r "$path" ]; then echo "  readable";   else echo "  NOT readable";   fi
if [ -w "$path" ]; then echo "  writable";   else echo "  NOT writable";   fi
if [ -x "$path" ]; then echo "  executable"; else echo "  NOT executable"; fi
