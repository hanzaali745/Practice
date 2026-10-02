#!/usr/bin/env python3
"""Create a big fake log for Lab 1. Usage: make_big_log.py [lines] [path]"""
import random
import sys
from datetime import datetime, timedelta

lines = int(sys.argv[1]) if len(sys.argv) > 1 else 500_000
path = sys.argv[2] if len(sys.argv) > 2 else "big.log"

random.seed(42)  # same "random" file every time → reproducible results
hosts = [f"web-{n:02d}" for n in range(1, 21)] + ["db-01", "db-02", "cache-01"]
levels = ["INFO"] * 80 + ["WARN"] * 12 + ["ERROR"] * 7 + ["CRITICAL"]
messages = ["request served", "slow query", "connection refused", "timeout", "cache miss"]
t = datetime(2024, 5, 1)

with open(path, "w", encoding="utf-8") as f:
    for _ in range(lines):
        t += timedelta(milliseconds=random.randint(1, 500))
        f.write(f"{t:%Y-%m-%d %H:%M:%S} {random.choice(levels)} {random.choice(hosts)} {random.choice(messages)}\n")

print(f"wrote {lines:,} lines to {path}")
