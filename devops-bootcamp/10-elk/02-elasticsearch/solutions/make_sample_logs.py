"""make_sample_logs.py — generate realistic demo-app logs (ECS JSON) spread over the last 24 hours.

Usage: python3 make_sample_logs.py [count] > logs.ndjson
"""
import json
import random
import sys
from datetime import datetime, timedelta, timezone

count = int(sys.argv[1]) if len(sys.argv) > 1 else 2000
now = datetime.now(timezone.utc)
hosts = ["web-1", "web-2", "web-3"]
paths = ["/"] * 70 + ["/visits"] * 15 + ["/work"] * 10 + ["/error"] * 3 + ["/admin", "/wp-login.php"]
versions = {"web-1": "2.1.0", "web-2": "2.1.0", "web-3": "2.0.0"}
random.seed(42)

for _ in range(count):
    host = random.choice(hosts)
    path = random.choice(paths)
    if path == "/error" or (path == "/visits" and random.random() < 0.08):
        code = 500 if path == "/error" else 503
    elif path in ("/admin", "/wp-login.php"):
        code = 404
    else:
        code = 200
    ms = random.lognormvariate(1.5, 0.6) + (random.choice([50, 120, 300, 700]) if path == "/work" else 0)
    level = "error" if code >= 500 else "warn" if code >= 400 else "info"
    ts = now - timedelta(seconds=random.uniform(0, 86400))
    print(json.dumps({
        "@timestamp": ts.isoformat(timespec="milliseconds").replace("+00:00", "Z"),
        "log": {"level": level},
        "message": f"GET {path} {code} {ms:.1f}ms",
        "http": {"request": {"method": "GET"}, "response": {"status_code": code}},
        "url": {"path": path},
        "event": {"duration": int(ms * 1e6)},
        "client": {"ip": f"203.0.113.{random.randint(1, 60)}"},
        "service": {"name": "demo-app", "version": versions[host]},
        "host": {"name": host},
    }))
