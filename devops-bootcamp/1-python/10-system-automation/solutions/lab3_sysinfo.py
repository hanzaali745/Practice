#!/usr/bin/env python3
"""Print basic system info by running common Linux commands."""
import shutil
import subprocess

COMMANDS = [
    ["uname", "-a"],
    ["uptime"],
    ["df", "-h", "/"],
    ["free", "-m"],
]

for cmd in COMMANDS:
    print(f"===== {' '.join(cmd)} =====")
    if shutil.which(cmd[0]) is None:
        print(f"(skipped: {cmd[0]} not installed)\n")
        continue
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True, timeout=10)
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"(failed with exit code {e.returncode}: {e.stderr.strip()})\n")
    except subprocess.TimeoutExpired:
        print("(timed out)\n")
