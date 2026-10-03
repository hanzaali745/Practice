#!/usr/bin/env bash
# export_dashboard.sh [DASHBOARD_ID] — pull a dashboard (and everything it uses) from Kibana into Git.
# Workflow: change it in the UI → run this → review the diff → commit. kibana_setup.sh imports it anywhere.
set -euo pipefail
cd "$(dirname "$0")"
KB=${KIBANA:-http://localhost:5601}
id=${1:-demo-logs-overview}
curl -fsS -X POST "$KB/api/saved_objects/_export" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
    -d "{\"objects\": [{\"type\": \"dashboard\", \"id\": \"$id\"}], \"includeReferencesDeep\": true, \"excludeExportDetails\": true}" \
  | python3 -c '
import json, sys
# stable output for clean Git diffs: one object per line, sorted by id, without fields that change on every save
drop = ("updated_at", "created_at", "version", "updated_by", "created_by", "managed", "coreMigrationVersion", "typeMigrationVersion")
objs = sorted((json.loads(line) for line in sys.stdin if line.strip()), key=lambda o: (o["type"], o["id"]))
for o in objs:
    if o["type"] == "index-pattern":
        continue                      # the data view is created by kibana_setup.sh
    for k in drop:
        o.pop(k, None)
    print(json.dumps(o, sort_keys=True))' > "kibana/$id.export.ndjson"
echo "exported $(wc -l < "kibana/$id.export.ndjson") objects to kibana/$id.export.ndjson — review with git diff"
