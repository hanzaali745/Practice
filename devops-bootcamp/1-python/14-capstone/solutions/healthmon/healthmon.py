#!/usr/bin/env python3
"""healthmon — check HTTP endpoints, TCP ports and disk usage from a YAML file.

Exit codes: 0 = all checks passed, 1 = at least one check failed, 2 = bad usage/config.
"""
from __future__ import annotations

import argparse
import json
import logging
import shutil
import socket
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from dataclasses import asdict, dataclass
from pathlib import Path

import requests
import yaml

log = logging.getLogger("healthmon")


class ConfigError(Exception):
    """Raised when the targets file is invalid."""


@dataclass
class Result:
    name: str
    kind: str
    ok: bool
    detail: str
    duration_ms: float


def check_http(target: dict, timeout: float) -> tuple[bool, str]:
    expected = int(target.get("expect_status", 200))
    try:
        resp = requests.get(target["url"], timeout=timeout)
    except requests.exceptions.RequestException as e:
        return False, f"{type(e).__name__}"
    return resp.status_code == expected, f"HTTP {resp.status_code} (expected {expected})"


def check_tcp(target: dict, timeout: float) -> tuple[bool, str]:
    host, port = target["host"], int(target["port"])
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True, f"{host}:{port} open"
    except OSError as e:
        return False, f"{host}:{port} {e.strerror or type(e).__name__}"


def check_disk(target: dict, timeout: float) -> tuple[bool, str]:
    max_percent = float(target.get("max_percent", 90))
    try:
        total, used, _free = shutil.disk_usage(target["path"])
    except OSError as e:
        return False, str(e)
    percent = used / total * 100
    return percent <= max_percent, f"{percent:.1f}% used (max {max_percent:.0f}%)"


CHECKS = {"http": check_http, "tcp": check_tcp, "disk": check_disk}
REQUIRED_KEYS = {"http": {"url"}, "tcp": {"host", "port"}, "disk": {"path"}}


def load_targets(path: Path) -> list[dict]:
    """Load and validate the targets YAML file."""
    try:
        data = yaml.safe_load(path.read_text())
    except FileNotFoundError as e:
        raise ConfigError(f"{path} not found") from e
    except yaml.YAMLError as e:
        raise ConfigError(f"{path} is not valid YAML: {e}") from e

    targets = (data or {}).get("targets")
    if not isinstance(targets, list) or not targets:
        raise ConfigError("config must contain a non-empty 'targets' list")

    for i, t in enumerate(targets, start=1):
        kind = t.get("type")
        if kind not in CHECKS:
            raise ConfigError(f"target #{i}: unknown type {kind!r} (use {sorted(CHECKS)})")
        missing = REQUIRED_KEYS[kind] - t.keys()
        if missing:
            raise ConfigError(f"target #{i} ({kind}): missing {sorted(missing)}")
        t.setdefault("name", f"{kind}-{i}")
    return targets


def run_check(target: dict, timeout: float) -> Result:
    start = time.perf_counter()
    ok, detail = CHECKS[target["type"]](target, timeout)
    duration = (time.perf_counter() - start) * 1000
    log.debug("%s -> ok=%s %s (%.0fms)", target["name"], ok, detail, duration)
    return Result(target["name"], target["type"], ok, detail, round(duration, 1))


def run_all(targets: list[dict], timeout: float, workers: int) -> list[Result]:
    with ThreadPoolExecutor(max_workers=workers) as pool:
        return list(pool.map(lambda t: run_check(t, timeout), targets))


def render_table(results: list[Result]) -> str:
    lines = [f"{'STATUS':<7}{'NAME':<20}{'TYPE':<6}{'TIME':>8}  DETAIL"]
    for r in results:
        status = "OK" if r.ok else "FAIL"
        lines.append(f"{status:<7}{r.name:<20}{r.kind:<6}{r.duration_ms:>6.0f}ms  {r.detail}")
    failed = sum(not r.ok for r in results)
    lines.append(f"\n{len(results) - failed}/{len(results)} checks passed")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("config", type=Path, help="YAML file with targets")
    parser.add_argument("--json", action="store_true", help="output JSON")
    parser.add_argument("--timeout", type=float, default=5.0, help="seconds per check (default 5)")
    parser.add_argument("--workers", type=int, default=8, help="parallel checks (default 8)")
    parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args(argv)

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.WARNING,
        format="%(asctime)s %(levelname)s %(message)s",
    )

    try:
        targets = load_targets(args.config)
    except ConfigError as e:
        log.error("%s", e)
        return 2

    results = run_all(targets, args.timeout, args.workers)
    if args.json:
        print(json.dumps([asdict(r) for r in results], indent=2))
    else:
        print(render_table(results))
    return 0 if all(r.ok for r in results) else 1


if __name__ == "__main__":
    sys.exit(main())
