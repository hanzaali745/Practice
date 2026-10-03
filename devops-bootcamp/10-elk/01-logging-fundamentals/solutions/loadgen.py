"""loadgen.py — steady, realistic-looking traffic for demo-app (standard library only).

~85% GET /, 5% /error, 10% /work with a random duration — so rates, error ratios and latency percentiles
have something interesting to show.
Usage: python3 loadgen.py http://app:8000 [requests_per_second] [error_fraction]
       (error_fraction 0.05 = 5% of requests go to /error; raise it to make error alerts fire)
"""
import random
import sys
import time
import urllib.error
import urllib.request

base = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8000"
rps = float(sys.argv[2]) if len(sys.argv) > 2 else 10.0
error_fraction = float(sys.argv[3]) if len(sys.argv) > 3 else 0.05

while True:
    roll = random.random()
    if roll < error_fraction:
        path = "/error"
    elif roll < error_fraction + 0.10:
        path = f"/work?ms={random.choice([20, 50, 120, 300, 700])}"
    else:
        path = "/"
    try:
        urllib.request.urlopen(base + path, timeout=5).read()
    except (urllib.error.URLError, OSError):
        pass                                  # errors are part of the traffic we want to see
    time.sleep(random.expovariate(rps))      # random gaps, average 1/rps seconds
