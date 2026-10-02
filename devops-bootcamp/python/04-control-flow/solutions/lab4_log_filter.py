#!/usr/bin/env python3
logs = ["INFO boot ok", "WARN disk 81%", "ERROR db timeout", "INFO user login",
        "ERROR api 500", "DEBUG cache hit", "CRITICAL kernel panic"]

info = warn = error = critical = debug = 0

for line in logs:
    level = line.split()[0]
    if level == "INFO":
        info += 1
    elif level == "WARN":
        warn += 1
    elif level == "ERROR":
        error += 1
    elif level == "DEBUG":
        debug += 1
    elif level == "CRITICAL":
        critical += 1
        print("Escalating to on-call!")
        break

print(f"INFO={info} WARN={warn} ERROR={error} DEBUG={debug} CRITICAL={critical}")
