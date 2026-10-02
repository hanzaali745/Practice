#!/usr/bin/env python3
import math

CAPACITY_PER_SERVER = 250  # requests/second

peak = int(input("Expected peak requests/second: "))
needed = math.ceil(peak / CAPACITY_PER_SERVER)
total = needed + 1  # N+1 redundancy
print(f"Servers needed: {needed}, with N+1 redundancy: {total}")
