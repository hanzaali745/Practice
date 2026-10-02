from unittest.mock import MagicMock, patch

import pytest

from ops_utils import count_levels, is_valid_ipv4, is_valid_port, service_is_active


# ---- Lab 1: parametrized validator tests ----
@pytest.mark.parametrize("port,expected", [
    (1, True), (22, True), (65535, True),
    (0, False), (65536, False), (-1, False), ("80", False), (True, False),
])
def test_is_valid_port(port, expected):
    assert is_valid_port(port) is expected


@pytest.mark.parametrize("ip,expected", [
    ("192.168.1.1", True), ("0.0.0.0", True), ("255.255.255.255", True),
    ("256.1.1.1", False), ("10.0.0", False), ("a.b.c.d", False), ("1.2.3.4.5", False), ("", False),
])
def test_is_valid_ipv4(ip, expected):
    assert is_valid_ipv4(ip) is expected


# ---- Lab 2: tmp_path ----
@pytest.fixture
def sample_log(tmp_path):
    log = tmp_path / "app.log"
    log.write_text("INFO start\nERROR db\n\nERROR api\nWARN slow\n")
    return log


def test_count_levels(sample_log):
    assert count_levels(sample_log) == {"INFO": 1, "ERROR": 2, "WARN": 1}


def test_count_levels_missing_file(tmp_path):
    with pytest.raises(FileNotFoundError):
        count_levels(tmp_path / "nope.log")


# ---- Lab 3: mocking subprocess ----
@pytest.mark.parametrize("returncode,stdout,expected", [
    (0, "active\n", True),
    (3, "inactive\n", False),
    (3, "failed\n", False),
])
def test_service_is_active(returncode, stdout, expected):
    fake = MagicMock(returncode=returncode, stdout=stdout)
    with patch("ops_utils.subprocess.run", return_value=fake) as run:
        assert service_is_active("nginx") is expected
        run.assert_called_once()
        assert run.call_args.args[0] == ["systemctl", "is-active", "nginx"]
