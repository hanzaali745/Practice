# Python Module 03 — Strings 🟢

## 🎯 Objectives
- Create strings, use escape characters and multi-line strings
- Index and slice strings
- Use the most important string methods
- Format output with f-strings like a pro

## 🧠 Why DevOps engineers care
Logs, command output, config files, hostnames, URLs, image tags — **everything is text**.
Parsing a log line like `2024-05-01 12:00:01 ERROR db-01 Connection refused` is a daily task.

---

## 📖 Lesson 3.1 — Creating strings

```python
a = 'single quotes'
b = "double quotes"            # same thing — pick one style and be consistent
c = "It's fine"                # mix to include the other quote
d = """Multi-line
string — great for
templates and help text"""

path = "C:\\Users\\admin"       # \\ = a literal backslash
print("Line1\nLine2\tTabbed")   # \n newline, \t tab
raw = r"C:\new\folder"          # raw string: backslashes are literal (great for regex!)
```

## 📖 Lesson 3.2 — Indexing & slicing

```
 string:  w  e  b  -  0  1
 index:   0  1  2  3  4  5
 negative:-6 -5 -4 -3 -2 -1
```

```python
host = "web-01"
print(host[0])      # w
print(host[-1])     # 1   (last char)
print(host[0:3])    # web (start inclusive, end exclusive)
print(host[4:])     # 01  (to the end)
print(host[:3])     # web (from the start)
print(host[::-1])   # 10-bew (reversed)
print(len(host))    # 6
```

Strings are **immutable** — you can't change a character in place; you create a new string.

## 📖 Lesson 3.3 — Essential string methods

```python
s = "  Web-Server-01  "
s.strip()            # "Web-Server-01"     remove whitespace both ends
s.lower()            # "  web-server-01  "
s.upper()            # "  WEB-SERVER-01  "
s.strip().replace("-", "_")   # "Web_Server_01"   (methods can be chained)

"web-01,web-02,db-01".split(",")       # ['web-01', 'web-02', 'db-01']
"a b   c".split()                      # ['a', 'b', 'c']  (any whitespace)
"-".join(["2024", "05", "01"])         # "2024-05-01"

"nginx.conf".endswith(".conf")         # True
"ERROR: disk full".startswith("ERROR") # True
"disk" in "ERROR: disk full"           # True
"ERROR: disk full".find("disk")        # 7   (-1 if not found)
"a-b-c".count("-")                     # 2
"8080".isdigit()                       # True
"web".center(11, "*")                  # "****web****"
"7".zfill(3)                           # "007"
```

## 📖 Lesson 3.4 — f-strings (formatting)

```python
host, cpu, mem_mb = "web-01", 73.456, 2048

print(f"{host} CPU={cpu:.1f}%")        # web-01 CPU=73.5%
print(f"{mem_mb:,} MB")                # 2,048 MB
print(f"{'HOST':<10}|{'CPU':>6}")      # left / right align in columns
print(f"{host:<10}|{cpu:>6.1f}")
print(f"{42:05d}")                     # 00042
print(f"{0.734:.0%}")                  # 73%
print(f"{host=}")                      # host='web-01'  (great for debugging)
```

Building a neat table:

```python
print(f"{'SERVER':<10} {'CPU%':>6} {'STATUS':<8}")
print(f"{'web-01':<10} {45.2:>6.1f} {'OK':<8}")
print(f"{'db-01':<10} {91.7:>6.1f} {'ALERT':<8}")
```
```
SERVER       CPU% STATUS
web-01       45.2 OK
db-01        91.7 ALERT
```

## 📖 Lesson 3.5 — Parsing a log line (real DevOps)

```python
line = "2024-05-01 12:00:01 ERROR db-01 Connection refused"

parts = line.split(" ", 4)        # split at most 4 times → 5 parts
date, time, level, host, message = parts   # "unpacking"

print(f"[{level}] {host}: {message} at {date} {time}")
# [ERROR] db-01: Connection refused at 2024-05-01 12:00:01
```

## ⚠️ Common mistakes
- Forgetting strings are immutable: `s.upper()` returns a new string; `s` is unchanged
- `"10" > "9"` is `False` (text comparison!) — convert to `int` first
- Off-by-one in slices: end index is **exclusive**

---

## 🧪 Labs

### Lab 1 ⭐ — Hostname normaliser
Given `raw = "   PROD_Web_Server_01  "`, produce `prod-web-server-01`
(strip, lowercase, underscores → hyphens).

### Lab 2 ⭐ — Docker image tag parser
Given `image = "registry.example.com/team/api-service:v2.3.1"`, print:
- registry: `registry.example.com`
- repository: `team/api-service`
- tag: `v2.3.1`
Hint: `split(":")` and `split("/", 1)`, or `rsplit`.

### Lab 3 ⭐⭐ — Log line parser
Given `line = "2024-05-01 12:00:01 ERROR db-01 Connection refused"`,
print: `ALERT! db-01 reported 'Connection refused' on 2024-05-01 at 12:00:01`.
Only print `ALERT!` if level is `ERROR` or `CRITICAL`, otherwise print `info`.
(You may peek ahead at `if` — Module 04.)

### Lab 4 ⭐⭐ — Status table
Print this table using f-string alignment (no manual spaces!):
```
SERVER       CPU%   MEM%  STATUS
web-01       45.2   61.0  OK
web-02       88.9   72.3  WARN
db-01        97.1   90.4  CRIT
```

### Lab 5 ⭐⭐⭐ — URL dissector
Given `url = "https://api.example.com:8443/v1/health?verbose=true"`, extract
scheme, host, port, path, query using only string methods. (Later you'll use `urllib.parse`!)

---

## ✅ Checkpoint
- [ ] I can slice strings and know end index is exclusive
- [ ] I know `strip`, `split`, `join`, `replace`, `startswith`, `in`
- [ ] I can build aligned tables with f-strings

👉 Next: [Module 04 — Control Flow](../04-control-flow/README.md)
