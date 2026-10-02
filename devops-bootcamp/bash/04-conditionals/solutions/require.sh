#!/usr/bin/env bash
# Lab 3 — check required tools are installed
missing=0
for tool in git curl docker python3 jq; do
    if command -v "$tool" &>/dev/null; then
        echo "✅ $tool ($(command -v "$tool"))"
    else
        echo "❌ $tool is missing"
        missing=$(( missing + 1 ))
    fi
done

if (( missing > 0 )); then
    echo "$missing tool(s) missing" >&2
    exit 1
fi
echo "All tools present"
