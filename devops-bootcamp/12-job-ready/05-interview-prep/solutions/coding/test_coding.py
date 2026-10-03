"""Tests for the coding exercises.   python3 -m pytest -q"""
import http.server
import io
import json
import subprocess
import sys
import threading
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent))
import env_diff  # noqa: E402
import largest_files  # noqa: E402
import retry as retry_mod  # noqa: E402
import top_ips  # noqa: E402
import unready_pods  # noqa: E402
import url_checker  # noqa: E402

HERE = Path(__file__).parent
LOG = """\
10.0.0.1 - - [12/Mar/2026:13:55:36 +0000] "GET / HTTP/1.1" 200 512 "-" "curl/8.5"
10.0.0.2 - - [12/Mar/2026:13:55:37 +0000] "GET /x HTTP/1.1" 404 10 "-" "curl/8.5"
10.0.0.1 - - [12/Mar/2026:13:55:38 +0000] "GET /error HTTP/1.1" 500 20 "-" "curl/8.5"
garbage line
10.0.0.1 - - [12/Mar/2026:13:55:39 +0000] "GET / HTTP/1.1" 200 512 "-" "curl/8.5"
"""


# ---------- top_ips ----------
def test_top_ips_counts_and_statuses():
    top, statuses, bad = top_ips.analyse(io.StringIO(LOG), n=1)
    assert top == [("10.0.0.1", 3)]
    assert statuses == {"2xx": 2, "4xx": 1, "5xx": 1}
    assert bad == 1


def test_bash_one_liner_agrees(tmp_path):
    log = tmp_path / "access.log"
    log.write_text(LOG)
    out = subprocess.run([str(HERE / "top_ips.sh"), str(log), "1"], capture_output=True, text=True, check=True).stdout
    assert out.split() == ["3", "10.0.0.1"]


# ---------- url_checker ----------
@pytest.fixture
def server():
    class Handler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200 if self.path == "/ok" else 503)
            self.end_headers()

        def log_message(self, *args):
            pass

    httpd = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    threading.Thread(target=httpd.serve_forever, daemon=True).start()
    yield f"http://127.0.0.1:{httpd.server_address[1]}"
    httpd.shutdown()


def test_url_checker(server):
    results = url_checker.check_all([f"{server}/ok", f"{server}/down", "http://127.0.0.1:1/"], timeout=2)
    assert [r["ok"] for r in results] == [True, False, False]
    assert results[1]["status"] == 503
    assert results[2]["status"] is None and results[2]["error"]
    assert url_checker.main([f"{server}/ok"]) == 0
    assert url_checker.main([f"{server}/ok", f"{server}/down"]) == 1


# ---------- retry ----------
def test_retry_succeeds_after_failures():
    calls, sleeps = [], []

    @retry_mod.retry(attempts=4, base=1, retry_on=(ConnectionError,), sleep=sleeps.append)
    def flaky():
        calls.append(1)
        if len(calls) < 3:
            raise ConnectionError("reset")
        return "ok"

    assert flaky() == "ok"
    assert len(calls) == 3
    assert len(sleeps) == 2
    assert 0 <= sleeps[0] <= 1 and 0 <= sleeps[1] <= 2          # full jitter within the exponential cap


def test_retry_gives_up_and_reraises():
    sleeps = []

    @retry_mod.retry(attempts=3, retry_on=(TimeoutError,), sleep=sleeps.append)
    def always_fails():
        raise TimeoutError("slow")

    with pytest.raises(TimeoutError):
        always_fails()
    assert len(sleeps) == 2


def test_retry_does_not_retry_other_errors():
    calls = []

    @retry_mod.retry(attempts=5, retry_on=(TimeoutError,), sleep=lambda s: None)
    def bad_request():
        calls.append(1)
        raise ValueError("400 Bad Request")

    with pytest.raises(ValueError):
        bad_request()
    assert len(calls) == 1


# ---------- largest_files ----------
def test_largest_files(tmp_path):
    (tmp_path / "a").mkdir()
    (tmp_path / "a" / "big.log").write_bytes(b"x" * 5000)
    (tmp_path / "small.txt").write_bytes(b"x" * 10)
    (tmp_path / "mid.bin").write_bytes(b"x" * 2000)
    (tmp_path / "link").symlink_to(tmp_path / "a" / "big.log")
    result = largest_files.largest(str(tmp_path), n=2)
    assert [Path(p).name for _, p in result] == ["big.log", "mid.bin"]
    assert largest_files.human(5000) == "4.9K"
    assert largest_files.human(10) == "10B"


# ---------- unready_pods ----------
def pod(name, ready, **status):
    return {"metadata": {"name": name, "namespace": "prod"},
            "status": {"phase": status.pop("phase", "Running"),
                       "conditions": [{"type": "Ready", "status": "True" if ready else "False"}] + status.pop("conditions", []),
                       **status}}


def test_unready_pods():
    data = {"items": [
        pod("ok", True),
        pod("crashy", False, containerStatuses=[{
            "name": "app", "ready": False, "restartCount": 7,
            "state": {"waiting": {"reason": "CrashLoopBackOff"}},
            "lastState": {"terminated": {"reason": "OOMKilled", "exitCode": 137}}}]),
        pod("pending", False, phase="Pending",
            conditions=[{"type": "PodScheduled", "status": "False", "reason": "Unschedulable", "message": "0/3 nodes: Insufficient cpu"}]),
        pod("job-done", False, phase="Succeeded"),
    ]}
    result = {name: why for name, _, why in unready_pods.unready(data)}
    assert set(result) == {"prod/crashy", "prod/pending"}
    assert "CrashLoopBackOff (last: OOMKilled, exit 137) restarts=7" in result["prod/crashy"][0]
    assert "Unschedulable" in result["prod/pending"][0]


def test_unready_pods_cli_exit_code():
    data = json.dumps({"items": [pod("ok", True)]})
    proc = subprocess.run([sys.executable, str(HERE / "unready_pods.py")], input=data, capture_output=True, text=True)
    assert proc.returncode == 0 and "all Pods ready" in proc.stdout


# ---------- env_diff ----------
def test_env_diff_masks_secrets():
    a = env_diff.parse("# staging\nDB_HOST=db.staging\nDB_PASSWORD=s3cret\nexport DEBUG=true\nOLD=1\n")
    b = env_diff.parse('DB_HOST="db.prod"\nDB_PASSWORD=other\nDEBUG=true\nNEW=2\n')
    assert env_diff.diff(a, b) == [
        "~ DB_HOST: db.staging → db.prod",
        "~ DB_PASSWORD: **** → ****",
        "+ NEW=2",
        "- OLD=1",
    ]


def test_env_diff_rejects_garbage():
    with pytest.raises(ValueError, match="line 2"):
        env_diff.parse("A=1\nthis is not config\n")
