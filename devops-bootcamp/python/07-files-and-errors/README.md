# Module 07 — Files & Error Handling 🟡

## 🎯 Objectives
- Read and write text files safely with `with open(...)`
- Process large log files line by line
- Handle errors with `try / except / else / finally`
- Raise your own exceptions
- Exit scripts with proper exit codes (`sys.exit`)

## 🧠 Why DevOps engineers care
Reading logs, writing reports, editing configs — all file work. And in production
**things fail**: the file isn't there, the disk is full, the network drops. A senior
engineer's script fails **gracefully** with a clear message and a non-zero exit code
so the CI pipeline / cron / monitoring knows something broke.

---

## 📖 Lesson 7.1 — Reading files

```python
# Always use `with` — it closes the file automatically, even if an error happens
with open("data/app.log") as f:
    content = f.read()          # whole file as one string (small files only)

with open("data/app.log") as f:
    lines = f.readlines()       # list of lines (with \n)

with open("data/app.log") as f:
    for line in f:              # ✅ BEST for big logs: one line at a time, low memory
        print(line.rstrip())    # rstrip() removes the trailing newline
```

## 📖 Lesson 7.2 — Writing files

| Mode | Meaning |
|------|---------|
| `"r"` | read (default) |
| `"w"` | write — **overwrites** the file! |
| `"a"` | append to the end |
| `"x"` | create, fail if exists |
| `"rb"`/`"wb"` | binary (images, archives) |

```python
with open("report.txt", "w") as f:
    f.write("Daily report\n")
    f.write("All systems OK\n")

with open("report.txt", "a") as f:
    print("Appended line", file=f)    # print() can write to files too

servers = ["web-01", "web-02"]
with open("hosts.txt", "w") as f:
    f.writelines(f"{s}\n" for s in servers)
```

> 💡 Use `encoding="utf-8"` for portability: `open(path, encoding="utf-8")`.

## 📖 Lesson 7.3 — Exceptions: `try / except`

```python
try:
    with open("/etc/missing.conf") as f:
        data = f.read()
except FileNotFoundError:
    print("Config file not found, using defaults")
    data = ""
except PermissionError:
    print("No permission to read config")
    data = ""
```

Full structure:

```python
try:
    port = int(input("Port: "))          # code that might fail
except ValueError as e:
    print(f"Not a number: {e}")           # runs if that error happens
else:
    print(f"Using port {port}")           # runs if NO error
finally:
    print("Done validating")              # ALWAYS runs (cleanup)
```

Common exceptions:

| Exception | When |
|-----------|------|
| `FileNotFoundError` | file/dir doesn't exist |
| `PermissionError` | no access |
| `ValueError` | right type, bad value (`int("abc")`) |
| `TypeError` | wrong type (`"a" + 1`) |
| `KeyError` | missing dict key |
| `IndexError` | list index out of range |
| `ZeroDivisionError` | divide by 0 |
| `TimeoutError` / `ConnectionError` | network problems |

> ⚠️ **Never** write a bare `except:` or `except Exception: pass`. You'll hide real bugs.
> Catch the **specific** errors you expect.

## 📖 Lesson 7.4 — Raising exceptions

```python
def set_replicas(n: int) -> int:
    if n < 1:
        raise ValueError(f"replicas must be >= 1, got {n}")
    return n

try:
    set_replicas(0)
except ValueError as e:
    print("Error:", e)
```

Custom exceptions for your tools:

```python
class DeploymentError(Exception):
    """Raised when a deployment fails."""

raise DeploymentError("health check failed after deploy")
```

## 📖 Lesson 7.5 — Exit codes (talk to Linux/CI!)

Every program returns an **exit code**: `0` = success, anything else = failure.
CI pipelines, cron, Bash `&&` and `set -e` all depend on this.

```python
import sys

def main() -> int:
    try:
        with open("config.yml") as f:
            f.read()
    except FileNotFoundError:
        print("ERROR: config.yml missing", file=sys.stderr)   # errors go to stderr
        return 1
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

```bash
python3 script.py; echo "exit code: $?"
```

## 📖 Lesson 7.6 — Processing a log file (putting it together)

```python
error_count = 0
with open("data/app.log", encoding="utf-8") as f:
    for line_no, line in enumerate(f, start=1):
        if " ERROR " in line:
            error_count += 1
            print(f"line {line_no}: {line.rstrip()}")
print(f"Total errors: {error_count}")
```

## ⚠️ Common mistakes
- Opening with `"w"` when you meant `"a"` — you just wiped the file
- `f.read()` on a 10 GB log → out of memory. Iterate line by line
- Swallowing exceptions silently
- Printing errors to stdout instead of `sys.stderr`, and exiting with `0` after a failure

---

## 🧪 Labs
Use the sample log at [`data/app.log`](data/app.log).

### Lab 1 ⭐ — Line counter
Print the number of lines, and the first and last line of `data/app.log`.

### Lab 2 ⭐⭐ — Error extractor
Read `data/app.log`, write every `ERROR` and `CRITICAL` line to `errors.log`, and print
how many were written.

### Lab 3 ⭐⭐ — Safe config reader
Write `read_config(path)` that reads `key=value` lines into a dict, ignoring blank lines
and `#` comments. If the file is missing, print a warning to stderr and return `{}`.
Lines without `=` should raise `ValueError` with the line number.

### Lab 4 ⭐⭐ — Robust input
Keep asking for a port number until the user enters a valid int between 1 and 65535.
Handle `ValueError` properly.

### Lab 5 ⭐⭐⭐ — Log summary report
Create `log_report.py` that takes the log path from `sys.argv[1]` and prints:
- count per level
- count of ERROR+CRITICAL per host
- the most frequent error message
Exit with code `1` (and a message on stderr) if the file doesn't exist,
and code `2` if any CRITICAL lines were found (so a monitoring system can alert!).

```bash
python3 solutions/lab5_log_report.py data/app.log; echo "exit=$?"
```

---

## ✅ Checkpoint
- [ ] I always use `with open(...)` and iterate big files line by line
- [ ] I catch specific exceptions, never a bare `except:`
- [ ] My scripts write errors to stderr and exit non-zero on failure

👉 Next: [Module 08 — Modules, venv & pip](../08-modules-venv-pip/README.md)
