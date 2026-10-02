#!/usr/bin/env python3
import csv
import json
from pathlib import Path

DATA = Path(__file__).parent.parent / "data" / "users.csv"

by_team: dict[str, list[dict]] = {}
with open(DATA, newline="") as f:
    for row in csv.DictReader(f):
        row["sudo"] = row["sudo"].strip().lower() == "yes"
        team = row.pop("team")
        by_team.setdefault(team, []).append(row)

print(json.dumps(by_team, indent=2))
