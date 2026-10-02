#!/usr/bin/env python3
import csv
import re
from collections import Counter
from pathlib import Path

DATA = Path(__file__).parent.parent / "data" / "access.log"

LOG_RE = re.compile(
    r'(?P<ip>\S+) \S+ \S+ \[(?P<time>[^\]]+)\] "(?P<method>\w+) (?P<path>\S+) [^"]+" '
    r"(?P<status>\d{3}) (?P<size>\d+)"
)

statuses: Counter[str] = Counter()
ips: Counter[str] = Counter()
failed_logins: Counter[str] = Counter()
server_errors = []

with open(DATA) as f:
    for line in f:
        m = LOG_RE.match(line)
        if not m:
            continue
        entry = m.groupdict()
        statuses[entry["status"]] += 1
        ips[entry["ip"]] += 1
        if entry["status"] == "401":
            failed_logins[entry["ip"]] += 1
        if entry["status"].startswith("5"):
            server_errors.append(entry)

print("Requests per status:", dict(sorted(statuses.items())))
print("Top IPs:", ips.most_common(3))
for ip, count in failed_logins.items():
    if count >= 3:
        print(f"🚨 Possible brute force from {ip}: {count} failed logins")

with open("server_errors.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["ip", "time", "method", "path", "status", "size"])
    writer.writeheader()
    writer.writerows(server_errors)
print(f"Wrote {len(server_errors)} 5xx errors to server_errors.csv")
