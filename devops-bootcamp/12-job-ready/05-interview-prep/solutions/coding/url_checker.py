"""url_checker.py URL... — check many URLs in parallel; print status and latency; exit 1 if any is unhealthy.

    python3 url_checker.py https://example.com http://localhost:8080/health --timeout 3
Healthy = HTTP 2xx/3xx within the timeout. Uses threads: the work is waiting on the network, not CPU.
"""
import argparse
import sys
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor


def check(url, timeout=5.0):
    start = time.monotonic()
    try:
        with urllib.request.urlopen(url, timeout=timeout) as resp:
            status = resp.status
    except urllib.error.HTTPError as e:          # 4xx/5xx still give us a status code
        status = e.code
    except (urllib.error.URLError, TimeoutError, OSError) as e:
        return {"url": url, "ok": False, "status": None, "ms": None, "error": str(getattr(e, "reason", e))}
    ms = round((time.monotonic() - start) * 1000)
    return {"url": url, "ok": 200 <= status < 400, "status": status, "ms": ms, "error": None}


def check_all(urls, timeout=5.0, workers=10):
    with ThreadPoolExecutor(max_workers=workers) as pool:
        return list(pool.map(lambda u: check(u, timeout), urls))   # keeps input order


def main(argv=None):
    p = argparse.ArgumentParser(description="check URLs in parallel")
    p.add_argument("urls", nargs="+")
    p.add_argument("--timeout", type=float, default=5.0)
    args = p.parse_args(argv)
    results = check_all(args.urls, args.timeout)
    for r in results:
        mark = "✅" if r["ok"] else "❌"
        detail = f'{r["status"]} {r["ms"]} ms' if r["status"] else r["error"]
        print(f'{mark} {r["url"]}  {detail}')
    return 0 if all(r["ok"] for r in results) else 1


if __name__ == "__main__":
    sys.exit(main())
