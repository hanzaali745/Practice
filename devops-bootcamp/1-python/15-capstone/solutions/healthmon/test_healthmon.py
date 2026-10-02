from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest
import requests

import healthmon


def write(tmp_path: Path, text: str) -> Path:
    p = tmp_path / "targets.yaml"
    p.write_text(text)
    return p


def test_load_targets_valid(tmp_path):
    cfg = write(tmp_path, "targets:\n  - type: disk\n    path: /\n")
    targets = healthmon.load_targets(cfg)
    assert targets[0]["name"] == "disk-1"


@pytest.mark.parametrize("text,message", [
    ("targets: []\n", "non-empty"),
    ("targets:\n  - type: ftp\n", "unknown type"),
    ("targets:\n  - type: tcp\n    host: x\n", r"missing \[.port.\]"),
    ("targets: [\n", "not valid YAML"),
])
def test_load_targets_invalid(tmp_path, text, message):
    with pytest.raises(healthmon.ConfigError, match=message):
        healthmon.load_targets(write(tmp_path, text))


def test_load_targets_missing_file(tmp_path):
    with pytest.raises(healthmon.ConfigError, match="not found"):
        healthmon.load_targets(tmp_path / "nope.yaml")


def test_check_http_ok():
    with patch("healthmon.requests.get", return_value=MagicMock(status_code=200)):
        ok, detail = healthmon.check_http({"url": "https://x"}, timeout=1)
    assert ok and "200" in detail


def test_check_http_connection_error():
    with patch("healthmon.requests.get", side_effect=requests.exceptions.ConnectionError()):
        ok, detail = healthmon.check_http({"url": "https://x"}, timeout=1)
    assert not ok and detail == "ConnectionError"


def test_check_disk_threshold():
    with patch("healthmon.shutil.disk_usage", return_value=(100, 95, 5)):
        ok, detail = healthmon.check_disk({"path": "/", "max_percent": 90}, timeout=1)
    assert not ok and "95.0%" in detail


def test_check_tcp_closed():
    ok, _ = healthmon.check_tcp({"host": "127.0.0.1", "port": 9}, timeout=0.5)
    assert not ok


def test_main_exit_codes(tmp_path, capsys):
    good = write(tmp_path, "targets:\n  - type: disk\n    path: /\n    max_percent: 100\n")
    assert healthmon.main([str(good)]) == 0
    assert "1/1 checks passed" in capsys.readouterr().out
    assert healthmon.main([str(tmp_path / "missing.yaml")]) == 2
