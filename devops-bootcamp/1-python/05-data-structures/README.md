# Module 05 — Data Structures 🟢

## 🎯 Objectives
- Use **lists**, **tuples**, **dictionaries** and **sets**
- Know which one to pick and why
- Nest them (list of dicts = how JSON/YAML looks!)
- Write list and dict **comprehensions**

## 🧠 Why DevOps engineers care
A server inventory is a **list**. A config is a **dict**. Open ports are a **set**.
API responses (JSON) and Kubernetes/Ansible files (YAML) load into Python as
**lists of dicts**. Master these and you can process any infrastructure data.

| Type | Syntax | Ordered | Changeable | Duplicates | Use for |
|------|--------|---------|-----------|------------|---------|
| list | `[1, 2]` | ✅ | ✅ | ✅ | collections of items (servers, logs) |
| tuple | `(1, 2)` | ✅ | ❌ | ✅ | fixed records (host, port) |
| dict | `{"k": v}` | ✅ | ✅ | keys unique | lookup by name (config) |
| set | `{1, 2}` | ❌ | ✅ | ❌ | uniqueness, comparisons |

---

## 📖 Lesson 5.1 — Lists

```python
servers = ["web-01", "web-02", "db-01"]

servers[0]                  # "web-01"
servers[-1]                 # "db-01"
servers[1:]                 # ["web-02", "db-01"]
len(servers)                # 3

servers.append("cache-01")  # add to end
servers.insert(0, "lb-01")  # add at position
servers.remove("web-02")    # remove by value
last = servers.pop()        # remove & return last
servers.sort()              # sort in place
sorted(servers, reverse=True)   # returns a NEW sorted list
"db-01" in servers          # True
servers.index("db-01")      # position of item
servers.extend(["x", "y"])  # add many

numbers = [72, 45, 91, 60]
print(sum(numbers), min(numbers), max(numbers), sum(numbers) / len(numbers))
```

## 📖 Lesson 5.2 — Tuples

Like lists but **cannot change** — safe for fixed data.

```python
endpoint = ("10.0.0.5", 443)
ip, port = endpoint                     # unpacking
print(f"Connecting to {ip}:{port}")

# Functions often return tuples
def disk_stats():
    return 500, 375            # total, used
total, used = disk_stats()
```

## 📖 Lesson 5.3 — Dictionaries (the most important one!)

```python
server = {
    "hostname": "web-01",
    "ip": "10.0.1.15",
    "cpu": 4,
    "tags": ["web", "prod"],
}

server["hostname"]                   # "web-01"
server.get("region")                 # None (no crash if missing)
server.get("region", "us-east-1")    # default value
server["region"] = "eu-west-1"       # add / update
del server["tags"]                   # delete
"ip" in server                       # True (checks KEYS)

for key, value in server.items():
    print(f"{key:>10}: {value}")

server.keys()     # all keys
server.values()   # all values
server.update({"cpu": 8, "ram": 32})   # merge
```

Counting with a dict (super common!):

```python
levels = ["INFO", "ERROR", "INFO", "WARN", "ERROR", "INFO"]
counts = {}
for level in levels:
    counts[level] = counts.get(level, 0) + 1
print(counts)    # {'INFO': 3, 'ERROR': 2, 'WARN': 1}
```

## 📖 Lesson 5.4 — Sets

```python
allowed_ports = {22, 80, 443}
open_ports = {22, 80, 443, 3306, 8080}

print(open_ports - allowed_ports)    # {3306, 8080}  → security risk!
print(open_ports & allowed_ports)    # intersection
print(open_ports | {9090})           # union
unique_ips = set(["1.1.1.1", "2.2.2.2", "1.1.1.1"])   # removes duplicates
```

## 📖 Lesson 5.5 — Nested data (looks like JSON!)

```python
inventory = [
    {"name": "web-01", "env": "prod", "cpu": 45},
    {"name": "web-02", "env": "prod", "cpu": 91},
    {"name": "dev-01", "env": "dev",  "cpu": 12},
]

for host in inventory:
    if host["env"] == "prod" and host["cpu"] > 80:
        print(f"High CPU on {host['name']}: {host['cpu']}%")

config = {
    "app": {"name": "api", "replicas": 3},
    "db": {"host": "db-01", "port": 5432},
}
print(config["db"]["port"])    # 5432
```

## 📖 Lesson 5.6 — Comprehensions (pro shortcut)

```python
# [expression for item in iterable if condition]
names = [h["name"] for h in inventory]                       # ['web-01', 'web-02', 'dev-01']
prod  = [h["name"] for h in inventory if h["env"] == "prod"] # ['web-01', 'web-02']
squares = [n * n for n in range(5)]

# dict comprehension
cpu_by_host = {h["name"]: h["cpu"] for h in inventory}       # {'web-01': 45, ...}

# set comprehension
envs = {h["env"] for h in inventory}                         # {'prod', 'dev'}
```

## 📖 Lesson 5.7 — Copying gotcha

```python
a = ["x", "y"]
b = a            # b is the SAME list, not a copy!
b.append("z")
print(a)         # ['x', 'y', 'z']  😱
c = a.copy()     # real (shallow) copy
```

## ⚠️ Common mistakes
- `dict["missing"]` → `KeyError`; use `.get()` when the key may not exist
- `b = a` doesn't copy a list/dict
- Sets are unordered — don't rely on their order
- `{}` is an empty **dict**, not a set; use `set()` for an empty set

---

## 🧪 Labs

### Lab 1 ⭐ — Inventory manager
Start with `servers = ["web-01", "web-02", "db-01"]`.
Add `cache-01`, remove `web-02`, insert `lb-01` at the start, sort and print with count.

### Lab 2 ⭐ — Config lookup
Create a dict `config` with keys `app_name`, `port`, `debug`, `replicas`.
Print each key/value. Safely print `log_level` with default `"INFO"`. Update `replicas` to 5.

### Lab 3 ⭐⭐ — Log level counter
Given:
```python
logs = ["INFO start", "ERROR db", "WARN slow", "INFO ok", "ERROR api", "ERROR db", "INFO done"]
```
Build a dict counting each level, then print levels sorted by count (highest first).

### Lab 4 ⭐⭐ — Firewall audit
`allowed = {22, 80, 443}`. For each server below, print unexpected open ports and missing required ports:
```python
servers = {
    "web-01": {22, 80, 443},
    "web-02": {22, 80, 443, 8080},
    "db-01": {22, 5432},
}
```

### Lab 5 ⭐⭐⭐ — Inventory report
Using this inventory:
```python
inventory = [
    {"name": "web-01", "env": "prod", "role": "web", "cpu": 45, "mem": 70},
    {"name": "web-02", "env": "prod", "role": "web", "cpu": 91, "mem": 85},
    {"name": "db-01", "env": "prod", "role": "db", "cpu": 66, "mem": 93},
    {"name": "web-03", "env": "staging", "role": "web", "cpu": 20, "mem": 30},
    {"name": "db-02", "env": "staging", "role": "db", "cpu": 10, "mem": 40},
]
```
1. Group server names by environment → `{"prod": [...], "staging": [...]}`
2. List servers where CPU **or** memory > 90 (comprehension)
3. Average CPU per role
4. Print a set of all unique roles

---

## ✅ Checkpoint
- [ ] I can choose between list/tuple/dict/set
- [ ] I can loop over a list of dicts and access nested values
- [ ] I can write a list and a dict comprehension

👉 Next: [Module 06 — Functions](../06-functions/README.md)
