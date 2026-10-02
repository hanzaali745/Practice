#!/usr/bin/env python3
logs = ["INFO start", "ERROR db", "WARN slow", "INFO ok", "ERROR api", "ERROR db", "INFO done"]

counts = {}
for line in logs:
    level = line.split()[0]
    counts[level] = counts.get(level, 0) + 1

for level, count in sorted(counts.items(), key=lambda item: item[1], reverse=True):
    print(f"{level:<6} {count}")
