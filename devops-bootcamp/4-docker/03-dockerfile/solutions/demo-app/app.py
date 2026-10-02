#!/usr/bin/env python3
"""demo-app — a tiny web service used throughout the Docker and Kubernetes tracks.

Endpoints:
  GET /         hello message with hostname (so you can SEE which container answered)
  GET /health   {"status": "ok"} — for health checks and probes
  GET /visits   visit counter: stored in Redis if REDIS_HOST is set, else in memory
  GET /work?ms=N  burn CPU for N milliseconds (default 50, max 2000) — for autoscaling labs

Configuration (environment variables):
  PORT         port to listen on (default 8000)
  APP_VERSION  version string to report (default "1.0.0")
  APP_MESSAGE  greeting (default "Hello from demo-app")
  REDIS_HOST   Redis hostname (optional); REDIS_PORT (default 6379)

Only the Python standard library is used, so the image needs no pip install.
"""
import json
import os
import signal
import socket
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

PORT = int(os.environ.get("PORT", "8000"))
VERSION = os.environ.get("APP_VERSION", "1.0.0")
MESSAGE = os.environ.get("APP_MESSAGE", "Hello from demo-app")
REDIS_HOST = os.environ.get("REDIS_HOST", "")
REDIS_PORT = int(os.environ.get("REDIS_PORT", "6379"))

_memory_visits = 0
_lock = threading.Lock()


def redis_incr(key: str) -> int:
    """INCR a key using the Redis protocol directly (no client library needed)."""
    with socket.create_connection((REDIS_HOST, REDIS_PORT), timeout=2) as s:
        s.sendall(f"*2\r\n$4\r\nINCR\r\n${len(key)}\r\n{key}\r\n".encode())
        reply = s.recv(64).decode()
    if not reply.startswith(":"):
        raise RuntimeError(f"unexpected Redis reply: {reply!r}")
    return int(reply[1:].strip())


def burn_cpu(ms: int) -> int:
    """Busy-loop for `ms` milliseconds (makes the CPU work, unlike sleep). Returns loop count."""
    deadline = time.perf_counter() + ms / 1000
    loops = 0
    while time.perf_counter() < deadline:
        loops += 1
    return loops


def count_visit() -> tuple[int, str]:
    global _memory_visits
    if REDIS_HOST:
        return redis_incr("visits"), "redis"
    with _lock:
        _memory_visits += 1
        return _memory_visits, "memory"


class Handler(BaseHTTPRequestHandler):
    def _send(self, code: int, payload: dict) -> None:
        body = (json.dumps(payload) + "\n").encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802 (name required by BaseHTTPRequestHandler)
        url = urlparse(self.path)
        if url.path == "/work":
            try:
                ms = min(int(parse_qs(url.query).get("ms", ["50"])[0]), 2000)
            except ValueError:
                self._send(400, {"error": "ms must be an integer"})
                return
            loops = burn_cpu(max(ms, 0))
            self._send(200, {"worked_ms": ms, "loops": loops, "hostname": socket.gethostname()})
        elif self.path == "/":
            self._send(200, {"message": MESSAGE, "version": VERSION, "hostname": socket.gethostname()})
        elif self.path == "/health":
            self._send(200, {"status": "ok"})
        elif self.path == "/visits":
            try:
                count, backend = count_visit()
            except OSError as e:
                self._send(503, {"error": f"redis unavailable: {e}"})
                return
            self._send(200, {"visits": count, "backend": backend, "hostname": socket.gethostname()})
        else:
            self._send(404, {"error": "not found"})

    def log_message(self, fmt: str, *args) -> None:
        # Log to stdout (one line per request) — containers should log to stdout/stderr
        print(f"{self.address_string()} {fmt % args}", flush=True)


def main() -> None:
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)

    def shutdown(signum, _frame):
        print(f"received signal {signum}, shutting down", flush=True)
        threading.Thread(target=server.shutdown).start()

    signal.signal(signal.SIGTERM, shutdown)   # `docker stop` / Kubernetes send SIGTERM
    signal.signal(signal.SIGINT, shutdown)
    print(f"demo-app {VERSION} listening on :{PORT} (redis={'on' if REDIS_HOST else 'off'})", flush=True)
    server.serve_forever()
    print("bye", flush=True)
    sys.exit(0)


if __name__ == "__main__":
    main()
