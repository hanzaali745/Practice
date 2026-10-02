#!/usr/bin/env python3
line = "2024-05-01 12:00:01 ERROR db-01 Connection refused"

date, time, level, host, message = line.split(" ", 4)

if level in ("ERROR", "CRITICAL"):
    print(f"ALERT! {host} reported '{message}' on {date} at {time}")
else:
    print("info")
