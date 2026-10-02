# Python Module 01 — Getting Started with Python 🟢

## 🎯 Objectives
By the end of this module you can:
- Install Python and check the version
- Use the interactive **REPL**
- Write, save and run a `.py` script
- Use `print()` and comments
- Understand what an error message is telling you

## 🧠 Why DevOps engineers care
Every automation journey starts with "run a script". You'll run Python scripts on
servers, in CI pipelines (GitHub Actions, Jenkins, GitLab CI) and inside Docker
containers. Knowing how Python is installed and executed on Linux saves hours of debugging.

---

## 📖 Lesson 1.1 — Install & verify

Ubuntu already includes Python 3. If you followed [Step 0 — Ubuntu setup](../../00-ubuntu-setup/README.md),
you're ready. Otherwise:

```bash
sudo apt update && sudo apt install -y python3 python3-pip python3-venv
```

Verify:
```bash
python3 --version     # Ubuntu 24.04 → Python 3.12, Ubuntu 22.04 → Python 3.10. Both are fine.
which python3         # /usr/bin/python3 (or ~/venvs/devops/bin/python3 if your venv is active)
```

> ⚠️ On Linux, use `python3` — `python` may not exist or may point to old Python 2.

## 📖 Lesson 1.2 — The REPL (your playground)

REPL = **R**ead **E**val **P**rint **L**oop. Type `python3` and press Enter:

```python
>>> 2 + 2
4
>>> print("Hello, DevOps!")
Hello, DevOps!
>>> 60 * 60 * 24        # seconds in a day
86400
>>> exit()              # or press Ctrl+D
```

Use the REPL to **quickly test ideas**. Use scripts for anything you want to keep.

## 📖 Lesson 1.3 — Your first script

Create a file `hello.py`:

```python
# hello.py — my first Python script
# Lines starting with # are comments. Python ignores them.

print("Hello, DevOps world!")
print("Server:", "web-01")
print("Uptime days:", 42)
```

Run it:

```bash
python3 hello.py
```

Output:
```
Hello, DevOps world!
Server: web-01
Uptime days: 42
```

## 📖 Lesson 1.4 — Making a script executable (Linux way)

Add a **shebang** as the very first line so Linux knows which interpreter to use:

```python
#!/usr/bin/env python3
print("I run like a real command!")
```

```bash
chmod +x hello.py     # give execute permission
./hello.py            # run it directly
```

> This is exactly how DevOps tools are shipped — you'll see this again in Bash.

## 📖 Lesson 1.5 — `print()` tricks

```python
print("a", "b", "c")             # a b c
print("a", "b", "c", sep="-")    # a-b-c
print("no newline", end="")      # stays on the same line
print()                          # empty line
print("=" * 30)                  # ==============================
```

## 📖 Lesson 1.6 — Reading error messages (very important!)

```python
print("hello"
```
```
  File "hello.py", line 1
    print("hello"
         ^
SyntaxError: '(' was never closed
```

How to read it — **always from the bottom up**:
1. **Last line** = the error type and message (`SyntaxError: '(' was never closed`)
2. **Above** = the file and line number where Python noticed it
3. Fix → re-run → repeat

Common beginner errors:

| Error | Meaning |
|-------|---------|
| `SyntaxError` | Python can't understand your code (typo, missing bracket/quote) |
| `NameError` | You used a name that doesn't exist (typo in variable name?) |
| `IndentationError` | Spaces at the start of a line are wrong |
| `TypeError` | Wrong type, e.g. `"5" + 5` |

## ⚠️ Common mistakes
- Using `python` instead of `python3`
- Mixing tabs and spaces → always use **4 spaces**
- Smart quotes `“ ”` copied from Word/web pages → use plain `" "`
- Saving as `hello.py.txt` on Windows

---

## 🧪 Labs

### Lab 1 ⭐ — Server banner
Write `banner.py` that prints:
```
==============================
  Welcome to PROD-WEB-01
  Environment: production
  Managed by: DevOps Team
==============================
```
Use `"=" * 30` for the lines.

### Lab 2 ⭐ — Quick maths in the REPL
In the REPL, calculate:
1. Seconds in a week
2. How many GB is 5000 MB? (1 GB = 1024 MB)
3. If a disk has 500 GB and 375 GB is used, what % is used?

### Lab 3 ⭐⭐ — Make it executable
Add a shebang to `banner.py`, `chmod +x` it, and run it with `./banner.py`.

### Lab 4 ⭐⭐ — Break it on purpose
Introduce each error into a copy of your script, run it, and **write down** what Python says:
`SyntaxError`, `NameError` (e.g. `prnt("x")`), `IndentationError` (add spaces before `print`).

---

## ✅ Checkpoint
- [ ] I can open and exit the REPL
- [ ] I can run a script with `python3 file.py` **and** `./file.py`
- [ ] I read error messages from the bottom up

👉 Next: [Module 02 — Variables, Types & Operators](../02-variables-and-types/README.md)
