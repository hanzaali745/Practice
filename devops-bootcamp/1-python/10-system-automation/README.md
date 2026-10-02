# Python Module 10 — System Automation 🔴

## 🎯 Objectives
- Work with paths and files using `pathlib`, `os` and `shutil`
- Read environment variables safely
- Run shell commands with `subprocess` (the right way)
- Build real CLI tools with `argparse`
- Log properly with `logging` instead of `print`

## 🧠 Why DevOps engineers care
This is where Python becomes a **DevOps superpower**. Cleaning old files, creating backups,
wrapping `kubectl`/`docker`/`git` commands, writing CLI tools for your team — this module
is what you'll use in your actual job.

---

## 📖 Lesson 10.1 — `pathlib` (modern paths)

```python
from pathlib import Path

home = Path.home()
logs = Path("/var/log")
config = Path("app") / "config" / "settings.yml"   # / joins paths (cross-platform!)

print(config.name)        # settings.yml
print(config.stem)        # settings
print(config.suffix)      # .yml
print(config.parent)      # app/config
print(config.exists(), config.is_file(), config.is_dir())

Path("backups/daily").mkdir(parents=True, exist_ok=True)   # like mkdir -p

p = Path("notes.txt")
p.write_text("hello\n")             # quick write
print(p.read_text())                # quick read

for f in Path(".").glob("*.py"):    # files matching pattern in this dir
    print(f)
for f in Path(".").rglob("*.log"):  # recursive
    print(f, f.stat().st_size, "bytes")
```

## 📖 Lesson 10.2 — `os` & environment variables

```python
import os

print(os.getcwd())
print(os.environ.get("HOME"))
db_host = os.environ.get("DB_HOST", "localhost")     # with default
port = int(os.getenv("APP_PORT", "8080"))            # env vars are always strings!

api_key = os.environ.get("API_KEY")
if not api_key:
    raise SystemExit("ERROR: API_KEY environment variable is required")
```

> 🔐 **Secrets come from environment variables or a secrets manager — never hard-coded in Git.**

## 📖 Lesson 10.3 — `shutil` (copy, move, archive, disk)

```python
import shutil

shutil.copy("app.conf", "app.conf.bak")          # copy file
shutil.copytree("src", "src_backup")             # copy directory
shutil.move("old.log", "archive/old.log")        # move/rename
shutil.rmtree("tmp_build")                       # rm -rf (careful!)
shutil.make_archive("backup-2024-05-01", "gztar", "data")   # → backup-2024-05-01.tar.gz

total, used, free = shutil.disk_usage("/")
print(f"Disk: {used / total:.0%} used")
print(shutil.which("docker"))                    # path to a command, or None
```

## 📖 Lesson 10.4 — `subprocess` (run shell commands)

```python
import subprocess

# ✅ The recommended way: a LIST of arguments, check=True, capture output as text
result = subprocess.run(
    ["df", "-h", "/"],
    capture_output=True,   # collect stdout/stderr
    text=True,             # str instead of bytes
    check=True,            # raise CalledProcessError if exit code != 0
    timeout=30,            # never hang forever
)
print(result.stdout)
print("exit code:", result.returncode)
```

Handling failures:

```python
try:
    subprocess.run(["ls", "/does-not-exist"], capture_output=True, text=True, check=True)
except subprocess.CalledProcessError as e:
    print(f"Command failed ({e.returncode}): {e.stderr.strip()}")
except FileNotFoundError:
    print("Command not installed")
except subprocess.TimeoutExpired:
    print("Command took too long")
```

> 🔐 **Security:** avoid `shell=True` with any user input — it allows **command injection**:
> `subprocess.run(f"ping {user_input}", shell=True)` with `user_input = "x; rm -rf /"` 💀.
> Use a list: `subprocess.run(["ping", "-c", "1", user_input])`.

## 📖 Lesson 10.5 — `argparse` (professional CLIs)

```python
#!/usr/bin/env python3
import argparse

parser = argparse.ArgumentParser(description="Deploy an application")
parser.add_argument("app", help="application name")                       # positional
parser.add_argument("-e", "--env", choices=["dev", "staging", "prod"], default="dev")
parser.add_argument("-r", "--replicas", type=int, default=1)
parser.add_argument("--dry-run", action="store_true", help="show what would happen")
parser.add_argument("-v", "--verbose", action="count", default=0)
args = parser.parse_args()

print(args.app, args.env, args.replicas, args.dry_run, args.verbose)
```

```bash
./deploy.py --help                        # free help text!
./deploy.py api -e prod -r 3 --dry-run -vv
```

## 📖 Lesson 10.6 — `logging` (stop using print!)

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)-8s %(name)s: %(message)s",
    handlers=[logging.StreamHandler(), logging.FileHandler("deploy.log")],
)
log = logging.getLogger("deployer")

log.debug("hidden unless level=DEBUG")
log.info("Starting deployment of %s", "api")       # lazy formatting
log.warning("Disk at %d%%", 85)
log.error("Health check failed")
try:
    1 / 0
except ZeroDivisionError:
    log.exception("Something crashed")              # logs the full traceback
```

Levels: `DEBUG < INFO < WARNING < ERROR < CRITICAL`. Tie `-v` to `DEBUG` in your CLIs.

## 📖 Lesson 10.7 — Time & dates

```python
from datetime import datetime, timedelta, timezone
import time

now = datetime.now(timezone.utc)
print(now.strftime("%Y-%m-%d_%H-%M-%S"))      # good for backup file names
week_ago = now - timedelta(days=7)
age_seconds = time.time() - Path("notes.txt").stat().st_mtime   # file age
```

## ⚠️ Common mistakes
- `shell=True` with untrusted input (injection)
- No `timeout` on `subprocess.run` → script hangs in CI forever
- Not checking return codes (`check=True`)
- Hard-coding `/home/me/...` paths — use `Path.home()`, args, or env vars
- `shutil.rmtree` on a path built from unvalidated input

---

## 🧪 Labs
> Work inside `my-work/` — some labs create/delete files!

### Lab 1 ⭐⭐ — Directory organiser
Write `organise.py <folder>` that moves files into sub-folders by extension
(`logs/`, `configs/` for .yml/.yaml/.conf/.ini, `scripts/` for .sh/.py, `other/`).
Support `--dry-run`.

### Lab 2 ⭐⭐ — Old file cleaner
Write `cleanup.py <folder> --days N [--dry-run] [--pattern "*.log"]` that deletes files older
than N days matching the pattern. Log each deletion and print total space freed.

### Lab 3 ⭐⭐ — System info via subprocess
Run `uname -a`, `uptime`, `df -h /`, `free -m` (skip any not installed using `shutil.which`)
and print each output under a heading. Handle failures gracefully.

### Lab 4 ⭐⭐⭐ — Backup tool
Write `backup.py SOURCE DEST [--keep 5] [-v]` that:
- creates `DEST/<source-name>-YYYYmmdd-HHMMSS.tar.gz`
- keeps only the newest `--keep` backups (deletes older ones)
- logs with `logging` (DEBUG when `-v`)
- exits `1` with a clear error if SOURCE doesn't exist

---

## ✅ Checkpoint
- [ ] I use `pathlib` for paths and `shutil` for copy/move/archive
- [ ] I run commands with a list of args, `check=True` and a `timeout`
- [ ] My CLIs use `argparse` and `logging`

👉 Next: [Module 11 — Data Formats & Regex](../11-data-formats/README.md)
