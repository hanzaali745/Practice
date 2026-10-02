# Python Module 08 — Modules, Packages, venv & pip 🟡

## 🎯 Objectives
- Import from the standard library and your own files
- Build a small **package** (folder with `__init__.py`)
- Create isolated **virtual environments** with `venv`
- Install and pin dependencies with `pip` and `requirements.txt`

## 🧠 Why DevOps engineers care
"Works on my laptop, breaks on the server" is usually a **dependency** problem.
Virtual environments + pinned `requirements.txt` make Python apps reproducible —
exactly what you need for Docker images and CI pipelines.

---

## 📖 Lesson 8.1 — Importing

```python
import os                          # whole module
import datetime as dt              # alias
from pathlib import Path           # one name
from math import ceil, floor       # several names

print(os.getcwd())
print(dt.datetime.now().isoformat())
print(Path.home())
print(ceil(4.1))
```

> ❌ Avoid `from module import *` — you can't tell where names come from.

### Standard library highlights for DevOps (no install needed!)

| Module | Use |
|--------|-----|
| `os`, `pathlib`, `shutil` | files, dirs, env vars |
| `subprocess` | run shell commands |
| `sys` | argv, exit codes, stdin/stdout |
| `argparse` | CLI arguments |
| `logging` | proper logs |
| `json`, `csv` | data formats |
| `re` | regular expressions |
| `datetime`, `time` | timestamps, sleep |
| `socket` | network checks |
| `urllib` | HTTP without extra libs |
| `hashlib` | checksums (sha256) |
| `tarfile`, `zipfile` | archives/backups |

## 📖 Lesson 8.2 — Your own modules

```
myproject/
├── utils.py
└── main.py
```

`utils.py`:
```python
def to_gb(mb: float) -> float:
    return mb / 1024
```

`main.py`:
```python
from utils import to_gb
print(to_gb(2048))
```

Remember the `if __name__ == "__main__":` guard from Module 06? Code under it **won't run**
when `utils.py` is imported. That's why we always use it.

## 📖 Lesson 8.3 — Packages

A package is a folder of modules with an `__init__.py` file:

```
devopskit/
├── __init__.py        # makes it a package (can be empty)
├── convert.py
└── checks.py
```

```python
from devopskit.convert import bytes_to_human
from devopskit import checks
checks.is_port_open("localhost", 22)
```

See the working example in [`solutions/`](solutions/).

## 📖 Lesson 8.4 — Virtual environments (venv)

A venv is an **isolated folder** with its own Python + packages, per project.

```bash
cd myproject
python3 -m venv .venv              # create
source .venv/bin/activate          # activate — your prompt now starts with (.venv)
which python                        # → myproject/.venv/bin/python
pip install requests                # installs ONLY into this venv
deactivate                          # leave
```

### 🐧 Why Ubuntu forces you to use a venv

On Ubuntu 23.04+ (including 24.04), installing outside a venv fails on purpose:

```text
$ pip install requests
error: externally-managed-environment
× This environment is externally managed
```

Ubuntu's own tools (like `apt`) are written in Python. If `pip` changed the system's packages,
it could break your operating system. So Ubuntu says: **use a venv** (or `sudo apt install python3-<name>`
for the few libraries Ubuntu packages).

> ❌ Don't "fix" it with `pip install --break-system-packages`. Use a venv — that's what professionals do.
> In Step 0 you created one venv for the whole course at `~/venvs/devops`. For your own real
> projects, create one venv per project as shown above.

> Add `.venv/` to `.gitignore` — never commit it.

## 📖 Lesson 8.5 — pip & requirements.txt

```bash
pip install requests==2.32.3        # specific version
pip install "pyyaml>=6,<7"          # version range
pip list                            # what's installed
pip show requests                   # details
pip freeze > requirements.txt       # snapshot exact versions
pip install -r requirements.txt     # reproduce on another machine / in Docker
pip uninstall requests
```

Example `requirements.txt`:
```
requests==2.32.3
PyYAML==6.0.2
boto3==1.35.0
```

How this looks in a real Dockerfile:
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "main.py"]
```

> 💡 Modern alternatives you'll meet: `pipx` (install CLI tools), `poetry` / `uv` (project managers),
> `pyproject.toml` (modern project config). Learn venv+pip first — they're always there.

## ⚠️ Common mistakes
- `sudo pip install` into the system Python → can break your OS tools. Use a venv
- Naming your file `requests.py` or `json.py` → shadows the real module!
- Forgetting to activate the venv (`which python` to check)
- Not pinning versions → builds break randomly months later

---

## 🧪 Labs

### Lab 1 ⭐ — Stdlib tour
Write a script using `os`, `platform`, `datetime`, `socket` that prints:
current user, hostname, OS, Python version, current time in ISO format, and your home dir.

### Lab 2 ⭐⭐ — Build a package
Create a package `devopskit/` with:
- `convert.py` → `bytes_to_human()` (from Module 06)
- `checks.py` → `is_port_open(host, port, timeout=1)` using `socket`
- `__init__.py` exposing a `__version__ = "0.1.0"`

Then write `main.py` that imports and uses both.

### Lab 3 ⭐⭐ — venv workflow
1. Create a venv in your `my-work` folder and activate it
2. Install `requests` and `pyyaml`
3. `pip freeze > requirements.txt`
4. Delete the venv, recreate it, and reinstall from `requirements.txt`
5. Write `check_deps.py` that imports both and prints their `__version__`

### Lab 4 ⭐⭐⭐ — Dockerise it (optional, if you have Docker)
Write a `Dockerfile` for your Lab 2 package that installs `requirements.txt` and runs `main.py`.
Build and run it: `docker build -t devopskit . && docker run --rm devopskit`.

---

## ✅ Checkpoint
- [ ] I can import stdlib modules and my own modules
- [ ] I know what `__init__.py` does
- [ ] I create a venv for every project and pin dependencies

👉 Next: [Module 09 — Object-Oriented Python](../09-oop/README.md)
