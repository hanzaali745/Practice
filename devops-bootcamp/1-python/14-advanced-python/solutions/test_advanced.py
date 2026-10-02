"""Tests for Module 14 labs. Run: pytest -v"""
import os
import subprocess
import sys

import pytest

from contexts import file_lock, working_directory
from decorators import retry, timed
from log_pipeline import only_level, parse, top_error_hosts
from portscan import parse_ports


# ---- Lab 1: generators ----
def test_pipeline_is_lazy_and_correct(tmp_path):
    log = tmp_path / "x.log"
    log.write_text(
        "2024-05-01 10:00:00 ERROR web-01 boom\n"
        "2024-05-01 10:00:01 INFO web-02 ok\n"
        "2024-05-01 10:00:02 ERROR web-01 bang\n"
        "2024-05-01 10:00:03 CRITICAL db-01 down\n"
    )
    gen = only_level(["a ERROR b\n"], "ERROR")
    assert iter(gen) is gen                       # a generator, not a list
    assert top_error_hosts(str(log)) == [("web-01", 2), ("db-01", 1)]
    assert next(parse(["d t INFO h hello world\n"]))["message"] == "hello world"


# ---- Lab 2: decorators ----
def test_retry_succeeds_after_failures():
    calls = []

    @retry(times=3, delay=0, exceptions=(ConnectionError,))
    def flaky():
        calls.append(1)
        if len(calls) < 3:
            raise ConnectionError
        return "ok"

    assert flaky() == "ok" and len(calls) == 3


def test_retry_reraises_and_ignores_other_errors():
    @retry(times=2, delay=0, exceptions=(ConnectionError,))
    def always_down():
        raise ConnectionError("down")

    with pytest.raises(ConnectionError):
        always_down()

    calls = []

    @retry(times=5, delay=0, exceptions=(ConnectionError,))
    def bad_value():
        calls.append(1)
        raise ValueError

    with pytest.raises(ValueError):
        bad_value()
    assert len(calls) == 1                         # not retried: wrong exception type


def test_timed_keeps_metadata(capsys):
    @timed
    def hello():
        """docstring"""
        return 42

    assert hello() == 42 and hello.__name__ == "hello" and hello.__doc__ == "docstring"
    assert "hello took" in capsys.readouterr().out


# ---- Lab 3: context managers ----
def test_working_directory_restores_even_on_error(tmp_path):
    before = os.getcwd()
    with pytest.raises(RuntimeError):
        with working_directory(str(tmp_path)):
            assert os.getcwd() == str(tmp_path)
            raise RuntimeError("boom")
    assert os.getcwd() == before


def test_file_lock_blocks_second_process(tmp_path):
    lock = str(tmp_path / "x.lock")
    here = os.path.dirname(__file__)
    code = (
        f"import sys; sys.path.insert(0, {here!r})\n"
        "from contexts import file_lock\n"
        "try:\n"
        f"    with file_lock({lock!r}): pass\n"
        "except RuntimeError: sys.exit(3)\n"
    )
    with file_lock(lock):
        assert subprocess.run([sys.executable, "-c", code]).returncode == 3
    assert subprocess.run([sys.executable, "-c", code]).returncode == 0


# ---- Lab 4: port parsing ----
@pytest.mark.parametrize("spec,expected", [("22", [22]), ("22,80", [22, 80]), ("8000-8002", [8000, 8001, 8002])])
def test_parse_ports(spec, expected):
    assert parse_ports(spec) == expected


def test_parse_ports_rejects_out_of_range():
    with pytest.raises(ValueError):
        parse_ports("0-10")
