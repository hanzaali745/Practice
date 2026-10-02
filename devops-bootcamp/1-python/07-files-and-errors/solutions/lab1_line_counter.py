#!/usr/bin/env python3
from pathlib import Path

LOG = Path(__file__).parent.parent / "data" / "app.log"

with open(LOG, encoding="utf-8") as f:
    lines = [line.rstrip("\n") for line in f]

print("Lines:", len(lines))
print("First:", lines[0])
print("Last: ", lines[-1])
