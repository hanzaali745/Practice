#!/usr/bin/env bash
# verify_image.sh IMAGE[:TAG] OWNER/REPO — check a pushed image the way a careful deployer would
#   ./verify_image.sh ghcr.io/you/cicd-lab:main you/cicd-lab
# Needs: docker, cosign, gh (GitHub CLI, logged in)
set -euo pipefail
image=${1:?usage: verify_image.sh IMAGE[:TAG] OWNER/REPO}
repo=${2:?usage: verify_image.sh IMAGE[:TAG] OWNER/REPO}

echo "== 1. resolve the tag to an immutable digest"
digest=$(docker buildx imagetools inspect "$image" --format '{{json .Manifest}}' | python3 -c 'import json,sys; print(json.load(sys.stdin)["digest"])')
ref="${image%:*}@$digest"
echo "$ref"

echo "== 2. which platforms are inside?"
docker buildx imagetools inspect "$image" | grep -E 'Platform:' | sort -u

echo "== 3. was it signed by OUR workflow? (keyless cosign)"
cosign verify "$ref" \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com \
    --certificate-identity-regexp "^https://github.com/${repo}/.github/workflows/" > /dev/null
echo "signature OK"

echo "== 4. does GitHub hold a build provenance attestation for it?"
gh attestation verify "oci://$ref" --repo "$repo" > /dev/null
echo "attestation OK"

echo "✅ $ref is multi-arch, signed and attested — deploy this digest"
