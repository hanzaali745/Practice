"""top_ips.py [LOG] [-n N] — the busiest client IPs and the status-code mix of an nginx/Apache access log.

    python3 top_ips.py /var/log/nginx/access.log -n 5
    cat access.log | python3 top_ips.py
Lines that don't parse are counted, not fatal (real logs are messy).
"""
import argparse
import re
import sys
from collections import Counter

# 1.2.3.4 - - [12/Mar/2026:13:55:36 +0000] "GET /path HTTP/1.1" 200 512 "-" "curl/8.5"
LINE = re.compile(r'^(?P<ip>\S+) \S+ \S+ \[[^\]]+\] "[^"]*" (?P<status>\d{3}) ')


def analyse(lines, n=10):
    ips, statuses, bad = Counter(), Counter(), 0
    for line in lines:
        m = LINE.match(line)
        if not m:
            bad += 1
            continue
        ips[m["ip"]] += 1
        statuses[m["status"][0] + "xx"] += 1
    return ips.most_common(n), dict(sorted(statuses.items())), bad


def main(argv=None):
    p = argparse.ArgumentParser(description="top client IPs in an access log")
    p.add_argument("log", nargs="?", help="log file (default: stdin)")
    p.add_argument("-n", type=int, default=10)
    args = p.parse_args(argv)
    with (open(args.log, encoding="utf-8", errors="replace") if args.log else sys.stdin) as f:
        top, statuses, bad = analyse(f, args.n)
    for ip, count in top:
        print(f"{count:8d}  {ip}")
    print("status:", "  ".join(f"{k}={v}" for k, v in statuses.items()), f"  unparsed={bad}")


if __name__ == "__main__":
    main()
