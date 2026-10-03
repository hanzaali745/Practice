"""load_sample_data.py — install the index template and bulk-load 24 h of generated demo-app logs (stdlib only).

Usage: python3 load_sample_data.py [elasticsearch_url] [count]
"""
import json
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

ES = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:9200"
COUNT = sys.argv[2] if len(sys.argv) > 2 else "5000"
HERE = Path(__file__).parent


def call(method: str, path: str, body: bytes, ctype: str = "application/json") -> dict:
    req = urllib.request.Request(ES + path, data=body, method=method, headers={"Content-Type": ctype})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


for _ in range(60):                                      # wait for Elasticsearch
    try:
        urllib.request.urlopen(ES, timeout=2)
        break
    except OSError:
        time.sleep(2)

call("PUT", "/_index_template/demo-logs", (HERE / "index-template.json").read_bytes())
lines = subprocess.run([sys.executable, str(HERE / "make_sample_logs.py"), COUNT],
                       capture_output=True, text=True, check=True).stdout.splitlines()
bulk = "".join('{"index":{}}\n' + line + "\n" for line in lines).encode()
result = call("POST", "/demo-logs-sample/_bulk?refresh=true", bulk, "application/x-ndjson")
print(f"loaded {len(result['items'])} documents into demo-logs-sample, errors={result['errors']}")
