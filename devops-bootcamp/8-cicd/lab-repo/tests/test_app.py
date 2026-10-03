"""Tests for demo-app. Run: python3 -m pytest -q"""
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


def free_port() -> int:
    with socket.socket() as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


@pytest.fixture
def server():
    port = free_port()
    env = {**os.environ, "PORT": str(port), "APP_VERSION": "9.9.9", "REDIS_HOST": ""}
    proc = subprocess.Popen([sys.executable, str(APP)], env=env, stdout=subprocess.PIPE, text=True)
    for _ in range(50):
        try:
            socket.create_connection(("127.0.0.1", port), timeout=0.1).close()
            break
        except OSError:
            time.sleep(0.1)
    yield f"http://127.0.0.1:{port}", proc
    proc.terminate()
    proc.wait(timeout=5)


def get(url: str) -> tuple[int, dict]:
    try:
        with urllib.request.urlopen(url, timeout=3) as r:
            return r.status, json.load(r)
    except urllib.error.HTTPError as e:
        return e.code, json.load(e)


def test_root_reports_version(server):
    base, _ = server
    code, body = get(base + "/")
    assert code == 200 and body["version"] == "9.9.9" and body["hostname"]


def test_health(server):
    base, _ = server
    assert get(base + "/health") == (200, {"status": "ok"})


def test_visits_count_in_memory(server):
    base, _ = server
    assert get(base + "/visits")[1]["visits"] == 1
    _, body = get(base + "/visits")
    assert body["visits"] == 2 and body["backend"] == "memory"


def test_work_burns_cpu_and_validates_input(server):
    base, _ = server
    code, body = get(base + "/work?ms=20")
    assert code == 200 and body["worked_ms"] == 20 and body["loops"] > 0
    assert get(base + "/work?ms=abc")[0] == 400


def test_unknown_path_is_404(server):
    base, _ = server
    assert get(base + "/nope")[0] == 404


def test_sigterm_exits_cleanly(server):
    _, proc = server
    proc.terminate()                      # SIGTERM, like `docker stop`
    assert proc.wait(timeout=5) == 0


def test_redis_auth_and_incr(monkeypatch):
    """redis_incr talks RESP to a tiny fake Redis that requires a password."""
    import importlib.util
    import threading

    spec = importlib.util.spec_from_file_location("demo_app", APP)
    app = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(app)

    srv = socket.create_server(("127.0.0.1", 0))
    received = []

    def fake_redis():
        for _ in range(2):
            conn, _ = srv.accept()
            with conn:
                data = conn.recv(1024)
                received.append(data)
                if b"AUTH" in data and b"s3cret" not in data:
                    conn.sendall(b"-WRONGPASS invalid password\r\n")
                    continue
                if b"AUTH" in data:
                    conn.sendall(b"+OK\r\n")
                    data = conn.recv(1024)
                conn.sendall(b":42\r\n")

    threading.Thread(target=fake_redis, daemon=True).start()
    monkeypatch.setattr(app, "REDIS_HOST", "127.0.0.1")
    monkeypatch.setattr(app, "REDIS_PORT", srv.getsockname()[1])
    monkeypatch.setattr(app, "REDIS_PASSWORD", "s3cret")
    assert app.redis_incr("visits") == 42
    assert received[0].startswith(b"*2\r\n$4\r\nAUTH\r\n$6\r\ns3cret\r\n")

    monkeypatch.setattr(app, "REDIS_PASSWORD", "wrong")
    with pytest.raises(RuntimeError, match="AUTH failed"):
        app.redis_incr("visits")
    srv.close()
