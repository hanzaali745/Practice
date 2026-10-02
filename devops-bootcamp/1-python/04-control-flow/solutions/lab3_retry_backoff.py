#!/usr/bin/env python3
import time

SUCCEEDS_ON = 4
MAX_ATTEMPTS = 5
total_wait = 0.0

for attempt in range(1, MAX_ATTEMPTS + 1):
    print(f"Attempt {attempt}: connecting to database...")
    if attempt == SUCCEEDS_ON:
        print("Connected ✅")
        break
    wait = 2 ** attempt * 0.1
    print(f"  failed, waiting {wait:.1f}s")
    time.sleep(wait)
    total_wait += wait
else:
    print("Giving up ❌")

print(f"Total time spent waiting: {total_wait:.1f}s")
