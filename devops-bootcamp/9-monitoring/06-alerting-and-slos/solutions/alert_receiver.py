"""alert_receiver.py — a stand-in for Slack/PagerDuty: prints every notification Alertmanager sends.

It also appends each one to /data/notifications.jsonl, so scripts (chaos.sh) can check what was sent.
Usage: python3 alert_receiver.py [port]
"""
import json
import sys
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

LOG = Path("/data/notifications.jsonl") if Path("/data").is_dir() else Path("notifications.jsonl")


class Receiver(BaseHTTPRequestHandler):
    def do_POST(self) -> None:  # noqa: N802
        body = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        channel = self.path.strip("/")
        now = datetime.now(timezone.utc).strftime("%H:%M:%S")
        icon = "🔥" if body["status"] == "firing" else "✅"
        print(f"{now} [{channel}] {icon} {body['status'].upper()} group={body['groupLabels']}", flush=True)
        for alert in body["alerts"]:
            labels, notes = alert["labels"], alert["annotations"]
            print(f"      - {labels['alertname']} ({labels.get('severity', '?')}) {notes.get('summary', '')}",
                  flush=True)
        with LOG.open("a") as f:
            f.write(json.dumps({"channel": channel, "status": body["status"],
                                "alerts": [a["labels"]["alertname"] for a in body["alerts"]]}) + "\n")
        self.send_response(200)
        self.end_headers()

    def log_message(self, fmt: str, *args) -> None:
        pass


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 5001
    print(f"alert receiver listening on :{port}", flush=True)
    HTTPServer(("0.0.0.0", port), Receiver).serve_forever()
