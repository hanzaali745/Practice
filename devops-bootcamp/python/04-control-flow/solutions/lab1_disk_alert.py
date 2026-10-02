#!/usr/bin/env python3
usage = float(input("Disk usage %: "))

if usage < 0 or usage > 100:
    print("Invalid value")
elif usage >= 90:
    print("CRITICAL")
elif usage >= 70:
    print("WARNING")
else:
    print("OK")
