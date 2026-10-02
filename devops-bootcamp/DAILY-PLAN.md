# 📅 Daily Plan — learn and practise every day

> **One page, one day at a time.** About **60–90 minutes a day**. Follow the days in order.
> Every 7th day is a 🔄 **review day**. Total: **96 days** (about 14 weeks).
>
> Run this to see **today's** task and track your progress:
> ```bash
> cd ~/Practice/devops-bootcamp
> sh today.sh            # show today's task
> sh today.sh done       # mark today complete → tomorrow's task
> sh today.sh status     # progress so far
> ```

## How every day works

| Step | Time | What |
|------|------|------|
| 🔁 Warm-up | 10 min | A small drill on something you learned **earlier** — from memory, no notes. This is how it sticks. |
| 📖 Learn | 30–40 min | Read the listed lessons and **type** every example. |
| 🧪 Practice | 30–40 min | Do the listed labs in `my-work/`. Check `solutions/` only after a real try. |
| 💾 Save | 2 min | `git add -A && git commit -m "Day N" && git push` |

Missed a day? No problem — just continue where you stopped. Don't skip ahead.

## Overview

| Days | Phase |
|------|-------|
| 1 | Step 0 · Ubuntu setup |
| 2–44 | Phase 1 · Python |
| 45–70 | Phase 2 · Shell scripting |
| 71–96 | Phase 3 · Bash |

---
## Day 1 — Step 0 · Set up your Ubuntu lab

**🎯 Goal:** Have every tool installed and the checker showing all ✅.  
**📂 Module:** [00-ubuntu-setup](00-ubuntu-setup/README.md)

- [ ] 🔁 **Warm-up (10 min):** Open a terminal and type: `pwd`, `ls`, `cd ~`, `cd -`. Just get comfortable.
- [ ] 📖 **Learn:** Steps 1–10 of the setup guide
- [ ] 🧪 **Practice:** Run `sh 00-ubuntu-setup/check_setup.sh` until everything is ✅. Then run `sh today.sh done`.
- [ ] 💾 **Save:** `git commit -m "Day 1: Step 0 Set up your Ubuntu lab"`

## Day 2 — Python 01 · Getting started

**🎯 Goal:** Run Python in the REPL and as a script.  
**📂 Module:** [1-python/01-getting-started](1-python/01-getting-started/README.md)

- [ ] 🔁 **Warm-up (10 min):** In the terminal: `python3 --version`, `which python3`, `echo $VIRTUAL_ENV`.
- [ ] 📖 **Learn:** Lessons 1.1–1.6
- [ ] 🧪 **Practice:** Labs 1–4
- [ ] 💾 **Save:** `git commit -m "Day 2: Python 01 Getting started"`

## Day 3 — Python 02 · Variables & types (1/2)

**🎯 Goal:** Store data in variables and convert between types.  
**📂 Module:** [1-python/02-variables-and-types](1-python/02-variables-and-types/README.md)

- [ ] 🔁 **Warm-up (10 min):** From memory, write a script that prints a 30-character `=` banner with your name inside.
- [ ] 📖 **Learn:** Lessons 2.1–2.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 3: Python 02 Variables & types (1/2)"`

## Day 4 — Python 02 · Variables & types (2/2)

**🎯 Goal:** Compare values, combine conditions, read input.  
**📂 Module:** [1-python/02-variables-and-types](1-python/02-variables-and-types/README.md)

- [ ] 🔁 **Warm-up (10 min):** In the REPL: convert `"8080"` to an int, add 1, and print it in an f-string.
- [ ] 📖 **Learn:** Lessons 2.5–2.7
- [ ] 🧪 **Practice:** Labs 3–5
- [ ] 💾 **Save:** `git commit -m "Day 4: Python 02 Variables & types (2/2)"`

## Day 5 — Python 03 · Strings (1/2)

**🎯 Goal:** Slice strings and use the core string methods.  
**📂 Module:** [1-python/03-strings](1-python/03-strings/README.md)

- [ ] 🔁 **Warm-up (10 min):** Without notes: seconds → `X h Y m Z s` for 93784 (use `//` and `%`).
- [ ] 📖 **Learn:** Lessons 3.1–3.3
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 5: Python 03 Strings (1/2)"`

## Day 6 — Python 03 · Strings (2/2)

**🎯 Goal:** Format tables with f-strings and parse log lines.  
**📂 Module:** [1-python/03-strings](1-python/03-strings/README.md)

- [ ] 🔁 **Warm-up (10 min):** From memory: normalise `"  PROD_Web_01 "` → `prod-web-01`.
- [ ] 📖 **Learn:** Lessons 3.4–3.5
- [ ] 🧪 **Practice:** Labs 3–5
- [ ] 💾 **Save:** `git commit -m "Day 6: Python 03 Strings (2/2)"`

## Day 7 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 8 — Python 04 · Control flow (1/2)

**🎯 Goal:** Make decisions with if/elif/else and loop with for.  
**📂 Module:** [1-python/04-control-flow](1-python/04-control-flow/README.md)

- [ ] 🔁 **Warm-up (10 min):** Split `2024-05-01 12:00:01 ERROR db-01 Connection refused` into 5 variables.
- [ ] 📖 **Learn:** Lessons 4.1–4.3
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 8: Python 04 Control flow (1/2)"`

## Day 9 — Python 04 · Control flow (2/2)

**🎯 Goal:** Retry with while, use break/continue and match.  
**📂 Module:** [1-python/04-control-flow](1-python/04-control-flow/README.md)

- [ ] 🔁 **Warm-up (10 min):** Print 1–10, writing `even`/`odd` next to each number.
- [ ] 📖 **Learn:** Lessons 4.4–4.7
- [ ] 🧪 **Practice:** Labs 3–6
- [ ] 💾 **Save:** `git commit -m "Day 9: Python 04 Control flow (2/2)"`

## Day 10 — Python 05 · Data structures (1/3)

**🎯 Goal:** Use lists and tuples.  
**📂 Module:** [1-python/05-data-structures](1-python/05-data-structures/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a `while` loop that retries 3 times with `time.sleep(1)` and stops early on success.
- [ ] 📖 **Learn:** Lessons 5.1–5.2
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 10: Python 05 Data structures (1/3)"`

## Day 11 — Python 05 · Data structures (2/3)

**🎯 Goal:** Use dictionaries and sets — the DevOps workhorses.  
**📂 Module:** [1-python/05-data-structures](1-python/05-data-structures/README.md)

- [ ] 🔁 **Warm-up (10 min):** Make a list of 5 servers, sort it, print it numbered with `enumerate`.
- [ ] 📖 **Learn:** Lessons 5.3–5.4
- [ ] 🧪 **Practice:** Labs 2–4
- [ ] 💾 **Save:** `git commit -m "Day 11: Python 05 Data structures (2/3)"`

## Day 12 — Python 05 · Data structures (3/3)

**🎯 Goal:** Work with nested data and comprehensions.  
**📂 Module:** [1-python/05-data-structures](1-python/05-data-structures/README.md)

- [ ] 🔁 **Warm-up (10 min):** Count words in a sentence using a dict and `.get(word, 0) + 1`.
- [ ] 📖 **Learn:** Lessons 5.5–5.7
- [ ] 🧪 **Practice:** Lab 5
- [ ] 💾 **Save:** `git commit -m "Day 12: Python 05 Data structures (3/3)"`

## Day 13 — Python 06 · Functions (1/2)

**🎯 Goal:** Write functions with defaults, keyword args, *args, **kwargs.  
**📂 Module:** [1-python/06-functions](1-python/06-functions/README.md)

- [ ] 🔁 **Warm-up (10 min):** One-liner comprehension: names of servers with `cpu > 80` from a list of dicts.
- [ ] 📖 **Learn:** Lessons 6.1–6.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 13: Python 06 Functions (1/2)"`

## Day 14 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 15 — Python 06 · Functions (2/2)

**🎯 Goal:** Scope, type hints, lambda sorting, and the main() pattern.  
**📂 Module:** [1-python/06-functions](1-python/06-functions/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write `is_valid_port(port) -> bool` from memory, with a docstring.
- [ ] 📖 **Learn:** Lessons 6.5–6.8
- [ ] 🧪 **Practice:** Labs 3–5
- [ ] 💾 **Save:** `git commit -m "Day 15: Python 06 Functions (2/2)"`

## Day 16 — Python 07 · Files & errors (1/2)

**🎯 Goal:** Read and write files safely with `with open`.  
**📂 Module:** [1-python/07-files-and-errors](1-python/07-files-and-errors/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a script skeleton with `main()` and the `__main__` guard — no peeking.
- [ ] 📖 **Learn:** Lessons 7.1–7.2
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 16: Python 07 Files & errors (1/2)"`

## Day 17 — Python 07 · Files & errors (2/2)

**🎯 Goal:** Handle exceptions and return proper exit codes.  
**📂 Module:** [1-python/07-files-and-errors](1-python/07-files-and-errors/README.md)

- [ ] 🔁 **Warm-up (10 min):** Read `data/app.log` line by line and print only the line numbers of ERRORs.
- [ ] 📖 **Learn:** Lessons 7.3–7.6
- [ ] 🧪 **Practice:** Labs 3–5
- [ ] 💾 **Save:** `git commit -m "Day 17: Python 07 Files & errors (2/2)"`

## Day 18 — Python 08 · Modules & packages

**🎯 Goal:** Import modules and build your own package.  
**📂 Module:** [1-python/08-modules-venv-pip](1-python/08-modules-venv-pip/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write `int(input())` wrapped in try/except ValueError that loops until valid.
- [ ] 📖 **Learn:** Lessons 8.1–8.3
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 18: Python 08 Modules & packages"`

## Day 19 — Python 08 · venv & pip

**🎯 Goal:** Create venvs and pin dependencies (Ubuntu's way).  
**📂 Module:** [1-python/08-modules-venv-pip](1-python/08-modules-venv-pip/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain out loud: what does `if __name__ == "__main__":` do and why?
- [ ] 📖 **Learn:** Lessons 8.4–8.5
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 19: Python 08 venv & pip"`

## Day 20 — Python 09 · OOP (1/2)

**🎯 Goal:** Create classes, objects and use inheritance.  
**📂 Module:** [1-python/09-oop](1-python/09-oop/README.md)

- [ ] 🔁 **Warm-up (10 min):** Create a fresh venv in /tmp, install `requests`, `pip freeze`, then delete it.
- [ ] 📖 **Learn:** Lessons 9.1–9.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 20: Python 09 OOP (1/2)"`

## Day 21 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 22 — Python 09 · OOP (2/2)

**🎯 Goal:** Use properties, classmethods and dataclasses.  
**📂 Module:** [1-python/09-oop](1-python/09-oop/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a `Server` class with `start()`/`stop()` and a `__str__` from memory.
- [ ] 📖 **Learn:** Lessons 9.5–9.7
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 22: Python 09 OOP (2/2)"`

## Day 23 — Python 10 · System automation (1/3)

**🎯 Goal:** Work with paths, env vars and shutil.  
**📂 Module:** [1-python/10-system-automation](1-python/10-system-automation/README.md)

- [ ] 🔁 **Warm-up (10 min):** Convert yesterday's `Server` class into a `@dataclass`.
- [ ] 📖 **Learn:** Lessons 10.1–10.3
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 23: Python 10 System automation (1/3)"`

## Day 24 — Python 10 · System automation (2/3)

**🎯 Goal:** Run shell commands safely with subprocess.  
**📂 Module:** [1-python/10-system-automation](1-python/10-system-automation/README.md)

- [ ] 🔁 **Warm-up (10 min):** List all `.py` files under the course with `Path(...).rglob` and print their sizes.
- [ ] 📖 **Learn:** Lessons 10.4 and 10.7
- [ ] 🧪 **Practice:** Labs 2–3
- [ ] 💾 **Save:** `git commit -m "Day 24: Python 10 System automation (2/3)"`

## Day 25 — Python 10 · System automation (3/3)

**🎯 Goal:** Build a real CLI with argparse + logging.  
**📂 Module:** [1-python/10-system-automation](1-python/10-system-automation/README.md)

- [ ] 🔁 **Warm-up (10 min):** Run `df -h /` with `subprocess.run([...], capture_output=True, text=True, check=True, timeout=10)`.
- [ ] 📖 **Learn:** Lessons 10.5–10.6
- [ ] 🧪 **Practice:** Lab 4
- [ ] 💾 **Save:** `git commit -m "Day 25: Python 10 System automation (3/3)"`

## Day 26 — Python 11 · JSON, YAML & CSV

**🎯 Goal:** Read and write the formats DevOps runs on.  
**📂 Module:** [1-python/11-data-formats](1-python/11-data-formats/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a 3-option argparse CLI (`--env`, `--dry-run`, `-v`) and run `--help`.
- [ ] 📖 **Learn:** Lessons 11.1–11.3
- [ ] 🧪 **Practice:** Labs 1–3
- [ ] 💾 **Save:** `git commit -m "Day 26: Python 11 JSON, YAML & CSV"`

## Day 27 — Python 11 · Regex

**🎯 Goal:** Parse logs with named-group regular expressions.  
**📂 Module:** [1-python/11-data-formats](1-python/11-data-formats/README.md)

- [ ] 🔁 **Warm-up (10 min):** Load `data/deployment.yaml` with `yaml.safe_load` and print every container image.
- [ ] 📖 **Learn:** Lesson 11.4
- [ ] 🧪 **Practice:** Lab 4
- [ ] 💾 **Save:** `git commit -m "Day 27: Python 11 Regex"`

## Day 28 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 29 — Python 12 · REST APIs (1/3)

**🎯 Goal:** Call APIs with requests, timeouts and status checks.  
**📂 Module:** [1-python/12-apis-and-cloud](1-python/12-apis-and-cloud/README.md)

- [ ] 🔁 **Warm-up (10 min):** Regex: extract every IPv4 address from `data/access.log` with `re.findall`.
- [ ] 📖 **Learn:** Lessons 12.1–12.3
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 29: Python 12 REST APIs (1/3)"`

## Day 30 — Python 12 · REST APIs (2/3)

**🎯 Goal:** Pagination, urllib, and your own health endpoint.  
**📂 Module:** [1-python/12-apis-and-cloud](1-python/12-apis-and-cloud/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain the difference between 4xx and 5xx, and which ones you should retry.
- [ ] 📖 **Learn:** Lessons 12.4–12.6
- [ ] 🧪 **Practice:** Labs 2–3
- [ ] 💾 **Save:** `git commit -m "Day 30: Python 12 REST APIs (2/3)"`

## Day 31 — Python 12 · Cloud with boto3 (3/3)

**🎯 Goal:** Take your first steps with AWS from Python.  
**📂 Module:** [1-python/12-apis-and-cloud](1-python/12-apis-and-cloud/README.md)

- [ ] 🔁 **Warm-up (10 min):** `curl -i localhost:8000/health` against your Lab 3 server — read every header.
- [ ] 📖 **Learn:** Lesson 12.7
- [ ] 🧪 **Practice:** Lab 4 (needs a free-tier AWS account — if you don't have one, redo Lab 2 adding retries with `HTTPAdapter`)
- [ ] 💾 **Save:** `git commit -m "Day 31: Python 12 Cloud with boto3 (3/3)"`

## Day 32 — Python 13 · Testing with pytest

**🎯 Goal:** Write tests with parametrize, fixtures and mocks.  
**📂 Module:** [1-python/13-testing-and-quality](1-python/13-testing-and-quality/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a `requests.get` call with a timeout, `raise_for_status()`, and error handling.
- [ ] 📖 **Learn:** Lessons 13.1–13.4
- [ ] 🧪 **Practice:** Labs 1–3
- [ ] 💾 **Save:** `git commit -m "Day 32: Python 13 Testing with pytest"`

## Day 33 — Python 13 · Code quality & CI

**🎯 Goal:** Type-check, lint, and run everything in CI.  
**📂 Module:** [1-python/13-testing-and-quality](1-python/13-testing-and-quality/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write one parametrized pytest test for `is_valid_port` from memory.
- [ ] 📖 **Learn:** Lessons 13.5–13.8
- [ ] 🧪 **Practice:** Lab 4
- [ ] 💾 **Save:** `git commit -m "Day 33: Python 13 Code quality & CI"`

## Day 34 — Python 14 · Advanced (1/3): generators

**🎯 Goal:** Stream huge files with generators; use collections.  
**📂 Module:** [1-python/14-advanced-python](1-python/14-advanced-python/README.md)

- [ ] 🔁 **Warm-up (10 min):** Run `ruff check` and `mypy` on one of your Module 10 scripts; fix one finding.
- [ ] 📖 **Learn:** Lessons 14.1–14.2
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 34: Python 14 Advanced (1/3): generators"`

## Day 35 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 36 — Python 14 · Advanced (2/3): decorators & context managers

**🎯 Goal:** Write @retry, @timed and your own `with` blocks.  
**📂 Module:** [1-python/14-advanced-python](1-python/14-advanced-python/README.md)

- [ ] 🔁 **Warm-up (10 min):** Use `Counter` to count status codes in `11-data-formats/data/access.log`.
- [ ] 📖 **Learn:** Lessons 14.3–14.4
- [ ] 🧪 **Practice:** Labs 2–3
- [ ] 💾 **Save:** `git commit -m "Day 36: Python 14 Advanced (2/3): decorators & context managers"`

## Day 37 — Python 14 · Advanced (3/3): concurrency & packaging

**🎯 Goal:** Go concurrent and ship a real command.  
**📂 Module:** [1-python/14-advanced-python](1-python/14-advanced-python/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a `@timed` decorator from memory (remember `functools.wraps`).
- [ ] 📖 **Learn:** Lessons 14.5–14.8
- [ ] 🧪 **Practice:** Labs 4–5
- [ ] 💾 **Save:** `git commit -m "Day 37: Python 14 Advanced (3/3): concurrency & packaging"`

## Day 38 — Python 15 · Capstone: study healthmon

**🎯 Goal:** Understand a production-style tool end to end.  
**📂 Module:** [1-python/15-capstone](1-python/15-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain threads vs processes vs asyncio in 3 sentences.
- [ ] 📖 **Learn:** Project 1 — read every line of `solutions/healthmon/`, run it and its tests
- [ ] 🧪 **Practice:** Add one feature to healthmon (e.g. a `dns` check type) with a test
- [ ] 💾 **Save:** `git commit -m "Day 38: Python 15 Capstone: study healthmon"`

## Day 39 — Python 15 · Capstone: logwatch (1/2)

**🎯 Goal:** Build your own tool from a spec.  
**📂 Module:** [1-python/15-capstone](1-python/15-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a generator that yields only ERROR lines from a file.
- [ ] 📖 **Learn:** Project 2 spec
- [ ] 🧪 **Practice:** Build the parser, counters and `--format table`
- [ ] 💾 **Save:** `git commit -m "Day 39: Python 15 Capstone: logwatch (1/2)"`

## Day 40 — Python 15 · Capstone: logwatch (2/2)

**🎯 Goal:** Finish, test and document your tool.  
**📂 Module:** [1-python/15-capstone](1-python/15-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a `@contextmanager` timer from memory.
- [ ] 📖 **Learn:** Project 2 spec
- [ ] 🧪 **Practice:** Add `--since`, `--format json|csv`, the 5xx alert exit code, tests and a README
- [ ] 💾 **Save:** `git commit -m "Day 40: Python 15 Capstone: logwatch (2/2)"`

## Day 41 — Python 15 · Capstone: backupctl or deployer (1/2)

**🎯 Goal:** Plan and build a bigger tool.  
**📂 Module:** [1-python/15-capstone](1-python/15-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** argparse subcommands: sketch `tool create|verify|prune` from memory.
- [ ] 📖 **Learn:** Project 3 or 4 spec — pick one
- [ ] 🧪 **Practice:** Subcommands skeleton + the core feature
- [ ] 💾 **Save:** `git commit -m "Day 41: Python 15 Capstone: backupctl or deployer (1/2)"`

## Day 42 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 43 — Python 15 · Capstone: backupctl or deployer (2/2)

**🎯 Goal:** Finish with tests, CI and a README.  
**📂 Module:** [1-python/15-capstone](1-python/15-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a pytest test that mocks `subprocess.run`.
- [ ] 📖 **Learn:** Same project
- [ ] 🧪 **Practice:** Finish it, add a GitHub Actions workflow, push it
- [ ] 💾 **Save:** `git commit -m "Day 43: Python 15 Capstone: backupctl or deployer (2/2)"`

## Day 44 — Python 15 · Python graduation

**🎯 Goal:** Prove you're at expert level.  
**📂 Module:** [1-python/15-capstone](1-python/15-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain your capstone to an imaginary interviewer in 2 minutes (out loud!).
- [ ] 📖 **Learn:** The Python expert checklist in `1-python/README.md`
- [ ] 🧪 **Practice:** Tick every box. Any you can't? Redo that module's hardest lab today.
- [ ] 💾 **Save:** `git commit -m "Day 44: Python 15 Python graduation"`

## Day 45 — Shell 01 · Terminal (1/2)

**🎯 Goal:** Move around and manage files confidently.  
**📂 Module:** [2-shell-scripting/01-terminal-essentials](2-shell-scripting/01-terminal-essentials/README.md)

- [ ] 🔁 **Warm-up (10 min):** Python warm-down: list the 5 core Python types from memory.
- [ ] 📖 **Learn:** Lessons 1.1–1.5
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 45: Shell 01 Terminal (1/2)"`

## Day 46 — Shell 01 · Terminal (2/2)

**🎯 Goal:** Permissions, sudo, help and system info.  
**📂 Module:** [2-shell-scripting/01-terminal-essentials](2-shell-scripting/01-terminal-essentials/README.md)

- [ ] 🔁 **Warm-up (10 min):** Create `a/b/c`, a file in it, copy, rename, and delete it — all from memory.
- [ ] 📖 **Learn:** Lessons 1.6–1.9
- [ ] 🧪 **Practice:** Labs 2–4
- [ ] 💾 **Save:** `git commit -m "Day 46: Shell 01 Terminal (2/2)"`

## Day 47 — Shell 02 · First script (1/2)

**🎯 Goal:** Write and run your first `#!/bin/sh` script.  
**📂 Module:** [2-shell-scripting/02-first-script](2-shell-scripting/02-first-script/README.md)

- [ ] 🔁 **Warm-up (10 min):** What do `chmod 755` and `chmod 600` mean? Say each permission out loud.
- [ ] 📖 **Learn:** Lessons 2.1–2.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 47: Shell 02 First script (1/2)"`

## Day 48 — Shell 02 · First script (2/2)

**🎯 Goal:** Exit codes, heredocs, PATH and the script template.  
**📂 Module:** [2-shell-scripting/02-first-script](2-shell-scripting/02-first-script/README.md)

- [ ] 🔁 **Warm-up (10 min):** `printf` a 2-column aligned table of 3 servers and their CPU %.
- [ ] 📖 **Learn:** Lessons 2.5–2.8
- [ ] 🧪 **Practice:** Labs 3–5
- [ ] 💾 **Save:** `git commit -m "Day 48: Shell 02 First script (2/2)"`

## Day 49 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 50 — Shell 03 · Variables & quoting

**🎯 Goal:** Master quoting — the #1 shell lesson.  
**📂 Module:** [2-shell-scripting/03-variables-input-args](2-shell-scripting/03-variables-input-args/README.md)

- [ ] 🔁 **Warm-up (10 min):** Run `ls /nope; echo $?` then `true && echo yes || echo no`. Explain both.
- [ ] 📖 **Learn:** Lessons 3.1–3.4
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 50: Shell 03 Variables & quoting"`

## Day 51 — Shell 03 · Input, arguments & maths

**🎯 Goal:** Make scripts reusable with arguments.  
**📂 Module:** [2-shell-scripting/03-variables-input-args](2-shell-scripting/03-variables-input-args/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain why `rm -rf $dir/*` is dangerous and write the safe version.
- [ ] 📖 **Learn:** Lessons 3.5–3.7
- [ ] 🧪 **Practice:** Labs 2–5
- [ ] 💾 **Save:** `git commit -m "Day 51: Shell 03 Input, arguments & maths"`

## Day 52 — Shell 04 · Conditionals (1/2)

**🎯 Goal:** Test strings, numbers and files with `[ ]`.  
**📂 Module:** [2-shell-scripting/04-conditionals](2-shell-scripting/04-conditionals/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a script that prints `Usage:` to stderr and exits 2 when `$#` is 0.
- [ ] 📖 **Learn:** Lessons 4.1–4.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 52: Shell 04 Conditionals (1/2)"`

## Day 53 — Shell 04 · Conditionals (2/2)

**🎯 Goal:** Combine tests, use commands as conditions and `case`.  
**📂 Module:** [2-shell-scripting/04-conditionals](2-shell-scripting/04-conditionals/README.md)

- [ ] 🔁 **Warm-up (10 min):** From memory: the 6 number operators (`-eq` …) and 5 file tests (`-f` …).
- [ ] 📖 **Learn:** Lessons 4.5–4.8
- [ ] 🧪 **Practice:** Labs 3–5
- [ ] 💾 **Save:** `git commit -m "Day 53: Shell 04 Conditionals (2/2)"`

## Day 54 — Shell 05 · Loops (1/2)

**🎯 Goal:** Loop over lists, files and counters; wait & retry.  
**📂 Module:** [2-shell-scripting/05-loops](2-shell-scripting/05-loops/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a `case` that handles `start|stop|restart` and prints usage otherwise.
- [ ] 📖 **Learn:** Lessons 5.1–5.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 54: Shell 05 Loops (1/2)"`

## Day 55 — Shell 05 · Loops (2/2)

**🎯 Goal:** Read files line by line the correct way.  
**📂 Module:** [2-shell-scripting/05-loops](2-shell-scripting/05-loops/README.md)

- [ ] 🔁 **Warm-up (10 min):** An `until` loop that waits for `/tmp/ready` to exist (create it from another terminal).
- [ ] 📖 **Learn:** Lessons 5.5–5.7
- [ ] 🧪 **Practice:** Labs 3–5
- [ ] 💾 **Save:** `git commit -m "Day 55: Shell 05 Loops (2/2)"`

## Day 56 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 57 — Shell 06 · Functions (1/2)

**🎯 Goal:** Write functions that return status and data.  
**📂 Module:** [2-shell-scripting/06-functions](2-shell-scripting/06-functions/README.md)

- [ ] 🔁 **Warm-up (10 min):** From memory: `while IFS= read -r line; do ... done < file` skipping `#` comments.
- [ ] 📖 **Learn:** Lessons 6.1–6.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 57: Shell 06 Functions (1/2)"`

## Day 58 — Shell 06 · Functions (2/2)

**🎯 Goal:** Build a logging library and the main pattern.  
**📂 Module:** [2-shell-scripting/06-functions](2-shell-scripting/06-functions/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write `is_number` using only `case`.
- [ ] 📖 **Learn:** Lessons 6.5–6.7
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 58: Shell 06 Functions (2/2)"`

## Day 59 — Shell 07 · Pipes & the core toolkit

**🎯 Goal:** Redirect output and chain commands.  
**📂 Module:** [2-shell-scripting/07-pipes-and-text-processing](2-shell-scripting/07-pipes-and-text-processing/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write `log()` and `die()` helpers that print to stderr with a timestamp.
- [ ] 📖 **Learn:** Lessons 7.1–7.3
- [ ] 🧪 **Practice:** Lab 4 parts 1–3
- [ ] 💾 **Save:** `git commit -m "Day 59: Shell 07 Pipes & the core toolkit"`

## Day 60 — Shell 07 · grep & sed

**🎯 Goal:** Search and edit text like a pro.  
**📂 Module:** [2-shell-scripting/07-pipes-and-text-processing](2-shell-scripting/07-pipes-and-text-processing/README.md)

- [ ] 🔁 **Warm-up (10 min):** Top 3 IPs in `data/access.log` — the famous `cut | sort | uniq -c | sort -rn | head` one-liner.
- [ ] 📖 **Learn:** Lessons 7.4–7.5
- [ ] 🧪 **Practice:** Labs 1–3
- [ ] 💾 **Save:** `git commit -m "Day 60: Shell 07 grep & sed"`

## Day 61 — Shell 07 · awk & jq

**🎯 Goal:** Sum, group and report with awk.  
**📂 Module:** [2-shell-scripting/07-pipes-and-text-processing](2-shell-scripting/07-pipes-and-text-processing/README.md)

- [ ] 🔁 **Warm-up (10 min):** With sed, mask the password in `data/app.conf` (no `-i`).
- [ ] 📖 **Learn:** Lessons 7.6–7.7
- [ ] 🧪 **Practice:** Labs 4 (rest) and 5
- [ ] 💾 **Save:** `git commit -m "Day 61: Shell 07 awk & jq"`

## Day 62 — Shell 08 · Errors (1/2)

**🎯 Goal:** Use `set -eu`, exit codes and `trap`.  
**📂 Module:** [2-shell-scripting/08-exit-codes-and-errors](2-shell-scripting/08-exit-codes-and-errors/README.md)

- [ ] 🔁 **Warm-up (10 min):** awk: total bytes (column 10) in `access.log` from memory.
- [ ] 📖 **Learn:** Lessons 8.1–8.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 62: Shell 08 Errors (1/2)"`

## Day 63 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 64 — Shell 08 · Errors (2/2)

**🎯 Goal:** Debug, lock and retry.  
**📂 Module:** [2-shell-scripting/08-exit-codes-and-errors](2-shell-scripting/08-exit-codes-and-errors/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a script that makes a `mktemp -d` dir and always deletes it via `trap ... EXIT`.
- [ ] 📖 **Learn:** Lessons 8.5–8.7
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 64: Shell 08 Errors (2/2)"`

## Day 65 — Shell 09 · Processes & signals

**🎯 Goal:** Inspect, background, parallelise and signal processes.  
**📂 Module:** [2-shell-scripting/09-processes-and-scheduling](2-shell-scripting/09-processes-and-scheduling/README.md)

- [ ] 🔁 **Warm-up (10 min):** Run any script with `sh -x` and read the trace line by line.
- [ ] 📖 **Learn:** Lessons 9.1–9.4
- [ ] 🧪 **Practice:** Labs 1–3
- [ ] 💾 **Save:** `git commit -m "Day 65: Shell 09 Processes & signals"`

## Day 66 — Shell 09 · cron & systemd

**🎯 Goal:** Schedule jobs the right way.  
**📂 Module:** [2-shell-scripting/09-processes-and-scheduling](2-shell-scripting/09-processes-and-scheduling/README.md)

- [ ] 🔁 **Warm-up (10 min):** Start `sleep 300 &`, find its PID 2 different ways, stop it with SIGTERM.
- [ ] 📖 **Learn:** Lessons 9.5–9.7
- [ ] 🧪 **Practice:** Labs 4–5
- [ ] 💾 **Save:** `git commit -m "Day 66: Shell 09 cron & systemd"`

## Day 67 — Shell 10 · Capstone: docker-entrypoint

**🎯 Goal:** Understand a production entrypoint script.  
**📂 Module:** [2-shell-scripting/10-capstone](2-shell-scripting/10-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a cron line for 02:30 every day, logging to a file, with `flock`.
- [ ] 📖 **Learn:** Project 1 — read the reference solution and its test runner
- [ ] 🧪 **Practice:** Rebuild it yourself without looking; run `sh test_entrypoint.sh` against yours
- [ ] 💾 **Save:** `git commit -m "Day 67: Shell 10 Capstone: docker-entrypoint"`

## Day 68 — Shell 10 · Capstone: sysinfo / logclean

**🎯 Goal:** Build a portable tool from a spec.  
**📂 Module:** [2-shell-scripting/10-capstone](2-shell-scripting/10-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain what `exec "$@"` does in an entrypoint.
- [ ] 📖 **Learn:** Project 2 or 3 spec
- [ ] 🧪 **Practice:** Build it; zero `shellcheck -s sh` warnings; test it with `dash`
- [ ] 💾 **Save:** `git commit -m "Day 68: Shell 10 Capstone: sysinfo / logclean"`

## Day 69 — Shell 10 · Shell graduation

**🎯 Goal:** Prove you're at expert level.  
**📂 Module:** [2-shell-scripting/10-capstone](2-shell-scripting/10-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** List 6 Bash-only features you must NOT use in `#!/bin/sh` scripts.
- [ ] 📖 **Learn:** The Shell expert checklist in `2-shell-scripting/README.md`
- [ ] 🧪 **Practice:** Project 4 (installer) — or redo the lab you found hardest
- [ ] 💾 **Save:** `git commit -m "Day 69: Shell 10 Shell graduation"`

## Day 70 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 71 — Bash 01 · From sh to Bash (1/2)

**🎯 Goal:** Use `[[ ]]`, `(( ))` and easy loops.  
**📂 Module:** [3-bash/01-from-sh-to-bash](3-bash/01-from-sh-to-bash/README.md)

- [ ] 🔁 **Warm-up (10 min):** Shell warm-down: read a CSV with `while IFS=, read -r` from memory.
- [ ] 📖 **Learn:** Lessons 1.1–1.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 71: Bash 01 From sh to Bash (1/2)"`

## Day 72 — Bash 01 · From sh to Bash (2/2)

**🎯 Goal:** Better read, here-strings, process substitution.  
**📂 Module:** [3-bash/01-from-sh-to-bash](3-bash/01-from-sh-to-bash/README.md)

- [ ] 🔁 **Warm-up (10 min):** Rewrite a POSIX `while [ "$i" -le 5 ]` loop as a Bash `for (( ))` loop.
- [ ] 📖 **Learn:** Lessons 1.5–1.8
- [ ] 🧪 **Practice:** Labs 3–5
- [ ] 💾 **Save:** `git commit -m "Day 72: Bash 01 From sh to Bash (2/2)"`

## Day 73 — Bash 02 · Arrays

**🎯 Goal:** Use indexed and associative arrays.  
**📂 Module:** [3-bash/02-arrays-and-strings](3-bash/02-arrays-and-strings/README.md)

- [ ] 🔁 **Warm-up (10 min):** Use `=~` and `BASH_REMATCH` to pull the number out of `web-42`.
- [ ] 📖 **Learn:** Lessons 2.1–2.2
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 73: Bash 02 Arrays"`

## Day 74 — Bash 02 · String manipulation

**🎯 Goal:** Parameter expansion instead of sed/cut/basename.  
**📂 Module:** [3-bash/02-arrays-and-strings](3-bash/02-arrays-and-strings/README.md)

- [ ] 🔁 **Warm-up (10 min):** Count log levels with `declare -A` from memory.
- [ ] 📖 **Learn:** Lessons 2.3–2.7
- [ ] 🧪 **Practice:** Labs 3–5
- [ ] 💾 **Save:** `git commit -m "Day 74: Bash 02 String manipulation"`

## Day 75 — Bash 03 · Functions & local

**🎯 Goal:** Bash functions with `local` and return values.  
**📂 Module:** [3-bash/03-functions-and-libraries](3-bash/03-functions-and-libraries/README.md)

- [ ] 🔁 **Warm-up (10 min):** From `/opt/app/api-v2.tar.gz` get dir, file, name without extension — expansion only.
- [ ] 📖 **Learn:** Lessons 3.1–3.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 75: Bash 03 Functions & local"`

## Day 76 — Bash 03 · Libraries

**🎯 Goal:** Shared logging libraries with `BASH_SOURCE`.  
**📂 Module:** [3-bash/03-functions-and-libraries](3-bash/03-functions-and-libraries/README.md)

- [ ] 🔁 **Warm-up (10 min):** Why is `local x=$(cmd)` a problem under `set -e`? Write the safe version.
- [ ] 📖 **Learn:** Lessons 3.5–3.7
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 76: Bash 03 Libraries"`

## Day 77 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 78 — Bash 04 · Strict mode

**🎯 Goal:** `set -euo pipefail` and its gotchas.  
**📂 Module:** [3-bash/04-strict-mode-and-debugging](3-bash/04-strict-mode-and-debugging/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a function library file and `source` it via `SCRIPT_DIR`.
- [ ] 📖 **Learn:** Lessons 4.1–4.3
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 78: Bash 04 Strict mode"`

## Day 79 — Bash 04 · Traps, debugging, locks

**🎯 Goal:** ERR traps with line numbers, PS4, flock, retry.  
**📂 Module:** [3-bash/04-strict-mode-and-debugging](3-bash/04-strict-mode-and-debugging/README.md)

- [ ] 🔁 **Warm-up (10 min):** Show that `(( i++ ))` with i=0 kills a `set -e` script, then fix it.
- [ ] 📖 **Learn:** Lessons 4.4–4.7
- [ ] 🧪 **Practice:** Labs 2–4
- [ ] 💾 **Save:** `git commit -m "Day 79: Bash 04 Traps, debugging, locks"`

## Day 80 — Bash 05 · SSH keys & config

**🎯 Goal:** Key-based login and `~/.ssh/config` aliases.  
**📂 Module:** [3-bash/05-remote-servers-ssh](3-bash/05-remote-servers-ssh/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write `trap 'echo "line $LINENO failed"' ERR` into a script and trigger it.
- [ ] 📖 **Learn:** Lessons 5.1–5.3
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 80: Bash 05 SSH keys & config"`

## Day 81 — Bash 05 · Remote commands & rsync

**🎯 Goal:** Run things remotely and sync files safely.  
**📂 Module:** [3-bash/05-remote-servers-ssh](3-bash/05-remote-servers-ssh/README.md)

- [ ] 🔁 **Warm-up (10 min):** From memory: `ssh -o BatchMode=yes -o ConnectTimeout=5 lab 'uptime'`. Explain both options.
- [ ] 📖 **Learn:** Lessons 5.4–5.5
- [ ] 🧪 **Practice:** Labs 2–3
- [ ] 💾 **Save:** `git commit -m "Day 81: Bash 05 Remote commands & rsync"`

## Day 82 — Bash 05 · Fleet operations & security

**🎯 Goal:** Operate many servers in parallel, securely.  
**📂 Module:** [3-bash/05-remote-servers-ssh](3-bash/05-remote-servers-ssh/README.md)

- [ ] 🔁 **Warm-up (10 min):** `rsync --dry-run` a folder to `lab:/tmp/x/` — then explain the trailing-slash rule.
- [ ] 📖 **Learn:** Lessons 5.6–5.7
- [ ] 🧪 **Practice:** Lab 4
- [ ] 💾 **Save:** `git commit -m "Day 82: Bash 05 Fleet operations & security"`

## Day 83 — Bash 06 · Script skeleton & backups

**🎯 Goal:** The professional skeleton and backups.  
**📂 Module:** [3-bash/06-real-devops-scripts](3-bash/06-real-devops-scripts/README.md)

- [ ] 🔁 **Warm-up (10 min):** Why must `ssh` inside `while read` use `-n`? Demonstrate the bug.
- [ ] 📖 **Learn:** Lessons 6.1–6.2
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 83: Bash 06 Script skeleton & backups"`

## Day 84 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 85 — Bash 06 · Logs & health checks

**🎯 Goal:** Rotate logs and check HTTP endpoints.  
**📂 Module:** [3-bash/06-real-devops-scripts](3-bash/06-real-devops-scripts/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write the `run()` dry-run wrapper from memory.
- [ ] 📖 **Learn:** Lessons 6.3–6.4
- [ ] 🧪 **Practice:** Labs 2–3
- [ ] 💾 **Save:** `git commit -m "Day 85: Bash 06 Logs & health checks"`

## Day 86 — Bash 06 · Deploys & bootstrap

**🎯 Goal:** Release folders, rollback, idempotent setup.  
**📂 Module:** [3-bash/06-real-devops-scripts](3-bash/06-real-devops-scripts/README.md)

- [ ] 🔁 **Warm-up (10 min):** `curl -s -o /dev/null -w '%{http_code}'` against a site — and add `--max-time`.
- [ ] 📖 **Learn:** Lessons 6.5–6.6
- [ ] 🧪 **Practice:** Labs 4–5
- [ ] 💾 **Save:** `git commit -m "Day 86: Bash 06 Deploys & bootstrap"`

## Day 87 — Bash 07 · Option parsing

**🎯 Goal:** `getopts` and long options like real tools.  
**📂 Module:** [3-bash/07-pro-bash](3-bash/07-pro-bash/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain how `ln -sfn` + `mv -T` gives an atomic deploy switch.
- [ ] 📖 **Learn:** Lessons 7.1–7.2
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 87: Bash 07 Option parsing"`

## Day 88 — Bash 07 · Portability & linting

**🎯 Goal:** Know sh vs Bash, ShellCheck and shfmt.  
**📂 Module:** [3-bash/07-pro-bash](3-bash/07-pro-bash/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a `getopts ":nk:h"` loop from memory.
- [ ] 📖 **Learn:** Lessons 7.3–7.4
- [ ] 🧪 **Practice:** Labs 3 and 5
- [ ] 💾 **Save:** `git commit -m "Day 88: Bash 07 Portability & linting"`

## Day 89 — Bash 07 · Testing, CI & style

**🎯 Goal:** Bats tests in CI and the team style guide.  
**📂 Module:** [3-bash/07-pro-bash](3-bash/07-pro-bash/README.md)

- [ ] 🔁 **Warm-up (10 min):** Name 5 rules from the style guide without looking.
- [ ] 📖 **Learn:** Lessons 7.5–7.8
- [ ] 🧪 **Practice:** Lab 4
- [ ] 💾 **Save:** `git commit -m "Day 89: Bash 07 Testing, CI & style"`

## Day 90 — Bash 08 · Capstone: study opsctl

**🎯 Goal:** Understand a multi-command toolkit.  
**📂 Module:** [3-bash/08-capstone](3-bash/08-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a Bats test using `run` and `[ "$status" -eq 0 ]`.
- [ ] 📖 **Learn:** Project 1 — read every file in `solutions/opsctl/`, run `bats tests/`
- [ ] 🧪 **Practice:** Add a new subcommand (e.g. `opsctl ports`) with a Bats test
- [ ] 💾 **Save:** `git commit -m "Day 90: Bash 08 Capstone: study opsctl"`

## Day 91 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 92 — Bash 08 · Capstone: server audit

**🎯 Goal:** Build a security audit tool.  
**📂 Module:** [3-bash/08-capstone](3-bash/08-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** List the SSH hardening settings from memory.
- [ ] 📖 **Learn:** Project 2 spec
- [ ] 🧪 **Practice:** Build it with PASS/WARN/FAIL output and exit codes
- [ ] 💾 **Save:** `git commit -m "Day 92: Bash 08 Capstone: server audit"`

## Day 93 — Bash 08 · Capstone: docker deploy (1/2)

**🎯 Goal:** Build a container deploy with rollback.  
**📂 Module:** [3-bash/08-capstone](3-bash/08-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a health-check `until` loop with a timeout.
- [ ] 📖 **Learn:** Project 3 spec
- [ ] 🧪 **Practice:** Deploy + health check
- [ ] 💾 **Save:** `git commit -m "Day 93: Bash 08 Capstone: docker deploy (1/2)"`

## Day 94 — Bash 08 · Capstone: docker deploy (2/2)

**🎯 Goal:** Finish rollback, locking, tests.  
**📂 Module:** [3-bash/08-capstone](3-bash/08-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain `trap ... EXIT` vs `trap ... ERR`.
- [ ] 📖 **Learn:** Project 3 spec
- [ ] 🧪 **Practice:** Rollback, `flock`, Bats tests, README
- [ ] 💾 **Save:** `git commit -m "Day 94: Bash 08 Capstone: docker deploy (2/2)"`

## Day 95 — Bash 08 · Capstone: Python + Bash

**🎯 Goal:** Ship a Python tool with a Bash wrapper + systemd timer.  
**📂 Module:** [3-bash/08-capstone](3-bash/08-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Package `devopskit` with `pip install -e .` again from memory.
- [ ] 📖 **Learn:** Project 5 spec
- [ ] 🧪 **Practice:** Build it and install the timer
- [ ] 💾 **Save:** `git commit -m "Day 95: Bash 08 Capstone: Python + Bash"`

## Day 96 — Bash 08 · 🎓 Graduation day

**🎯 Goal:** Confirm you're at expert level in all three.  
**📂 Module:** [3-bash/08-capstone](3-bash/08-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain to an imaginary interviewer: when do you use sh, Bash or Python?
- [ ] 📖 **Learn:** All three expert checklists (Python, Shell, Bash)
- [ ] 🧪 **Practice:** Any unticked box → redo that lab today. Then update your GitHub profile README to show off your capstones.
- [ ] 💾 **Save:** `git commit -m "Day 96: Bash 08 🎓 Graduation day"`

---

🎉 **You finished the bootcamp.** Keep going: Docker → Kubernetes → Terraform → Ansible → AWS certifications.
