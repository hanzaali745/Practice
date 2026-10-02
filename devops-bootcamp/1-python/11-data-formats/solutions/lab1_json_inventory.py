#!/usr/bin/env python3
import json
from pathlib import Path

DATA = Path(__file__).parent.parent / "data" / "servers.json"

with open(DATA) as f:
    inventory = json.load(f)

prod = [s for s in inventory["servers"] if s["env"] == "prod"]
for s in prod:
    if s["cpu"] > 80:
        print(f"HIGH CPU: {s['name']} ({s['ip']}) {s['cpu']}%")

with open("prod_servers.json", "w") as f:
    json.dump({"servers": prod}, f, indent=2)
print(f"Wrote {len(prod)} prod servers to prod_servers.json")
