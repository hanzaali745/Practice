"""check_dashboards.py — "unit tests" for dashboards as code (standard library only).

1. Grafana is up, the provisioned data source is healthy, and every JSON file in grafana/dashboards is loaded.
2. EVERY panel query returns data from Prometheus (with $variables filled in) — catches typos and renamed metrics
   before someone opens a blank dashboard during an incident.

Usage:  python3 check_dashboards.py [grafana_url] [prometheus_url]
        (user/password from GRAFANA_USER / GRAFANA_PASSWORD, default admin / bootcamp)
"""
import base64
import json
import os
import sys
import urllib.parse
import urllib.request
from pathlib import Path

GRAFANA = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:3000"
PROM = sys.argv[2] if len(sys.argv) > 2 else "http://localhost:9090"
AUTH = base64.b64encode(
    f"{os.environ.get('GRAFANA_USER', 'admin')}:{os.environ.get('GRAFANA_PASSWORD', 'bootcamp')}".encode()
).decode()
# What Grafana would substitute for the variables when you open the dashboard
VARIABLES = {"$__rate_interval": "1m", "$__interval": "30s", "$instance": ".*"}


def get(url: str, auth: bool = False):
    req = urllib.request.Request(url)
    if auth:
        req.add_header("Authorization", f"Basic {AUTH}")
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.load(r)


def main() -> int:
    failures = 0
    health = get(f"{GRAFANA}/api/datasources/uid/prometheus/health", auth=True)
    print(f"{'✅' if health['status'] == 'OK' else '❌'} data source: {health['message']}")
    failures += health["status"] != "OK"

    loaded = {d["uid"] for d in get(f"{GRAFANA}/api/search?type=dash-db", auth=True)}
    for path in sorted(Path(__file__).parent.glob("grafana/dashboards/*.json")):
        dash = json.loads(path.read_text())
        ok = dash["uid"] in loaded
        print(f"{'✅' if ok else '❌'} dashboard '{dash['title']}' loaded in Grafana")
        failures += not ok
        for panel in dash["panels"]:
            for target in panel.get("targets", []):
                expr = target["expr"]
                for var, value in VARIABLES.items():
                    expr = expr.replace(var, value)
                result = get(f"{PROM}/api/v1/query?" + urllib.parse.urlencode({"query": expr}))
                n = len(result["data"]["result"])
                print(f"   {'✅' if n else '❌'} {panel['title']} [{target['refId']}] → {n} series")
                failures += n == 0
    print("PASS" if failures == 0 else f"FAIL ({failures} problems)")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
