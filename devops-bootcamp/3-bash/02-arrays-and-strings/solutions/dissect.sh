#!/usr/bin/env bash
# Lab 3 — dissect a path and an image reference using parameter expansion only
path="/opt/releases/api-service-v2.3.1.tar.gz"
image="ghcr.io/acme/web-frontend:1.8.0-rc1"

file="${path##*/}"
name="${file%.tar.gz}"
echo "directory:  ${path%/*}"
echo "file:       $file"
echo "no ext:     $name"
echo "version:    ${name##*-v}"

ref="${image%:*}"
echo "registry:   ${ref%%/*}"
echo "repository: ${ref#*/}"
echo "tag:        ${image##*:}"
