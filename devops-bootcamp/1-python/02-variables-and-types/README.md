# Python Module 02 — Variables, Types & Operators 🟢

## 🎯 Objectives
- Create variables and follow naming rules
- Know the core types: `int`, `float`, `str`, `bool`, `None`
- Convert between types (`int()`, `str()`, `float()`)
- Use arithmetic, comparison and logical operators
- Read user input with `input()`

## 🧠 Why DevOps engineers care
Configs are full of values: ports (int), CPU thresholds (float), hostnames (str),
feature flags (bool). Getting types wrong is the #1 cause of "it worked on my machine" bugs —
e.g. an env var `PORT="8080"` is a **string**, not a number!

---

## 📖 Lesson 2.1 — Variables

A variable is a **label** pointing to a value.

```python
hostname = "web-01"
port = 8080
cpu_threshold = 85.5
is_production = True
last_error = None          # "no value yet"

print(hostname, port, cpu_threshold, is_production, last_error)
```

**Naming rules & style (PEP 8):**
- Use `snake_case`: `max_retries`, not `MaxRetries` or `maxretries`
- Can't start with a number: `1server` ❌ → `server1` ✅
- Case sensitive: `Port` and `port` are different
- Constants in CAPS by convention: `MAX_RETRIES = 3`

## 📖 Lesson 2.2 — Core types

```python
print(type(8080))       # <class 'int'>     whole numbers
print(type(85.5))       # <class 'float'>   decimals
print(type("web-01"))   # <class 'str'>     text
print(type(True))       # <class 'bool'>    True / False
print(type(None))       # <class 'NoneType'> nothing
```

## 📖 Lesson 2.3 — Type conversion (casting)

```python
port_str = "8080"              # e.g. from an environment variable or input()
port = int(port_str)           # now a real number
print(port + 1)                # 8081

print(str(443) + "/tcp")       # "443/tcp"
print(float("99.9"))           # 99.9
print(int(7.9))                # 7  (truncates, doesn't round!)
print(round(7.9))              # 8
print(bool(0), bool(1), bool(""), bool("x"))   # False True False True
```

> ⚠️ `int("abc")` → `ValueError`. We'll learn to handle that in Module 07.

## 📖 Lesson 2.4 — Arithmetic operators

| Op | Meaning | Example | Result |
|----|---------|---------|--------|
| `+` | add | `5 + 2` | `7` |
| `-` | subtract | `5 - 2` | `3` |
| `*` | multiply | `5 * 2` | `10` |
| `/` | divide (always float) | `5 / 2` | `2.5` |
| `//` | floor divide | `5 // 2` | `2` |
| `%` | remainder (modulo) | `5 % 2` | `1` |
| `**` | power | `2 ** 10` | `1024` |

DevOps example — convert seconds to `h:m:s`:

```python
uptime_seconds = 93784
hours = uptime_seconds // 3600
minutes = (uptime_seconds % 3600) // 60
seconds = uptime_seconds % 60
print(hours, "h", minutes, "m", seconds, "s")   # 26 h 3 m 4 s
```

Shortcut assignment: `count += 1` is the same as `count = count + 1` (also `-=`, `*=`, `/=`).

## 📖 Lesson 2.5 — Comparison & logical operators

```python
cpu = 92
mem = 60

print(cpu > 90)                 # True
print(cpu == 92)                # True   (== compares, = assigns!)
print(cpu != 100)               # True
print(cpu > 90 and mem > 90)    # False  (both must be True)
print(cpu > 90 or mem > 90)     # True   (at least one True)
print(not True)                 # False
print(70 <= cpu <= 95)          # True   (chained comparison)
```

## 📖 Lesson 2.6 — User input

`input()` **always returns a string**.

```python
name = input("Server name: ")
cores = int(input("CPU cores: "))      # convert!
print("Server", name, "has", cores * 2, "vCPUs with hyperthreading")
```

## 📖 Lesson 2.7 — f-strings (sneak peek)

The modern way to put variables in text:

```python
host = "db-01"
disk = 81.456
print(f"{host} disk usage: {disk:.1f}%")    # db-01 disk usage: 81.5%
```

## ⚠️ Common mistakes
- `"5" + 5` → `TypeError`. Convert first: `int("5") + 5`
- Using `=` when you meant `==`
- Forgetting `input()` returns a string
- Expecting `/` to give an int — it gives a float; use `//` for whole numbers

---

## 🧪 Labs

### Lab 1 ⭐ — Server profile
Create variables for a server: hostname, IP, CPU cores, RAM in GB, is_production.
Print each with its `type()`.

### Lab 2 ⭐ — Storage converter
Ask the user for a size in **MB** and print it in **GB** and **TB** (1024 based), 2 decimals.

### Lab 3 ⭐⭐ — Uptime formatter
Ask for uptime in seconds and print it as `X days, Y hours, Z minutes, W seconds`.
Test with `200000` → `2 days, 7 hours, 33 minutes, 20 seconds`.

### Lab 4 ⭐⭐ — Capacity planner
A web server handles **250 requests/second**. Ask the user for expected peak traffic
(requests/second). Print how many servers are needed (round **up**!) and add 1 extra
for redundancy (N+1). Hint: `-(-a // b)` rounds up, or `import math; math.ceil()`.

### Lab 5 ⭐⭐ — Alert logic
Given `cpu = 88`, `mem = 91`, `disk = 70`, print `True/False` for:
1. Any metric above 90?
2. All metrics above 60?
3. CPU between 80 and 90 inclusive?

---

## ✅ Checkpoint
- [ ] I know the 5 core types and how to convert between them
- [ ] I know the difference between `/` and `//`, and `=` vs `==`
- [ ] I always convert `input()` before doing maths

👉 Next: [Module 03 — Strings](../03-strings/README.md)
