#!/usr/bin/env bash
# validate.sh — check everything without a cluster: manifests (kubeconform) and the Fluent Bit config (--dry-run)
set -euo pipefail
cd "$(dirname "$0")"

echo "== kubeconform"
kubectl create configmap fluent-bit-config -n logging --from-file=fluent-bit.yaml --dry-run=client -o yaml > /tmp/fb-cm.yaml
kubeconform -strict -summary fluent-bit-daemonset.yaml /tmp/fb-cm.yaml

echo "== fluent-bit --dry-run (parses the config with the real binary)"
docker run --rm -v "$PWD/fluent-bit.yaml:/fluent-bit/etc/fluent-bit.yaml:ro" \
    -e ES_HOST=localhost -e ES_PORT=9200 -e ES_API_KEY=dummy -e ES_TLS=off \
    fluent/fluent-bit:4.2.8 --config=/fluent-bit/etc/fluent-bit.yaml --dry-run
echo "✅ valid"
