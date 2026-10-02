# Python Module 04 — Control Flow 🟢

## 🎯 Objectives
- Make decisions with `if / elif / else`
- Loop with `for` and `while`
- Control loops with `break`, `continue`, `else`
- Use `range()`, `enumerate()`, and `match` (Python 3.10+)

## 🧠 Why DevOps engineers care
Automation = **decisions + repetition**. "If disk > 90%, alert." "For each server, deploy."
"While the service isn't healthy, retry." That's 80% of every DevOps script.

---

## 📖 Lesson 4.1 — Indentation matters
Python uses **indentation (4 spaces)** to define blocks — no `{ }` braces.

```python
if True:
    print("inside the block")    # indented = inside
print("outside the block")       # not indented = outside
```

## 📖 Lesson 4.2 — `if / elif / else`

```python
disk_usage = 87

if disk_usage >= 95:
    print("CRITICAL: disk almost full!")
elif disk_usage >= 80:
    print("WARNING: disk getting full")
else:
    print("OK")
```

Python checks top to bottom and runs **only the first** matching block.

**Truthy / falsy** — these count as `False`: `0`, `0.0`, `""`, `[]`, `{}`, `None`, `False`.

```python
error_message = ""
if not error_message:
    print("No errors")
```

**One-line (ternary):**
```python
status = "UP" if disk_usage < 95 else "DOWN"
```

## 📖 Lesson 4.3 — `for` loops

```python
servers = ["web-01", "web-02", "db-01"]
for server in servers:
    print(f"Pinging {server}...")

for char in "abc":            # strings are iterable
    print(char)

for i in range(5):            # 0,1,2,3,4
    print(i)

for i in range(1, 11, 2):     # 1,3,5,7,9  (start, stop, step)
    print(i)

for index, server in enumerate(servers, start=1):
    print(f"{index}. {server}")
```

## 📖 Lesson 4.4 — `while` loops (retry logic!)

```python
import time

attempt = 1
max_attempts = 5
while attempt <= max_attempts:
    print(f"Attempt {attempt}: checking service...")
    healthy = attempt == 3          # pretend it becomes healthy on try 3
    if healthy:
        print("Service is healthy ✅")
        break
    attempt += 1
    time.sleep(0.5)                  # wait before retrying
else:
    print("Service never became healthy ❌")   # runs only if loop didn't `break`
```

> ⚠️ Always make sure a `while` loop can end, or you get an infinite loop. `Ctrl+C` stops it.

## 📖 Lesson 4.5 — `break` and `continue`

```python
for line in ["INFO start", "DEBUG x", "ERROR boom", "INFO end"]:
    if line.startswith("DEBUG"):
        continue          # skip this one, go to next
    if line.startswith("ERROR"):
        print("Found error, stopping:", line)
        break             # exit the loop entirely
    print(line)
```

## 📖 Lesson 4.6 — Nested loops

```python
environments = ["dev", "staging", "prod"]
services = ["api", "web"]
for env in environments:
    for svc in services:
        print(f"deploy {svc} -> {env}")
```

## 📖 Lesson 4.7 — `match` statement (Python 3.10+)

Like a `case` statement in Bash — cleaner than many `elif`s:

```python
command = "restart"
match command:
    case "start":
        print("Starting...")
    case "stop":
        print("Stopping...")
    case "restart" | "reload":
        print("Restarting...")
    case _:
        print(f"Unknown command: {command}")
```

## ⚠️ Common mistakes
- Forgetting the colon `:` after `if`, `for`, `while`
- Wrong indentation → `IndentationError` or logic in the wrong block
- Infinite `while` loops (forgot to update the counter)
- Modifying a list while looping over it

---

## 🧪 Labs

### Lab 1 ⭐ — Disk alert
Ask the user for disk usage %. Print `OK` (<70), `WARNING` (70–89), `CRITICAL` (≥90).
Reject values outside 0–100 with `Invalid value`.

### Lab 2 ⭐ — Server loop
Given `servers = ["web-01", "web-02", "db-01", "cache-01"]`, print a numbered list,
and print `(database!)` next to any server starting with `db`.

### Lab 3 ⭐⭐ — Retry with backoff
Simulate connecting to a database. The connection succeeds on attempt 4.
Retry up to 5 times; wait `2 ** attempt * 0.1` seconds between attempts (exponential backoff).
Print each attempt and the total wait time.

### Lab 4 ⭐⭐ — Log filter
Given this list:
```python
logs = ["INFO boot ok", "WARN disk 81%", "ERROR db timeout", "INFO user login",
        "ERROR api 500", "DEBUG cache hit", "CRITICAL kernel panic"]
```
Count how many lines of each level (INFO/WARN/ERROR/CRITICAL/DEBUG) there are using
`if/elif` and counter variables. Stop processing immediately when you hit `CRITICAL`
and print `Escalating to on-call!`.

### Lab 5 ⭐⭐ — Service controller
Write a loop that keeps asking `Command (start/stop/status/quit):` and uses `match` to respond.
`quit` exits the loop. Unknown commands print a help message.

### Lab 6 ⭐⭐⭐ — FizzBuzz, DevOps edition
For numbers 1–30 (think: build numbers): print `Deploy` if divisible by 3,
`Test` if divisible by 5, `Deploy+Test` if divisible by both, otherwise the number.

---

## ✅ Checkpoint
- [ ] I can write `if/elif/else` and know only the first match runs
- [ ] I can loop with `for`, `range`, `enumerate`, `while`
- [ ] I know `break`, `continue`, and the loop `else`

👉 Next: [Module 05 — Data Structures](../05-data-structures/README.md)
