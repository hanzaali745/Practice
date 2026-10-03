#!/usr/bin/env bash
# validate.sh — check everything without a cluster:
#   1. manifests (incl. ServiceMonitor/PrometheusRule CRDs) against their schemas with kubeconform
#   2. the rules inside the PrometheusRule with promtool
#   3. every key in values.yaml exists in the pinned chart's own values.yaml (catches typos Helm silently ignores)
set -euo pipefail
cd "$(dirname "$0")"
chart_version=91.9.0
catalog='https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'

echo "== 1. kubeconform"
kubeconform -strict -summary -schema-location default -schema-location "$catalog" \
    demo-app.yaml servicemonitor.yaml prometheusrule.yaml dashboard-configmap.yaml

echo "== 2. promtool"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
chmod 755 "$tmp"                                # the promtool container runs as user "nobody"
python3 -c 'import sys, yaml; yaml.safe_dump(yaml.safe_load(open("prometheusrule.yaml"))["spec"], open(sys.argv[1], "w"))' "$tmp/rules.yml"
chmod 644 "$tmp/rules.yml"
docker run --rm --entrypoint promtool -v "$tmp:/r:ro" prom/prometheus:v3.15.0 check rules /r/rules.yml

echo "== 3. values.yaml keys exist in kube-prometheus-stack $chart_version"
git -c advice.detachedHead=false clone -q --depth 1 --filter=blob:none --sparse --branch "kube-prometheus-stack-$chart_version" \
    https://github.com/prometheus-community/helm-charts.git "$tmp/charts"
git -C "$tmp/charts" sparse-checkout set charts/kube-prometheus-stack
python3 - "$tmp/charts/charts/kube-prometheus-stack" <<'PY'
import sys, yaml
from pathlib import Path
chart = Path(sys.argv[1])
defaults = yaml.safe_load((chart / "values.yaml").read_text())
# grafana is a sub-chart: its defaults live in its own values.yaml (if vendored); only check top-level keys then
def walk(mine, theirs, path=""):
    bad = 0
    for key, value in mine.items():
        here = f"{path}.{key}" if path else key
        if not isinstance(theirs, dict) or key not in theirs:
            if path.startswith("grafana"):
                continue                       # sub-chart values are not all listed in the parent chart
            print(f"   ❌ unknown key: {here}"); bad += 1
        elif isinstance(value, dict) and theirs[key] == {}:
            continue                           # an empty map in the chart = free-form (e.g. resources: {})
        elif isinstance(value, dict) and isinstance(theirs[key], dict):
            bad += walk(value, theirs[key], here)
    return bad
bad = walk(yaml.safe_load(open("values.yaml")), defaults)
print("   ✅ all keys known" if bad == 0 else f"   {bad} unknown key(s)")
sys.exit(1 if bad else 0)
PY
echo "✅ all checks passed"
