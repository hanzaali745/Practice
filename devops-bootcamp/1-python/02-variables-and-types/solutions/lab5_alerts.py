#!/usr/bin/env python3
cpu, mem, disk = 88, 91, 70

print("Any above 90:", cpu > 90 or mem > 90 or disk > 90)   # True
print("All above 60:", cpu > 60 and mem > 60 and disk > 60)  # True
print("CPU 80-90:", 80 <= cpu <= 90)                        # True
