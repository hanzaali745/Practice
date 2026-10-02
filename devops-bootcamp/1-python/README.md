# 🐍 Phase 1: Python for DevOps

> **Before you start:** finish [Step 0 — Ubuntu setup](../00-ubuntu-setup/README.md) and make sure your
> venv is active (`source ~/venvs/devops/bin/activate` — your prompt starts with `(devops)`).

> Python is the #1 language for DevOps automation. Ansible is written in Python.
> AWS CLI is written in Python. Most internal DevOps tools are Python.

## Modules

| # | Module | Level |
|---|--------|-------|
| 01 | [Getting Started](01-getting-started/README.md) | 🟢 Beginner |
| 02 | [Variables, Types & Operators](02-variables-and-types/README.md) | 🟢 Beginner |
| 03 | [Strings](03-strings/README.md) | 🟢 Beginner |
| 04 | [Control Flow](04-control-flow/README.md) | 🟢 Beginner |
| 05 | [Data Structures](05-data-structures/README.md) | 🟢 Beginner |
| 06 | [Functions](06-functions/README.md) | 🟡 Intermediate |
| 07 | [Files & Error Handling](07-files-and-errors/README.md) | 🟡 Intermediate |
| 08 | [Modules, venv & pip](08-modules-venv-pip/README.md) | 🟡 Intermediate |
| 09 | [Object-Oriented Python](09-oop/README.md) | 🟡 Intermediate |
| 10 | [System Automation](10-system-automation/README.md) | 🔴 Pro |
| 11 | [Data Formats & Regex](11-data-formats/README.md) | 🔴 Pro |
| 12 | [APIs & Cloud](12-apis-and-cloud/README.md) | 🔴 Pro |
| 13 | [Testing & Code Quality](13-testing-and-quality/README.md) | 🔴 Pro |
| 14 | [Capstone Projects](14-capstone/README.md) | 🏆 Capstone |

## How to run any solution

```bash
cd ~/Practice/devops-bootcamp/1-python/03-strings/solutions
python3 lab1_log_parser.py
```

## Python cheat sheet (keep this open)

```python
# Variables & types
name = "web-01"; port = 8080; cpu = 73.5; healthy = True; nothing = None

# Strings
f"{name}:{port}"   name.upper()   " x ".strip()   "a,b".split(",")   ",".join(lst)

# Collections
servers = ["web-01", "web-02"]          # list  (ordered, changeable)
point = (10, 20)                        # tuple (ordered, fixed)
config = {"env": "prod", "replicas": 3} # dict  (key → value)
ports = {80, 443}                       # set   (unique items)

# Control flow
if cpu > 90: ...
elif cpu > 70: ...
else: ...
for s in servers: ...
while retries < 3: ...

# Functions
def deploy(app: str, env: str = "dev") -> bool:
    return True

# Files & errors
with open("app.log") as f:
    for line in f: ...
try: ...
except FileNotFoundError as e: ...

# Run a shell command
import subprocess
subprocess.run(["ls", "-l"], check=True, capture_output=True, text=True)
```

## 🏅 Python expert checklist

You're "expert level" for DevOps when you can do all of these **without notes**:

- [ ] Choose the right data structure (list / dict / set / tuple / dataclass) and explain why
- [ ] Write small, typed functions with docstrings, and a `main()` with `if __name__ == "__main__":`
- [ ] Read huge log files line by line, and handle errors with specific exceptions
- [ ] Return correct exit codes and write errors to stderr
- [ ] Create a venv, pin dependencies in `requirements.txt`, and explain Ubuntu's `externally-managed-environment` error
- [ ] Run commands safely with `subprocess.run([...], check=True, timeout=...)` — and explain why not `shell=True`
- [ ] Build a CLI with `argparse` (subcommands, `--dry-run`, `-v`) and `logging`
- [ ] Load/transform JSON, YAML (`safe_load`!) and CSV; parse logs with named-group regex
- [ ] Call REST APIs with timeouts, retries, auth from env vars, and pagination
- [ ] Test with pytest (parametrize, fixtures, `tmp_path`, mocks) and run ruff + mypy + pytest in CI

👉 When you finish: [Phase 2 — Shell Scripting](../2-shell-scripting/README.md)
