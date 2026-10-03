"""log_alert.py — alert on LOG patterns: "more than N errors from a service in the last M minutes".

Every 30 s it asks Elasticsearch (as the read-only log_alerter user) for error counts per service, and sends
Alertmanager-style webhooks — FIRING when a service crosses the threshold, RESOLVED when it drops back — to the same
receiver used in Phase 9. (Kibana alerting rules can do this too; their Slack/webhook connectors need a paid licence.)
"""
import base64
import json
import os
import time
import urllib.error
import urllib.request

ES = os.environ.get("ES_URL", "http://elasticsearch:9200")
AUTH = base64.b64encode(f"log_alerter:{os.environ['ALERTER_PASSWORD']}".encode()).decode()
WEBHOOK = os.environ.get("WEBHOOK_URL", "http://receiver:5001/chat")
THRESHOLD = int(os.environ.get("THRESHOLD", "10"))
WINDOW = os.environ.get("WINDOW", "2m")
INTERVAL = int(os.environ.get("INTERVAL", "30"))


def post(url: str, body: dict, headers: dict) -> dict:
    req = urllib.request.Request(url, data=json.dumps(body).encode(), method="POST",
                                 headers={"Content-Type": "application/json", **headers})
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.load(r) if r.headers.get("Content-Type", "").startswith("application/json") else {}


def error_counts() -> dict[str, int]:
    result = post(f"{ES}/logs-demoapp-*,logs-nginx-*/_search", {
        "size": 0,
        "query": {"bool": {"filter": [{"term": {"log.level": "error"}},
                                      {"range": {"@timestamp": {"gte": f"now-{WINDOW}"}}}]}},
        "aggs": {"svc": {"terms": {"field": "service.name", "size": 20}}}}, {"Authorization": f"Basic {AUTH}"})
    return {b["key"]: b["doc_count"] for b in result["aggregations"]["svc"]["buckets"]}


def notify(service: str, count: int, status: str) -> None:
    post(WEBHOOK, {"status": status, "groupLabels": {"alertname": "LogErrorSpike", "service": service},
                   "alerts": [{"labels": {"alertname": "LogErrorSpike", "severity": "warning", "service": service},
                               "annotations": {"summary": f"{service}: {count} error log lines in the last {WINDOW} "
                                                          f"(threshold {THRESHOLD})"}}]}, {})
    print(f"{status.upper():8} {service} {count} errors / {WINDOW}", flush=True)


def main() -> None:
    firing: set[str] = set()
    print(f"log alerter: > {THRESHOLD} errors per {WINDOW}, checked every {INTERVAL}s", flush=True)
    while True:
        try:
            counts = error_counts()
            for service, count in counts.items():
                if count > THRESHOLD and service not in firing:
                    firing.add(service)
                    notify(service, count, "firing")
            for service in list(firing):
                if counts.get(service, 0) <= THRESHOLD:
                    firing.discard(service)
                    notify(service, counts.get(service, 0), "resolved")
        except (urllib.error.URLError, OSError, KeyError) as e:
            print(f"check failed: {e}", flush=True)          # e.g. no data stream yet
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
