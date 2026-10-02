#!/usr/bin/env python3
"""Check URLs and exit 1 if any are down. Usage: healthcheck.py URL [URL...] [--timeout 5]"""
import argparse
import sys
import time

import requests


def check(url: str, timeout: float) -> tuple[bool, str]:
    start = time.perf_counter()
    try:
        r = requests.get(url, timeout=timeout)
    except requests.exceptions.RequestException as e:
        return False, f"ERROR {type(e).__name__}"
    elapsed_ms = (time.perf_counter() - start) * 1000
    ok = r.status_code < 400
    return ok, f"{r.status_code} in {elapsed_ms:.0f}ms"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("urls", nargs="+")
    parser.add_argument("--timeout", type=float, default=5)
    args = parser.parse_args()

    down = 0
    for url in args.urls:
        ok, detail = check(url, args.timeout)
        print(f"{'UP  ' if ok else 'DOWN'}  {url:<45} {detail}")
        down += not ok
    print(f"\n{len(args.urls) - down} up, {down} down")
    return 1 if down else 0


if __name__ == "__main__":
    sys.exit(main())
