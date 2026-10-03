"""Integration test: demo-app + a real Redis. Runs only when REDIS_HOST is set (CI service container)."""
import json
import os
import socket
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

import pytest

APP = Path(__file__).resolve().parents[1] / "app" / "app.py"
REDIS_HOST = os.environ.get("REDIS_HOST", "")

pytestmark = pytest.mark.skipif(not REDIS_HOST, reason="set REDIS_HOST to run integration tests")


def free_port() -> int:
    with socket.socket() as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


def test_visits_are_stored_in_redis():
    port = free_port()
    env = {**os.environ, "PORT": str(port)}
    proc = subprocess.Popen([sys.executable, str(APP)], env=env)
    try:
        for _ in range(50):
            try:
                socket.create_connection(("127.0.0.1", port), timeout=0.1).close()
                break
            except OSError:
                time.sleep(0.1)
        counts = []
        for _ in range(2):
            with urllib.request.urlopen(f"http://127.0.0.1:{port}/visits", timeout=3) as r:
                body = json.load(r)
            assert body["backend"] == "redis"
            counts.append(body["visits"])
        assert counts[1] == counts[0] + 1
    finally:
        proc.terminate()
        proc.wait(timeout=5)
