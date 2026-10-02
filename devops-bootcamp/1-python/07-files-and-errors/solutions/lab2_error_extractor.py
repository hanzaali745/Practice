#!/usr/bin/env python3
from pathlib import Path

LOG = Path(__file__).parent.parent / "data" / "app.log"
OUT = Path("errors.log")

written = 0
with open(LOG, encoding="utf-8") as src, open(OUT, "w", encoding="utf-8") as dst:
    for line in src:
        level = line.split()[2]
        if level in ("ERROR", "CRITICAL"):
            dst.write(line)
            written += 1

print(f"Wrote {written} lines to {OUT}")
