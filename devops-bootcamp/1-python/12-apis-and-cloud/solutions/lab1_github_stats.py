#!/usr/bin/env python3
"""Show stats for a GitHub repo. Usage: lab1_github_stats.py owner/repo"""
import sys

import requests


def main() -> int:
    repo = sys.argv[1] if len(sys.argv) > 1 else input("owner/repo: ").strip()
    try:
        r = requests.get(f"https://api.github.com/repos/{repo}", timeout=10)
    except requests.exceptions.RequestException as e:
        print(f"ERROR: could not reach GitHub: {e}", file=sys.stderr)
        return 1

    if r.status_code == 404:
        print(f"Repository '{repo}' not found", file=sys.stderr)
        return 1
    if r.status_code == 403:
        print("Forbidden or rate limited (60 req/hour without a token). Try again later.", file=sys.stderr)
        return 1
    if not r.ok:
        print(f"ERROR: GitHub returned HTTP {r.status_code}", file=sys.stderr)
        return 1
    data = r.json()

    print(f"Repository:   {data['full_name']}")
    print(f"Stars:        {data['stargazers_count']:,}")
    print(f"Forks:        {data['forks_count']:,}")
    print(f"Open issues:  {data['open_issues_count']:,}")
    print(f"Branch:       {data['default_branch']}")
    print(f"Last push:    {data['pushed_at']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
