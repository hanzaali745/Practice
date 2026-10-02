#!/usr/bin/env python3
"""Tiny health/metrics server. Usage: lab3_health_server.py [--port 8000]"""
import argparse
import json
import os
import shutil
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

STARTED = time.time()


class Handler(BaseHTTPRequestHandler):
    def _send(self, code: int, payload: dict) -> None:
        body = json.dumps(payload).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:
        if self.path == "/health":
            self._send(200, {"status": "ok", "uptime_seconds": round(time.time() - STARTED, 1)})
        elif self.path == "/metrics":
            load1, load5, load15 = os.getloadavg()
            total, used, _free = shutil.disk_usage("/")
            self._send(200, {
                "load_average": {"1m": load1, "5m": load5, "15m": load15},
                "disk_used_percent": round(used / total * 100, 1),
            })
        else:
            self._send(404, {"error": "not found"})


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8000)
    args = parser.parse_args()
    print(f"Serving on http://0.0.0.0:{args.port} (Ctrl+C to stop)")
    try:
        HTTPServer(("0.0.0.0", args.port), Handler).serve_forever()
    except KeyboardInterrupt:
        print("\nbye")


if __name__ == "__main__":
    main()
