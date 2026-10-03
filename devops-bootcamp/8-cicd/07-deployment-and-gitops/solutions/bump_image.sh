#!/usr/bin/env bash
# bump_image.sh KUSTOMIZATION IMAGE TAG [DIGEST] — point the demo-app image of a kustomization.yaml at a new build
#   ./bump_image.sh deploy/k8s/kustomization.yaml ghcr.io/you/cicd-lab sha-1a2b3c4
#   ./bump_image.sh deploy/overlays/production/kustomization.yaml ghcr.io/you/cicd-lab sha-1a2b3c4 sha256:9f86d0...
# With a DIGEST, Kubernetes pulls exactly that image (immutable); the tag stays for humans to read.
# (kustomize edit set image does the same if kustomize is installed; this needs only sed)
set -euo pipefail
usage="usage: bump_image.sh KUSTOMIZATION IMAGE TAG [DIGEST]"
file=${1:?$usage} image=${2:?$usage} tag=${3:?$usage} digest=${4:-}

[[ $tag =~ ^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}$ ]] || { echo "invalid tag: $tag" >&2; exit 2; }
[[ -z $digest || $digest =~ ^sha256:[0-9a-f]{64}$ ]] || { echo "invalid digest: $digest" >&2; exit 2; }
grep -q '^  - name: demo-app$' "$file" || { echo "no demo-app image entry in $file" >&2; exit 1; }

# Edit only the lines inside the "- name: demo-app" entry: set newName/newTag, drop any old digest
sed -i -E "/^  - name: demo-app$/,/^  - name:|^[^ ]/{
  s|^(    newName: ).*|\1${image}|
  s|^(    newTag: ).*|\1${tag}|
  /^    digest: /d
}" "$file"
if [[ -n $digest ]]; then
    sed -i -E "/^  - name: demo-app$/,/^  - name:|^[^ ]/{
  s|^(    newTag: .*)$|\1\n    digest: ${digest}|
}" "$file"
fi

grep -A3 '^  - name: demo-app$' "$file"
