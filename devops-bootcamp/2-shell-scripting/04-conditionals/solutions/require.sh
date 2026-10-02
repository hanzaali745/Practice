#!/bin/sh
# Lab 3 — check required tools are installed
missing=0
for tool in git curl python3 jq docker; do
    if command -v "$tool" > /dev/null 2>&1; then
        echo "✅ $tool"
    else
        echo "❌ $tool is missing   (try: sudo apt install $tool)"
        missing=$((missing + 1))
    fi
done

if [ "$missing" -gt 0 ]; then
    echo "$missing tool(s) missing" >&2
    exit 1
fi
echo "All tools present"
