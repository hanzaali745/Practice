#!/usr/bin/env python3
"""Lab 1 — generator pipeline over a huge log. Usage: log_pipeline.py [big.log]"""
import resource
import sys
from collections import Counter
from collections.abc import Iterable, Iterator


def read_lines(path: str) -> Iterator[str]:
    with open(path, encoding="utf-8") as f:
        yield from f


def only_level(lines: Iterable[str], *levels: str) -> Iterator[str]:
    wanted = {f" {lvl} " for lvl in levels}
    return (line for line in lines if any(w in line for w in wanted))


def parse(lines: Iterable[str]) -> Iterator[dict[str, str]]:
    for line in lines:
        date, time, level, host, message = line.rstrip("\n").split(" ", 4)
        yield {"ts": f"{date} {time}", "level": level, "host": host, "message": message}


def top_error_hosts(path: str, n: int = 5) -> list[tuple[str, int]]:
    records = parse(only_level(read_lines(path), "ERROR", "CRITICAL"))
    return Counter(r["host"] for r in records).most_common(n)


if __name__ == "__main__":
    log = sys.argv[1] if len(sys.argv) > 1 else "big.log"
    for host, count in top_error_hosts(log):
        print(f"{host:<10} {count}")
    peak_mb = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024  # Linux reports KB
    print(f"peak memory: {peak_mb:.1f} MB")
