#!/usr/bin/env python3
"""demo-app — a tiny web service used throughout the Docker and Kubernetes tracks.

Endpoints:
  GET /         hello message with hostname (so you can SEE which container answered)
  GET /health   {"status": "ok"} — for health checks and probes
  GET /visits   visit counter: stored in Redis if REDIS_HOST is set, else in memory
  GET /work?ms=N  burn CPU for N milliseconds (default 50, max 2000) — for autoscaling labs
  GET /error    always answers 500 — for error-rate, alerting and logging labs
  GET /metrics  Prometheus metrics (requests, latency histogram, in-flight requests, build info)

Configuration (environment variables):
  PORT         port to listen on (default 8000)
  APP_VERSION  version string to report (default "1.0.0")
  APP_MESSAGE  greeting (default "Hello from demo-app")
  REDIS_HOST   Redis hostname (optional); REDIS_PORT (default 6379)
  REDIS_PASSWORD  Redis password (optional) — sent with AUTH before each command
  LOG_FORMAT   "text" (default) or "json" — one JSON object per line, ECS field names (for ELK)

Only the Python standard library is used, so the image needs no pip install.
"""
import json
import os
import signal
import socket
import sys
import threading
import time
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

PORT = int(os.environ.get("PORT", "8000"))
VERSION = os.environ.get("APP_VERSION", "1.0.0")
MESSAGE = os.environ.get("APP_MESSAGE", "Hello from demo-app")
REDIS_HOST = os.environ.get("REDIS_HOST", "")
REDIS_PORT = int(os.environ.get("REDIS_PORT", "6379"))
REDIS_PASSWORD = os.environ.get("REDIS_PASSWORD", "")
LOG_FORMAT = os.environ.get("LOG_FORMAT", "text")
HOSTNAME = socket.gethostname()

_memory_visits = 0
_lock = threading.Lock()


def resp(*parts: str) -> bytes:
    """Encode a command in the Redis protocol (RESP)."""
    out = f"*{len(parts)}\r\n"
    for p in parts:
        out += f"${len(p.encode())}\r\n{p}\r\n"
    return out.encode()


def redis_incr(key: str) -> int:
    """INCR a key using the Redis protocol directly (no client library needed)."""
    with socket.create_connection((REDIS_HOST, REDIS_PORT), timeout=2) as s:
        f = s.makefile("rb")
        if REDIS_PASSWORD:
            s.sendall(resp("AUTH", REDIS_PASSWORD))
            auth = f.readline().decode()
            if not auth.startswith("+OK"):
                raise RuntimeError("Redis AUTH failed")
        s.sendall(resp("INCR", key))
        reply = f.readline().decode()
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


def log(level: str, message: str, **fields) -> None:
    """Write one log line to stdout: plain text, or JSON with Elastic Common Schema (ECS) field names."""
    if LOG_FORMAT == "json":
        record = {
            "@timestamp": datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z"),
            "log": {"level": level},
            "message": message,
            "service": {"name": "demo-app", "version": VERSION},
            "host": {"name": HOSTNAME},
            **fields,
        }
        print(json.dumps(record), flush=True)
    else:
        print(f"{level.upper():5} {message}", flush=True)


class Metrics:
    """A tiny Prometheus registry using only the standard library (Monitoring track, Module 04).

    Real apps use the prometheus_client library; writing it by hand shows what the format really is.
    """

    BUCKETS = (0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0)
    # Only known paths become label values: a label per random URL would explode the number of time series
    PATHS = ("/", "/health", "/visits", "/work", "/error", "/metrics")

    def __init__(self) -> None:
        self.lock = threading.Lock()
        self.requests: dict[tuple[str, str, int], int] = {}
        self.buckets: dict[str, list[int]] = {}
        self.sums: dict[str, float] = {}
        self.counts: dict[str, int] = {}
        self.in_progress = 0
        self.start_time = time.time()

    def path_label(self, path: str) -> str:
        return path if path in self.PATHS else "other"

    def observe(self, method: str, path: str, code: int, seconds: float) -> None:
        path = self.path_label(path)
        with self.lock:
            key = (method, path, code)
            self.requests[key] = self.requests.get(key, 0) + 1
            buckets = self.buckets.setdefault(path, [0] * len(self.BUCKETS))
            for i, le in enumerate(self.BUCKETS):
                if seconds <= le:
                    buckets[i] += 1
            self.sums[path] = self.sums.get(path, 0.0) + seconds
            self.counts[path] = self.counts.get(path, 0) + 1

    def render(self) -> str:
        out = [
            "# HELP http_requests_total HTTP requests handled, by method, path and status code.",
            "# TYPE http_requests_total counter",
        ]
        with self.lock:
            for (method, path, code), n in sorted(self.requests.items()):
                out.append(f'http_requests_total{{method="{method}",path="{path}",code="{code}"}} {n}')
            out += [
                "# HELP http_request_duration_seconds Time to handle an HTTP request.",
                "# TYPE http_request_duration_seconds histogram",
            ]
            for path in sorted(self.buckets):
                for le, n in zip(self.BUCKETS, self.buckets[path]):
                    out.append(f'http_request_duration_seconds_bucket{{path="{path}",le="{le}"}} {n}')
                out.append(f'http_request_duration_seconds_bucket{{path="{path}",le="+Inf"}} {self.counts[path]}')
                out.append(f'http_request_duration_seconds_sum{{path="{path}"}} {self.sums[path]:.6f}')
                out.append(f'http_request_duration_seconds_count{{path="{path}"}} {self.counts[path]}')
            out += [
                "# HELP http_requests_in_progress Requests being handled right now.",
                "# TYPE http_requests_in_progress gauge",
                f"http_requests_in_progress {self.in_progress}",
            ]
        out += [
            "# HELP demo_app_build_info Always 1; the labels say which build is running.",
            "# TYPE demo_app_build_info gauge",
            f'demo_app_build_info{{version="{VERSION}"}} 1',
            "# HELP process_start_time_seconds Start time of the process since the Unix epoch.",
            "# TYPE process_start_time_seconds gauge",
            f"process_start_time_seconds {self.start_time:.3f}",
        ]
        return "\n".join(out) + "\n"


METRICS = Metrics()


class Handler(BaseHTTPRequestHandler):
    def _send(self, code: int, payload: dict | str, content_type: str = "application/json") -> None:
        body = (payload if isinstance(payload, str) else json.dumps(payload) + "\n").encode()
        self._code = code
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802 (name required by BaseHTTPRequestHandler)
        url = urlparse(self.path)
        self._code = 500
        start = time.perf_counter()
        with METRICS.lock:
            METRICS.in_progress += 1
        try:
            self._route(url)
        finally:
            seconds = time.perf_counter() - start
            with METRICS.lock:
                METRICS.in_progress -= 1
            METRICS.observe("GET", url.path, self._code, seconds)
            self._access_log(url.path, seconds)

    def _access_log(self, path: str, seconds: float) -> None:
        level = "error" if self._code >= 500 else "warn" if self._code >= 400 else "info"
        log(
            level,
            f"GET {path} {self._code} {seconds * 1000:.1f}ms",
            http={"request": {"method": "GET"}, "response": {"status_code": self._code}},
            url={"path": path},
            event={"duration": int(seconds * 1e9)},          # ECS: nanoseconds
            client={"ip": self.client_address[0]},
        )

    def _route(self, url) -> None:
        if url.path == "/work":
            try:
                ms = min(int(parse_qs(url.query).get("ms", ["50"])[0]), 2000)
            except ValueError:
                self._send(400, {"error": "ms must be an integer"})
                return
            loops = burn_cpu(max(ms, 0))
            self._send(200, {"worked_ms": ms, "loops": loops, "hostname": HOSTNAME})
        elif url.path == "/":
            self._send(200, {"message": MESSAGE, "version": VERSION, "hostname": HOSTNAME})
        elif url.path == "/health":
            self._send(200, {"status": "ok"})
        elif url.path == "/visits":
            try:
                count, backend = count_visit()
            except OSError as e:
                self._send(503, {"error": f"redis unavailable: {e}"})
                return
            self._send(200, {"visits": count, "backend": backend, "hostname": HOSTNAME})
        elif url.path == "/error":
            self._send(500, {"error": "simulated failure"})
        elif url.path == "/metrics":
            self._send(200, METRICS.render(), "text/plain; version=0.0.4; charset=utf-8")
        else:
            self._send(404, {"error": "not found"})

    def log_request(self, code="-", size="-") -> None:
        pass                                  # we write our own access log line in do_GET (with the duration)

    def log_message(self, fmt: str, *args) -> None:
        # Containers should log to stdout/stderr
        log("warn", fmt % args, client={"ip": self.client_address[0]})


def main() -> None:
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)

    def shutdown(signum, _frame):
        log("info", f"received signal {signum}, shutting down")
        threading.Thread(target=server.shutdown).start()

    signal.signal(signal.SIGTERM, shutdown)   # `docker stop` / Kubernetes send SIGTERM
    signal.signal(signal.SIGINT, shutdown)
    log("info", f"demo-app {VERSION} listening on :{PORT} (redis={'on' if REDIS_HOST else 'off'})")
    server.serve_forever()
    log("info", "bye")
    sys.exit(0)


if __name__ == "__main__":
    main()
