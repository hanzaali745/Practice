#!/usr/bin/env python3
from pathlib import Path

import yaml

DATA = Path(__file__).parent.parent / "data" / "deployment.yaml"

with open(DATA) as f:
    manifest = yaml.safe_load(f)

name = manifest["metadata"]["name"]
problems = []

for c in manifest["spec"]["template"]["spec"]["containers"]:
    image = c["image"]
    last_part = image.rsplit("/", 1)[-1]
    if ":" not in last_part or image.endswith(":latest"):
        problems.append(f"container '{c['name']}' uses an unpinned image: {image}")
    if not c.get("resources", {}).get("limits"):
        problems.append(f"container '{c['name']}' has no resource limits")

if manifest["spec"].get("replicas", 1) < 3:
    problems.append(f"replicas={manifest['spec'].get('replicas', 1)} (recommend >= 3 for prod)")

print(f"Audit of deployment '{name}':")
for p in problems or ["no problems found ✅"]:
    print(" -", p)

manifest["spec"]["replicas"] = 3
with open("deployment-fixed.yaml", "w") as f:
    yaml.safe_dump(manifest, f, sort_keys=False)
print("Wrote deployment-fixed.yaml")
