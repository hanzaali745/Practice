#!/usr/bin/env python3
"""Summarise a log file. Exit 1 if missing, 2 if CRITICAL lines are found."""
import sys


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <logfile>", file=sys.stderr)
        return 1
    path = sys.argv[1]

    levels: dict[str, int] = {}
    errors_per_host: dict[str, int] = {}
    error_messages: dict[str, int] = {}

    try:
        with open(path, encoding="utf-8") as f:
            for line in f:
                parts = line.rstrip("\n").split(" ", 4)
                if len(parts) < 5:
                    continue  # skip malformed lines
                _date, _time, level, host, message = parts
                levels[level] = levels.get(level, 0) + 1
                if level in ("ERROR", "CRITICAL"):
                    errors_per_host[host] = errors_per_host.get(host, 0) + 1
                    error_messages[message] = error_messages.get(message, 0) + 1
    except FileNotFoundError:
        print(f"ERROR: {path} does not exist", file=sys.stderr)
        return 1

    print("== Levels ==")
    for level, count in sorted(levels.items()):
        print(f"  {level:<9}{count}")
    print("== Errors per host ==")
    for host, count in sorted(errors_per_host.items(), key=lambda kv: -kv[1]):
        print(f"  {host:<9}{count}")
    if error_messages:
        top = max(error_messages, key=error_messages.get)
        print(f"== Most frequent error ==\n  {top} ({error_messages[top]}x)")

    return 2 if levels.get("CRITICAL") else 0


if __name__ == "__main__":
    sys.exit(main())
