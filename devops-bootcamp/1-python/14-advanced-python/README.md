# Python Module 14 — Advanced Python 🔴

## 🎯 Objectives
- Process huge files with constant memory using **iterators & generators**
- Count and group like a pro with **`collections`** (`Counter`, `defaultdict`, `deque`)
- Write **decorators** (`@retry`, `@timed`) — the pattern behind Flask, pytest and Click
- Write your own **context managers** (`with timer():`, `with file_lock(...)`)
- Run I/O work **concurrently** with threads and **asyncio**
- **Package** your tool so anyone can `pip install` it and run it as a real command

## 🧠 Why DevOps engineers care
This is the difference between "I can write Python scripts" and "I build tools my team relies on":
- a 20 GB log won't fit in memory → **generators**
- checking 500 servers one by one takes 25 minutes; concurrently, 10 seconds → **threads / asyncio**
- every API call needs retries → one **decorator** instead of 40 copy-pasted loops
- teammates should run `healthmon` like `git`, not `python3 ~/scripts/healthmon.py` → **packaging**

---

## 📖 Lesson 14.1 — Iterators & generators

A `for` loop works on anything **iterable**: lists, files, dicts, ranges... An **iterator** hands
out one item at a time. A **generator** is the easiest way to make your own — a function with `yield`:

```python
def count_up_to(n):
    i = 1
    while i <= n:
        yield i          # hand back one value, PAUSE here until the next one is asked for
        i += 1

for x in count_up_to(3):
    print(x)             # 1, 2, 3

gen = count_up_to(2)
print(next(gen), next(gen))   # 1 2   — next() asks for one item
```

**Why it matters:** a list holds *everything* in memory; a generator holds *one item at a time*.

```python
def read_errors(path):
    """Yield only ERROR lines — works on a 50 GB file with almost no memory."""
    with open(path, encoding="utf-8") as f:
        for line in f:               # files are iterators too: one line at a time
            if " ERROR " in line:
                yield line.rstrip("\n")

for line in read_errors("app.log"):
    print(line)
```

**Generator pipelines** — chain small steps like Unix pipes (`cat | grep | cut`):

```python
def read_lines(path):
    with open(path, encoding="utf-8") as f:
        yield from f                         # yield every line of the file

def grep(lines, word):
    return (l for l in lines if word in l)   # generator EXPRESSION: like a list comp with ( )

def field(lines, n):
    return (l.split()[n] for l in lines)

hosts = field(grep(read_lines("app.log"), "ERROR"), 3)   # nothing has run yet!
print(sorted(set(hosts)))                                # now it streams through once
```

> 💡 `[x for x in data]` builds a list (memory!). `(x for x in data)` is lazy (no memory). `sum(x for x in data)` needs no extra brackets.

## 📖 Lesson 14.2 — `collections`: the power tools

```python
from collections import Counter, defaultdict, deque, namedtuple

# Counter — count anything
levels = Counter(line.split()[2] for line in open("app.log"))
print(levels.most_common(2))            # [('INFO', 4), ('ERROR', 3)]
levels["DEBUG"]                         # 0 — missing keys count as 0 (no KeyError)

# defaultdict — group without "if key not in dict"
by_host = defaultdict(list)
for line in open("app.log"):
    parts = line.split(maxsplit=4)
    by_host[parts[3]].append(parts[4].strip())

# deque(maxlen=N) — keep only the last N items (this is how `tail -n 5` works)
last5 = deque(open("app.log"), maxlen=5)

# namedtuple — a tiny read-only record
Check = namedtuple("Check", "name ok detail")
c = Check("disk", True, "40% used")
print(c.name, c.ok)
```

## 📖 Lesson 14.3 — Decorators

A decorator is a function that **wraps** another function to add behaviour — without changing it.

```python
import functools
import time

def timed(func):
    @functools.wraps(func)                    # keep the original name & docstring
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)        # call the real function
        print(f"{func.__name__} took {time.perf_counter() - start:.3f}s")
        return result
    return wrapper

@timed                                        # same as: backup = timed(backup)
def backup():
    time.sleep(0.2)

backup()                                      # backup took 0.200s
```

**Decorators with arguments** need one more layer — the classic production `@retry`:

```python
def retry(times=3, delay=1.0, exceptions=(Exception,)):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(1, times + 1):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    if attempt == times:
                        raise                              # out of attempts: re-raise
                    print(f"{func.__name__} failed ({e}); retry {attempt}/{times - 1}")
                    time.sleep(delay * 2 ** (attempt - 1)) # exponential backoff
        return wrapper
    return decorator

@retry(times=5, delay=0.5, exceptions=(ConnectionError, TimeoutError))
def fetch_status():
    ...
```

You've already used decorators: `@dataclass`, `@property`, `@pytest.mark.parametrize`.

## 📖 Lesson 14.4 — Context managers (your own `with`)

`with` guarantees **cleanup**, even if an error happens — like `trap ... EXIT` in shell.
The easy way to make one is `@contextlib.contextmanager`:

```python
import contextlib
import os
import time

@contextlib.contextmanager
def timer(label):
    start = time.perf_counter()
    try:
        yield                                  # the body of the `with` block runs here
    finally:
        print(f"{label}: {time.perf_counter() - start:.2f}s")   # always runs

@contextlib.contextmanager
def working_directory(path):
    old = os.getcwd()
    os.chdir(path)
    try:
        yield path
    finally:
        os.chdir(old)                          # always go back, even after an exception

with timer("deploy"), working_directory("/tmp"):
    print(os.getcwd())                         # /tmp
```

Useful built-ins: `contextlib.suppress(FileNotFoundError)`, `tempfile.TemporaryDirectory()`.

## 📖 Lesson 14.5 — Concurrency with threads

Most DevOps work **waits** (network, disk, APIs). While one request waits, others can run.
`concurrent.futures.ThreadPoolExecutor` makes this easy:

```python
from concurrent.futures import ThreadPoolExecutor, as_completed
import socket

def is_open(host, port, timeout=1.0):
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return port, True
    except OSError:
        return port, False

ports = range(1, 1025)
with ThreadPoolExecutor(max_workers=100) as pool:
    futures = [pool.submit(is_open, "localhost", p) for p in ports]
    for fut in as_completed(futures):            # results arrive as each one finishes
        port, ok = fut.result()
        if ok:
            print("open:", port)

# Or, results in the same order as the inputs:
with ThreadPoolExecutor(max_workers=20) as pool:
    results = list(pool.map(lambda p: is_open("localhost", p), [22, 80, 443]))
```

| Work type | Use |
|-----------|-----|
| Waiting on network/disk (APIs, SSH, HTTP, ports) | `ThreadPoolExecutor` or `asyncio` |
| Heavy CPU (compressing, hashing big files) | `ProcessPoolExecutor` (Python's GIL lets only one thread run Python code at a time) |

> ⚠️ Be a good citizen: limit `max_workers`, and only scan hosts **you own**.

## 📖 Lesson 14.6 — `asyncio` (intro)

`asyncio` runs thousands of waiting tasks on **one** thread. Functions are `async def`, and you
`await` anything slow:

```python
import asyncio

async def check_port(host, port, timeout=1.0):
    try:
        _, writer = await asyncio.wait_for(asyncio.open_connection(host, port), timeout)
        writer.close()
        await writer.wait_closed()
        return port, True
    except (OSError, asyncio.TimeoutError):
        return port, False

async def main():
    results = await asyncio.gather(*(check_port("localhost", p) for p in range(1, 1025)))
    print([p for p, ok in results if ok])

asyncio.run(main())
```

Modern libraries (`httpx`, `aiohttp`, FastAPI) are async. Start with threads; reach for asyncio when
you need very many concurrent connections.

## 📖 Lesson 14.7 — Package your tool (`pyproject.toml`)

Turn a folder of code into an installable command:

```
devopskit/
├── pyproject.toml
└── src/
    └── devopskit/
        ├── __init__.py
        └── cli.py          # has a main() function
```

`pyproject.toml`:
```toml
[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"

[project]
name = "devopskit"
version = "0.2.0"
requires-python = ">=3.10"
dependencies = []

[project.scripts]
devopskit = "devopskit.cli:main"     # command name = "package.module:function"
```

```bash
pip install -e .          # -e = "editable": your code changes apply immediately
devopskit --help          # 🎉 a real command, available anywhere while the venv is active
pip install .             # normal install; `python -m build` makes a wheel to share
pipx install .            # install a CLI tool in its own isolated venv (great for team tools)
```

See the working example in [`solutions/devopskit/`](solutions/devopskit/).

## 📖 Lesson 14.8 — Measure before you optimise

```python
import time
start = time.perf_counter()
...
print(f"{time.perf_counter() - start:.3f}s")
```
```bash
python3 -m cProfile -s cumtime my_script.py | head -20    # where is the time going?
python3 -m timeit "'-'.join(str(n) for n in range(100))"  # micro-benchmarks
```

---

## ⚠️ Common mistakes
- Iterating a generator twice — it's empty the second time (make a new one)
- Forgetting `functools.wraps` → decorated functions lose their name/docstring
- Forgetting `try/finally` around `yield` in a context manager → no cleanup on errors
- Threads for CPU-heavy work (use processes) or unlimited workers (overloads targets)
- Calling a blocking function (`time.sleep`, `requests.get`) inside `async def` — it freezes the event loop

---

## 🧪 Labs
Work in `my-work/python/`. Solutions in [`solutions/`](solutions/), with tests: `pytest solutions/`.

### Lab 1 ⭐⭐ — Generator log pipeline
1. Run `python3 solutions/make_big_log.py` to create a 500,000-line `big.log`.
2. Write generator functions `read_lines`, `only_level`, `parse` and use them with `Counter` to print
   the top 5 hosts with ERRORs — without ever building a list of all lines.
3. Bonus: print peak memory with `resource.getrusage(resource.RUSAGE_SELF).ru_maxrss` and compare with
   `f.readlines()`.

### Lab 2 ⭐⭐ — Decorators
Write `@timed` and `@retry(times, delay, exceptions)`. Prove `@retry` works with a function that fails
twice then succeeds, and that it re-raises after the last attempt. Write pytest tests for both.

### Lab 3 ⭐⭐ — Context managers
Write `timer(label)`, `working_directory(path)` and `file_lock(path)` (use `fcntl.flock` with
`LOCK_EX | LOCK_NB`; raise `RuntimeError("already running")` if locked). Show the lock blocks a
second process.

### Lab 4 ⭐⭐⭐ — Concurrent port scanner
`portscan.py HOST [--ports 1-1024] [--mode seq|threads|async]` — scan your **own** machine with all
three modes and print the time each took. Start `python3 -m http.server 8000` in another terminal
so there's something to find.
Note: on your own machine closed ports answer instantly, so `seq` looks fast too. Try a range on a
VM or cloud server you own, where closed ports time out — then threads/async win by 10–100×.

### Lab 5 ⭐⭐⭐ — Ship it
Package a CLI called `devopskit` with subcommands `ports` (Lab 4) and `bytes` (convert bytes to
human-readable). Install it with `pip install -e .` and run `devopskit ports localhost`.

---

## ✅ Checkpoint
- [ ] I can write a generator and explain why it saves memory
- [ ] I use `Counter`, `defaultdict` and `deque` naturally
- [ ] I can write a decorator with arguments and a context manager
- [ ] I know when to use threads, processes and asyncio
- [ ] I can package a tool with `pyproject.toml` and an entry point

👉 Next: [Python Module 15 — Capstone Projects](../15-capstone/README.md)
