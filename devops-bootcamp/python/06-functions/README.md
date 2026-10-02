# Module 06 — Functions 🟡

## 🎯 Objectives
- Define functions with parameters and return values
- Use default, keyword, `*args` and `**kwargs` arguments
- Understand scope (local vs global)
- Write docstrings and type hints
- Use `lambda`, `sorted(key=...)`, and the `if __name__ == "__main__":` pattern

## 🧠 Why DevOps engineers care
Copy-pasted code is how bugs spread across 50 scripts. Functions let you write
`check_disk()` **once** and reuse it everywhere. Good functions are the foundation of
every maintainable automation tool.

---

## 📖 Lesson 6.1 — Defining & calling

```python
def greet():
    print("Hello from a function!")

greet()        # call it
```

## 📖 Lesson 6.2 — Parameters & return values

```python
def disk_percent(used_gb, total_gb):
    return used_gb / total_gb * 100

pct = disk_percent(375, 500)
print(f"{pct:.1f}%")      # 75.0%
```

- **Parameters** = names in the definition (`used_gb`)
- **Arguments** = actual values you pass (`375`)
- `return` sends a value back and **exits** the function. No `return` → returns `None`.

Return multiple values (a tuple):
```python
def min_max(values):
    return min(values), max(values)

low, high = min_max([3, 9, 1])
```

## 📖 Lesson 6.3 — Default & keyword arguments

```python
def deploy(app, env="dev", replicas=1, dry_run=False):
    mode = "DRY RUN" if dry_run else "LIVE"
    print(f"[{mode}] Deploying {app} to {env} with {replicas} replicas")

deploy("api")                                  # uses defaults
deploy("api", "prod", 3)                       # positional
deploy("api", replicas=5, env="staging")       # keyword — order doesn't matter, clearer!
deploy("api", env="prod", dry_run=True)
```

> ⚠️ Never use a mutable default like `def f(items=[])` — use `items=None` then `items = items or []`.

## 📖 Lesson 6.4 — `*args` and `**kwargs`

```python
def restart(*services):                 # any number of positional args → tuple
    for s in services:
        print("restarting", s)

restart("nginx", "redis", "api")

def tag_resource(resource_id, **tags):  # any keyword args → dict
    for k, v in tags.items():
        print(f"{resource_id}: {k}={v}")

tag_resource("i-123", env="prod", team="platform", cost_center="42")
```

Unpacking when calling:
```python
settings = {"env": "prod", "replicas": 3}
deploy("api", **settings)
```

## 📖 Lesson 6.5 — Scope

```python
counter = 0            # global

def increment():
    local_value = 1    # only exists inside the function
    return counter + local_value

print(increment())     # 1
# print(local_value)   # NameError!
```

> 💡 Avoid `global`. Pass values in as parameters and `return` results out. Easier to test.

## 📖 Lesson 6.6 — Docstrings & type hints

```python
def is_port_valid(port: int) -> bool:
    """Return True if port is in the valid TCP range (1-65535)."""
    return 1 <= port <= 65535

help(is_port_valid)    # shows the docstring
```

Type hints don't change how Python runs, but editors and tools (`mypy`) use them to catch bugs.

## 📖 Lesson 6.7 — Lambda & sorting

```python
servers = [{"name": "web-01", "cpu": 45}, {"name": "db-01", "cpu": 91}, {"name": "web-02", "cpu": 70}]

by_cpu = sorted(servers, key=lambda s: s["cpu"], reverse=True)
print([s["name"] for s in by_cpu])        # ['db-01', 'web-02', 'web-01']

hot = list(filter(lambda s: s["cpu"] > 60, servers))
```

A `lambda` is a tiny unnamed function: `lambda args: expression`.

## 📖 Lesson 6.8 — The `main` pattern

Every professional Python script looks like this:

```python
#!/usr/bin/env python3
"""check_servers.py — check server health."""


def check(server: str) -> bool:
    print(f"checking {server}")
    return True


def main() -> None:
    for s in ["web-01", "web-02"]:
        check(s)


if __name__ == "__main__":
    main()
```

`if __name__ == "__main__":` means "only run `main()` when this file is executed directly,
**not** when it's imported by another file". You'll see why in Module 08.

## ⚠️ Common mistakes
- Forgetting to `return` (function returns `None`)
- `print` inside a function instead of `return` — makes it un-reusable
- Mutable default arguments
- Functions that do 10 things — keep them small: **one function, one job**

---

## 🧪 Labs

### Lab 1 ⭐ — Unit converters
Write `bytes_to_human(n: int) -> str` that returns `"512.0 B"`, `"1.5 KB"`, `"3.2 GB"` etc.
(1024 based, units B, KB, MB, GB, TB).

### Lab 2 ⭐ — Validators
Write `is_valid_port(port)` and `is_valid_ipv4(ip)` (4 parts, each 0–255, all digits).
Test with: `"192.168.1.1"` ✅, `"256.1.1.1"` ❌, `"10.0.0"` ❌, `"a.b.c.d"` ❌.

### Lab 3 ⭐⭐ — Health status function
Write `health_status(cpu, mem, disk, threshold=80)` that returns a tuple
`(status, problems)` where status is `"OK"` or `"DEGRADED"` and problems is a list of
metric names above threshold.

### Lab 4 ⭐⭐ — Deploy planner
Write `plan_deploy(app, *envs, dry_run=False, **options)` that prints a deployment step for
each env, including all options. Example:
`plan_deploy("api", "staging", "prod", dry_run=True, version="1.2.0", replicas=3)`

### Lab 5 ⭐⭐⭐ — Retry helper
Write `retry(func, attempts=3, delay=0.1)` that calls `func()` until it returns `True`
or attempts run out. Return `True/False`. Test it with a function that succeeds on the
3rd call (hint: use a list or a counter dict to track calls).
Structure the file with a `main()` and the `__main__` guard.

---

## ✅ Checkpoint
- [ ] I `return` values instead of printing inside functions
- [ ] I can use defaults, keyword args, `*args`, `**kwargs`
- [ ] My scripts use `main()` and `if __name__ == "__main__":`

👉 Next: [Module 07 — Files & Error Handling](../07-files-and-errors/README.md)
