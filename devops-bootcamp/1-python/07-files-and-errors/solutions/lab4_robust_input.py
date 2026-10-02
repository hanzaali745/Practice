#!/usr/bin/env python3
while True:
    raw = input("Port (1-65535): ")
    try:
        port = int(raw)
    except ValueError:
        print(f"'{raw}' is not a number, try again")
        continue
    if 1 <= port <= 65535:
        break
    print("Out of range, try again")

print("Using port", port)
