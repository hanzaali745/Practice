# 📅 Daily Plan — learn and practise every day

> **One page, one day at a time.** About **60–90 minutes a day**. Follow the days in order.
> Every 7th day is a 🔄 **review day**. Total: **180 days** (about 26 weeks).
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
| 97–115 | Phase 4 · Docker |
| 116–137 | Phase 5 · Kubernetes |
| 138–159 | Phase 6 · Terraform |
| 160–180 | Phase 7 · Ansible |

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

## Day 96 — Bash 08 · 🎓 Graduation day (Phases 1–3)

**🎯 Goal:** Confirm you're at expert level in all three.  
**📂 Module:** [3-bash/08-capstone](3-bash/08-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain to an imaginary interviewer: when do you use sh, Bash or Python?
- [ ] 📖 **Learn:** All three expert checklists (Python, Shell, Bash)
- [ ] 🧪 **Practice:** Any unticked box → redo that lab today. Then update your GitHub profile README to show off your capstones.
- [ ] 💾 **Save:** `git commit -m "Day 96: Bash 08 🎓 Graduation day (Phases 1–3)"`

## Day 97 — Setup part 2 · Install the DevOps tools

**🎯 Goal:** Docker, kubectl, kind, Helm, Terraform and Ansible installed and checked.  
**📂 Module:** [00-ubuntu-setup/PART-2-DEVOPS-TOOLS.md](00-ubuntu-setup/PART-2-DEVOPS-TOOLS.md)

- [ ] 🔁 **Warm-up (10 min):** Explain to yourself in 3 sentences: what problem do containers solve?
- [ ] 📖 **Learn:** Part 2 of the setup guide, step by step
- [ ] 🧪 **Practice:** Run `sh 00-ubuntu-setup/check_devops_tools.sh` until everything is ✅; `docker run hello-world` works without sudo.
- [ ] 💾 **Save:** `git commit -m "Day 97: Setup part 2 Install the DevOps tools"`

## Day 98 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 99 — Docker 01 · Containers (1/2)

**🎯 Goal:** Run, list, stop and remove containers.  
**📂 Module:** [4-docker/01-containers-and-setup](4-docker/01-containers-and-setup/README.md)

- [ ] 🔁 **Warm-up (10 min):** Bash from memory: a `for` loop that pings 3 hosts with `ping -c1 -W1` and prints UP/DOWN.
- [ ] 📖 **Learn:** Lessons 1.1–1.5
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 99: Docker 01 Containers (1/2)"`

## Day 100 — Docker 01 · Containers (2/2)

**🎯 Goal:** Debug containers with logs, exec, inspect and stats.  
**📂 Module:** [4-docker/01-containers-and-setup](4-docker/01-containers-and-setup/README.md)

- [ ] 🔁 **Warm-up (10 min):** From memory: run nginx detached on port 8080 with a name, curl it, remove it.
- [ ] 📖 **Learn:** Lessons 1.6–1.8
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 100: Docker 01 Containers (2/2)"`

## Day 101 — Docker 02 · Images & registries

**🎯 Goal:** Understand layers, tags and digests; run a registry.  
**📂 Module:** [4-docker/02-images-and-registries](4-docker/02-images-and-registries/README.md)

- [ ] 🔁 **Warm-up (10 min):** `docker exec` into a running container and find its OS version and PID 1.
- [ ] 📖 **Learn:** Lessons 2.1–2.5
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 101: Docker 02 Images & registries"`

## Day 102 — Docker 02 · Registries & cleanup

**🎯 Goal:** Script registry reports, move images offline, reclaim disk.  
**📂 Module:** [4-docker/02-images-and-registries](4-docker/02-images-and-registries/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain tag vs digest. Which one would you deploy to production, and why?
- [ ] 📖 **Learn:** Lessons 2.6–2.7
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 102: Docker 02 Registries & cleanup"`

## Day 103 — Docker 03 · Dockerfile (1/2)

**🎯 Goal:** Write Dockerfiles and containerise demo-app.  
**📂 Module:** [4-docker/03-dockerfile](4-docker/03-dockerfile/README.md)

- [ ] 🔁 **Warm-up (10 min):** List 5 `docker image` / `docker system` commands from memory and what they do.
- [ ] 📖 **Learn:** Lessons 3.1–3.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 103: Docker 03 Dockerfile (1/2)"`

## Day 104 — Docker 03 · Dockerfile (2/2)

**🎯 Goal:** Master the build cache, .dockerignore, CMD vs ENTRYPOINT, ARG.  
**📂 Module:** [4-docker/03-dockerfile](4-docker/03-dockerfile/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write the demo-app Dockerfile from a blank file. Build and run it.
- [ ] 📖 **Learn:** Lessons 3.5–3.8
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 104: Docker 03 Dockerfile (2/2)"`

## Day 105 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 106 — Docker 04 · Volumes

**🎯 Goal:** Keep data with volumes and bind mounts; back them up.  
**📂 Module:** [4-docker/04-volumes-and-networking](4-docker/04-volumes-and-networking/README.md)

- [ ] 🔁 **Warm-up (10 min):** Why does exec-form `CMD ["python3", "app.py"]` stop faster than shell form?
- [ ] 📖 **Learn:** Lessons 4.1–4.4
- [ ] 🧪 **Practice:** Labs 1–3
- [ ] 💾 **Save:** `git commit -m "Day 106: Docker 04 Volumes"`

## Day 107 — Docker 04 · Networking

**🎯 Goal:** Connect containers on user networks and publish ports safely.  
**📂 Module:** [4-docker/04-volumes-and-networking](4-docker/04-volumes-and-networking/README.md)

- [ ] 🔁 **Warm-up (10 min):** Back up a named volume to a `.tar.gz` with a throwaway container — from memory.
- [ ] 📖 **Learn:** Lessons 4.5–4.7
- [ ] 🧪 **Practice:** Lab 4
- [ ] 💾 **Save:** `git commit -m "Day 107: Docker 04 Networking"`

## Day 108 — Docker 05 · Compose (1/2)

**🎯 Goal:** Define multi-container apps with healthchecks and config.  
**📂 Module:** [4-docker/05-docker-compose](4-docker/05-docker-compose/README.md)

- [ ] 🔁 **Warm-up (10 min):** Create a network, start redis on it, and `redis-cli ping` it from a second container.
- [ ] 📖 **Learn:** Lessons 5.1–5.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 108: Docker 05 Compose (1/2)"`

## Day 109 — Docker 05 · Compose (2/2)

**🎯 Goal:** Scale, load-balance and split dev/prod with override files.  
**📂 Module:** [4-docker/05-docker-compose](4-docker/05-docker-compose/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a compose service with a healthcheck and `depends_on: condition: service_healthy`.
- [ ] 📖 **Learn:** Lessons 5.5–5.7
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 109: Docker 05 Compose (2/2)"`

## Day 110 — Docker 06 · Production images (1/2)

**🎯 Goal:** Small, multi-stage, non-root images with healthchecks.  
**📂 Module:** [4-docker/06-production-images](4-docker/06-production-images/README.md)

- [ ] 🔁 **Warm-up (10 min):** `docker compose config` — explain what override files changed.
- [ ] 📖 **Learn:** Lessons 6.1–6.5
- [ ] 🧪 **Practice:** Labs 1–3
- [ ] 💾 **Save:** `git commit -m "Day 110: Docker 06 Production images (1/2)"`

## Day 111 — Docker 06 · Production images (2/2)

**🎯 Goal:** PID 1, labels, vulnerability scans and CI builds.  
**📂 Module:** [4-docker/06-production-images](4-docker/06-production-images/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a multi-stage Dockerfile for a Go hello-world from memory.
- [ ] 📖 **Learn:** Lessons 6.6–6.9
- [ ] 🧪 **Practice:** Lab 4
- [ ] 💾 **Save:** `git commit -m "Day 111: Docker 06 Production images (2/2)"`

## Day 112 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 113 — Docker 07 · Capstone: shipit (1/2)

**🎯 Goal:** Study and run a build → push → deploy tool.  
**📂 Module:** [4-docker/07-capstone](4-docker/07-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** List 6 hardening flags for `docker run` (`--read-only`, `--cap-drop`...).
- [ ] 📖 **Learn:** Project 1 — read `solutions/shipit/`, run `demo.sh`
- [ ] 🧪 **Practice:** Release two versions, then trigger an automatic rollback with the broken image
- [ ] 💾 **Save:** `git commit -m "Day 113: Docker 07 Capstone: shipit (1/2)"`

## Day 114 — Docker 07 · Capstone: shipit (2/2)

**🎯 Goal:** Make it yours.  
**📂 Module:** [4-docker/07-capstone](4-docker/07-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain how `shipit` decides to roll back.
- [ ] 📖 **Learn:** Project 1 stretch goals
- [ ] 🧪 **Practice:** Add one feature (e.g. `shipit logs` or image signing) with a test
- [ ] 💾 **Save:** `git commit -m "Day 114: Docker 07 Capstone: shipit (2/2)"`

## Day 115 — Docker 07 · Capstone: your own stack

**🎯 Goal:** Containerise something real.  
**📂 Module:** [4-docker/07-capstone](4-docker/07-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain the difference between an image, a container and a volume to a beginner.
- [ ] 📖 **Learn:** Project 2 or 3 spec
- [ ] 🧪 **Practice:** Build it, then tick the Docker expert checklist
- [ ] 💾 **Save:** `git commit -m "Day 115: Docker 07 Capstone: your own stack"`

## Day 116 — Kubernetes 01 · Concepts & cluster

**🎯 Goal:** Create a kind cluster and find your way with kubectl.  
**📂 Module:** [5-kubernetes/01-concepts-and-cluster](5-kubernetes/01-concepts-and-cluster/README.md)

- [ ] 🔁 **Warm-up (10 min):** Docker from memory: build, tag and run demo-app, then `curl /health`.
- [ ] 📖 **Learn:** Lessons 1.1–1.7
- [ ] 🧪 **Practice:** Labs 1–4
- [ ] 💾 **Save:** `git commit -m "Day 116: Kubernetes 01 Concepts & cluster"`

## Day 117 — Kubernetes 02 · Pods (1/2)

**🎯 Goal:** Write pod manifests and debug them.  
**📂 Module:** [5-kubernetes/02-pods-and-kubectl](5-kubernetes/02-pods-and-kubectl/README.md)

- [ ] 🔁 **Warm-up (10 min):** Name the control-plane components and what each one does.
- [ ] 📖 **Learn:** Lessons 2.1–2.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 117: Kubernetes 02 Pods (1/2)"`

## Day 118 — Kubernetes 02 · Pods (2/2)

**🎯 Goal:** Labels, selectors, sidecars and init containers.  
**📂 Module:** [5-kubernetes/02-pods-and-kubectl](5-kubernetes/02-pods-and-kubectl/README.md)

- [ ] 🔁 **Warm-up (10 min):** Debug drill: `describe`, `logs --previous`, `get events` — when do you use each?
- [ ] 📖 **Learn:** Lessons 2.5–2.7
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 118: Kubernetes 02 Pods (2/2)"`

## Day 119 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 120 — Kubernetes 03 · Deployments (1/2)

**🎯 Goal:** Deploy, scale and roll out new versions.  
**📂 Module:** [5-kubernetes/03-deployments-and-rollouts](5-kubernetes/03-deployments-and-rollouts/README.md)

- [ ] 🔁 **Warm-up (10 min):** Generate a pod YAML with `kubectl run --dry-run=client -o yaml`.
- [ ] 📖 **Learn:** Lessons 3.1–3.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 120: Kubernetes 03 Deployments (1/2)"`

## Day 121 — Kubernetes 03 · Deployments (2/2)

**🎯 Goal:** History, rollback and safe broken rollouts.  
**📂 Module:** [5-kubernetes/03-deployments-and-rollouts](5-kubernetes/03-deployments-and-rollouts/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain `maxSurge` and `maxUnavailable` with numbers.
- [ ] 📖 **Learn:** Lessons 3.5–3.7
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 121: Kubernetes 03 Deployments (2/2)"`

## Day 122 — Kubernetes 04 · Services

**🎯 Goal:** Stable networking and service DNS.  
**📂 Module:** [5-kubernetes/04-services-and-ingress](5-kubernetes/04-services-and-ingress/README.md)

- [ ] 🔁 **Warm-up (10 min):** `kubectl rollout undo` to a specific revision — from memory.
- [ ] 📖 **Learn:** Lessons 4.1–4.3
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 122: Kubernetes 04 Services"`

## Day 123 — Kubernetes 04 · Ingress

**🎯 Goal:** One entry point for many apps; Gateway API preview.  
**📂 Module:** [5-kubernetes/04-services-and-ingress](5-kubernetes/04-services-and-ingress/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write the full DNS name of a Service `web` in namespace `shop`.
- [ ] 📖 **Learn:** Lessons 4.4–4.5
- [ ] 🧪 **Practice:** Labs 2–4
- [ ] 💾 **Save:** `git commit -m "Day 123: Kubernetes 04 Ingress"`

## Day 124 — Kubernetes 05 · ConfigMaps & Secrets

**🎯 Goal:** Configure apps without rebuilding images.  
**📂 Module:** [5-kubernetes/05-configmaps-and-secrets](5-kubernetes/05-configmaps-and-secrets/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write an Ingress for host `demo.localtest.me` → service `demo-app:80` from memory.
- [ ] 📖 **Learn:** Lessons 5.1–5.5
- [ ] 🧪 **Practice:** Labs 1–4
- [ ] 💾 **Save:** `git commit -m "Day 124: Kubernetes 05 ConfigMaps & Secrets"`

## Day 125 — Kubernetes 06 · Storage

**🎯 Goal:** PVCs and StatefulSets for data that must survive.  
**📂 Module:** [5-kubernetes/06-storage-and-statefulsets](5-kubernetes/06-storage-and-statefulsets/README.md)

- [ ] 🔁 **Warm-up (10 min):** Why is a Secret not encrypted? Name 2 real-world fixes.
- [ ] 📖 **Learn:** Lessons 6.1–6.3
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 125: Kubernetes 06 Storage"`

## Day 126 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 127 — Kubernetes 06 · Stateful apps & backups

**🎯 Goal:** demo-app + Redis, and backup Jobs.  
**📂 Module:** [5-kubernetes/06-storage-and-statefulsets](5-kubernetes/06-storage-and-statefulsets/README.md)

- [ ] 🔁 **Warm-up (10 min):** Deployment vs StatefulSet: give 3 differences.
- [ ] 📖 **Learn:** Lessons 6.4–6.6
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 127: Kubernetes 06 Stateful apps & backups"`

## Day 128 — Kubernetes 07 · Probes & resources

**🎯 Goal:** Make pods production-ready.  
**📂 Module:** [5-kubernetes/07-probes-resources-autoscaling](5-kubernetes/07-probes-resources-autoscaling/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a CronJob schedule for 02:30 every day.
- [ ] 📖 **Learn:** Lessons 7.1–7.2
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 128: Kubernetes 07 Probes & resources"`

## Day 129 — Kubernetes 07 · Autoscaling & disruption

**🎯 Goal:** HPA, PDBs and spreading.  
**📂 Module:** [5-kubernetes/07-probes-resources-autoscaling](5-kubernetes/07-probes-resources-autoscaling/README.md)

- [ ] 🔁 **Warm-up (10 min):** Liveness vs readiness vs startup probe — what happens when each one fails?
- [ ] 📖 **Learn:** Lessons 7.3–7.5
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 129: Kubernetes 07 Autoscaling & disruption"`

## Day 130 — Kubernetes 08 · Kustomize & Helm (1/2)

**🎯 Goal:** Overlays and installing charts.  
**📂 Module:** [5-kubernetes/08-helm-and-kustomize](5-kubernetes/08-helm-and-kustomize/README.md)

- [ ] 🔁 **Warm-up (10 min):** What does a pod need for the HPA to work? (2 things)
- [ ] 📖 **Learn:** Lessons 8.1–8.2
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 130: Kubernetes 08 Kustomize & Helm (1/2)"`

## Day 131 — Kubernetes 08 · Kustomize & Helm (2/2)

**🎯 Goal:** Write your own chart and upgrade atomically.  
**📂 Module:** [5-kubernetes/08-helm-and-kustomize](5-kubernetes/08-helm-and-kustomize/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a Kustomize overlay that changes replicas and the image tag.
- [ ] 📖 **Learn:** Lessons 8.3–8.5
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 131: Kubernetes 08 Kustomize & Helm (2/2)"`

## Day 132 — Kubernetes 09 · Troubleshooting & RBAC

**🎯 Goal:** Fix broken apps fast; least-privilege access.  
**📂 Module:** [5-kubernetes/09-troubleshooting-and-security](5-kubernetes/09-troubleshooting-and-security/README.md)

- [ ] 🔁 **Warm-up (10 min):** `helm upgrade --install --atomic` — what does each flag protect you from?
- [ ] 📖 **Learn:** Lessons 9.1–9.2
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 132: Kubernetes 09 Troubleshooting & RBAC"`

## Day 133 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 134 — Kubernetes 09 · Pod security & network policies

**🎯 Goal:** Restricted pods, quotas, default-deny networking.  
**📂 Module:** [5-kubernetes/09-troubleshooting-and-security](5-kubernetes/09-troubleshooting-and-security/README.md)

- [ ] 🔁 **Warm-up (10 min):** `kubectl auth can-i` — check 3 permissions of a ServiceAccount.
- [ ] 📖 **Learn:** Lessons 9.3–9.5
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 134: Kubernetes 09 Pod security & network policies"`

## Day 135 — Kubernetes 10 · Capstone: study the platform

**🎯 Goal:** Understand a complete, hardened platform.  
**📂 Module:** [5-kubernetes/10-capstone](5-kubernetes/10-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a default-deny NetworkPolicy from memory.
- [ ] 📖 **Learn:** Project 1 — read `solutions/platform/`, run `validate.sh`
- [ ] 🧪 **Practice:** Deploy it to kind and `curl` it through the Ingress
- [ ] 💾 **Save:** `git commit -m "Day 135: Kubernetes 10 Capstone: study the platform"`

## Day 136 — Kubernetes 10 · Capstone: break & fix

**🎯 Goal:** Prove it's resilient.  
**📂 Module:** [5-kubernetes/10-capstone](5-kubernetes/10-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Draw the platform: Ingress → Service → Pods → Redis, with every policy.
- [ ] 📖 **Learn:** Project 4 (chaos day) spec
- [ ] 🧪 **Practice:** Kill pods and drain a node while a load loop runs; write down what happened
- [ ] 💾 **Save:** `git commit -m "Day 136: Kubernetes 10 Capstone: break & fix"`

## Day 137 — Kubernetes 10 · Capstone: make it yours

**🎯 Goal:** Extend it.  
**📂 Module:** [5-kubernetes/10-capstone](5-kubernetes/10-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Walk through your 5-step troubleshooting method out loud.
- [ ] 📖 **Learn:** Project 2 or 3 spec
- [ ] 🧪 **Practice:** Build it, then tick the Kubernetes expert checklist
- [ ] 💾 **Save:** `git commit -m "Day 137: Kubernetes 10 Capstone: make it yours"`

## Day 138 — Terraform 01 · First config

**🎯 Goal:** init, plan, apply, destroy — and HCL basics.  
**📂 Module:** [6-terraform/01-iac-and-first-config](6-terraform/01-iac-and-first-config/README.md)

- [ ] 🔁 **Warm-up (10 min):** kubectl from memory: create a deployment, scale it to 3, expose it.
- [ ] 📖 **Learn:** Lessons 1.1–1.6
- [ ] 🧪 **Practice:** Labs 1–4
- [ ] 💾 **Save:** `git commit -m "Day 138: Terraform 01 First config"`

## Day 139 — Terraform 02 · Resources (1/2)

**🎯 Goal:** References, the graph, depends_on, data sources.  
**📂 Module:** [6-terraform/02-resources-and-dependencies](6-terraform/02-resources-and-dependencies/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain what `terraform plan` compares (3 things).
- [ ] 📖 **Learn:** Lessons 2.1–2.4
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 139: Terraform 02 Resources (1/2)"`

## Day 140 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 141 — Terraform 02 · Resources (2/2)

**🎯 Goal:** terraform_data, lifecycle, replace — and why to avoid provisioners.  
**📂 Module:** [6-terraform/02-resources-and-dependencies](6-terraform/02-resources-and-dependencies/README.md)

- [ ] 🔁 **Warm-up (10 min):** Resource vs data source — one sentence each.
- [ ] 📖 **Learn:** Lessons 2.5–2.8
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 141: Terraform 02 Resources (2/2)"`

## Day 142 — Terraform 03 · Variables (1/2)

**🎯 Goal:** Typed, validated, sensitive inputs.  
**📂 Module:** [6-terraform/03-variables-outputs-locals](6-terraform/03-variables-outputs-locals/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a `lifecycle` block with `prevent_destroy` and `ignore_changes` from memory.
- [ ] 📖 **Learn:** Lessons 3.1–3.4
- [ ] 🧪 **Practice:** Labs 1–3
- [ ] 💾 **Save:** `git commit -m "Day 142: Terraform 03 Variables (1/2)"`

## Day 143 — Terraform 03 · Locals & outputs

**🎯 Goal:** Locals, outputs and the console.  
**📂 Module:** [6-terraform/03-variables-outputs-locals](6-terraform/03-variables-outputs-locals/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a variable with type, default and a validation block from memory.
- [ ] 📖 **Learn:** Lessons 3.5–3.8
- [ ] 🧪 **Practice:** Lab 4
- [ ] 💾 **Save:** `git commit -m "Day 143: Terraform 03 Locals & outputs"`

## Day 144 — Terraform 04 · State (1/2)

**🎯 Goal:** What state is; moved and import blocks.  
**📂 Module:** [6-terraform/04-state](6-terraform/04-state/README.md)

- [ ] 🔁 **Warm-up (10 min):** List the variable precedence order, lowest to highest.
- [ ] 📖 **Learn:** Lessons 4.1–4.3
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 144: Terraform 04 State (1/2)"`

## Day 145 — Terraform 04 · State (2/2)

**🎯 Goal:** removed blocks, drift, remote state and workspaces.  
**📂 Module:** [6-terraform/04-state](6-terraform/04-state/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a `moved` block that renames `random_pet.a` to `random_pet.name`.
- [ ] 📖 **Learn:** Lessons 4.4–4.7
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 145: Terraform 04 State (2/2)"`

## Day 146 — Terraform 05 · Loops (1/2)

**🎯 Goal:** count vs for_each and for expressions.  
**📂 Module:** [6-terraform/05-expressions-and-loops](6-terraform/05-expressions-and-loops/README.md)

- [ ] 🔁 **Warm-up (10 min):** Why must state never be committed to Git? Give 2 reasons.
- [ ] 📖 **Learn:** Lessons 5.1–5.3
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 146: Terraform 05 Loops (1/2)"`

## Day 147 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 148 — Terraform 05 · Loops (2/2)

**🎯 Goal:** Conditionals, templatefile, dynamic blocks, functions.  
**📂 Module:** [6-terraform/05-expressions-and-loops](6-terraform/05-expressions-and-loops/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain the count trap with a 3-item list where you delete the middle one.
- [ ] 📖 **Learn:** Lessons 5.4–5.7
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 148: Terraform 05 Loops (2/2)"`

## Day 149 — Terraform 06 · Modules (1/2)

**🎯 Goal:** Write and call modules with good interfaces.  
**📂 Module:** [6-terraform/06-modules](6-terraform/06-modules/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a `for` expression that turns a map into a list of `"name=value"` strings.
- [ ] 📖 **Learn:** Lessons 6.1–6.3
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 149: Terraform 06 Modules (1/2)"`

## Day 150 — Terraform 06 · Modules (2/2)

**🎯 Goal:** Registry and Git sources, environments, refactoring into modules.  
**📂 Module:** [6-terraform/06-modules](6-terraform/06-modules/README.md)

- [ ] 🔁 **Warm-up (10 min):** What belongs in a module's variables.tf, outputs.tf and versions.tf?
- [ ] 📖 **Learn:** Lessons 6.4–6.6
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 150: Terraform 06 Modules (2/2)"`

## Day 151 — Terraform 07 · Terraform + Kubernetes

**🎯 Goal:** Manage your kind cluster as code.  
**📂 Module:** [6-terraform/07-kubernetes-with-terraform](6-terraform/07-kubernetes-with-terraform/README.md)

- [ ] 🔁 **Warm-up (10 min):** Pin a module from Git to a tag — write the `source` line.
- [ ] 📖 **Learn:** Lessons 7.1–7.5
- [ ] 🧪 **Practice:** Labs 1–4
- [ ] 💾 **Save:** `git commit -m "Day 151: Terraform 07 Terraform + Kubernetes"`

## Day 152 — Terraform 08 · AWS (optional) (1/2)

**🎯 Goal:** A safe account, credentials and data sources.  
**📂 Module:** [6-terraform/08-aws-with-terraform](6-terraform/08-aws-with-terraform/README.md)

- [ ] 🔁 **Warm-up (10 min):** Who should own a Deployment: Terraform, Helm or GitOps? Argue one side.
- [ ] 📖 **Learn:** Lessons 8.1–8.3
- [ ] 🧪 **Practice:** Lab 1 (no AWS account? read the lessons and do Lab 1 as a checklist)
- [ ] 💾 **Save:** `git commit -m "Day 152: Terraform 08 AWS (optional) (1/2)"`

## Day 153 — Terraform 08 · AWS (optional) (2/2)

**🎯 Goal:** A web server and a state bucket — then destroy.  
**📂 Module:** [6-terraform/08-aws-with-terraform](6-terraform/08-aws-with-terraform/README.md)

- [ ] 🔁 **Warm-up (10 min):** Name 3 AWS cost traps and how to avoid them.
- [ ] 📖 **Learn:** Lessons 8.4–8.6
- [ ] 🧪 **Practice:** Labs 2–4 (or `terraform validate` only, without an account)
- [ ] 💾 **Save:** `git commit -m "Day 153: Terraform 08 AWS (optional) (2/2)"`

## Day 154 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 155 — Terraform 09 · Testing

**🎯 Goal:** Fast checks, terraform test and mocks.  
**📂 Module:** [6-terraform/09-workflow-testing-ci](6-terraform/09-workflow-testing-ci/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write the fast-check sequence: fmt, validate, tflint — with flags.
- [ ] 📖 **Learn:** Lessons 9.1–9.3
- [ ] 🧪 **Practice:** Labs 1–3
- [ ] 💾 **Save:** `git commit -m "Day 155: Terraform 09 Testing"`

## Day 156 — Terraform 09 · CI & promotion

**🎯 Goal:** PR pipelines, plan files and environments.  
**📂 Module:** [6-terraform/09-workflow-testing-ci](6-terraform/09-workflow-testing-ci/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a `run` block with `command = plan` and one `assert` from memory.
- [ ] 📖 **Learn:** Lessons 9.4–9.5
- [ ] 🧪 **Practice:** Lab 4
- [ ] 💾 **Save:** `git commit -m "Day 156: Terraform 09 CI & promotion"`

## Day 157 — Terraform 10 · Capstone: study the platform

**🎯 Goal:** A tested, multi-environment module.  
**📂 Module:** [6-terraform/10-capstone](6-terraform/10-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain why every environment gets its own root module and state.
- [ ] 📖 **Learn:** Project 1 — read `solutions/platform/`, run `check.sh`
- [ ] 🧪 **Practice:** Apply `live/dev` to kind and `curl` it
- [ ] 💾 **Save:** `git commit -m "Day 157: Terraform 10 Capstone: study the platform"`

## Day 158 — Terraform 10 · Capstone: extend it

**🎯 Goal:** Add a feature with a test.  
**📂 Module:** [6-terraform/10-capstone](6-terraform/10-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Draw the PR pipeline from push to apply.
- [ ] 📖 **Learn:** Project 1 stretch goals
- [ ] 🧪 **Practice:** Add one feature and a `terraform test` run for it
- [ ] 💾 **Save:** `git commit -m "Day 158: Terraform 10 Capstone: extend it"`

## Day 159 — Terraform 10 · Capstone: your own project

**🎯 Goal:** Infrastructure you'd actually use.  
**📂 Module:** [6-terraform/10-capstone](6-terraform/10-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain `moved`, `import` and `removed` blocks to a teammate.
- [ ] 📖 **Learn:** Project 2, 3 or 4 spec
- [ ] 🧪 **Practice:** Build it, then tick the Terraform expert checklist
- [ ] 💾 **Save:** `git commit -m "Day 159: Terraform 10 Capstone: your own project"`

## Day 160 — Ansible 01 · Inventory & ad-hoc (1/2)

**🎯 Goal:** Start the practice fleet and run your first commands.  
**📂 Module:** [7-ansible/01-inventory-and-adhoc](7-ansible/01-inventory-and-adhoc/README.md)

- [ ] 🔁 **Warm-up (10 min):** Terraform from memory: init, fmt, validate, plan -out, apply the plan.
- [ ] 📖 **Learn:** Lessons 1.1–1.4
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 160: Ansible 01 Inventory & ad-hoc (1/2)"`

## Day 161 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 162 — Ansible 01 · Inventory & ad-hoc (2/2)

**🎯 Goal:** Ad-hoc commands, become, facts and idempotence.  
**📂 Module:** [7-ansible/01-inventory-and-adhoc](7-ansible/01-inventory-and-adhoc/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write the fleet's inventory (groups web, db, fleet) from memory.
- [ ] 📖 **Learn:** Lessons 1.5–1.6
- [ ] 🧪 **Practice:** Labs 2–4
- [ ] 💾 **Save:** `git commit -m "Day 162: Ansible 01 Inventory & ad-hoc (2/2)"`

## Day 163 — Ansible 02 · Playbooks (1/2)

**🎯 Goal:** Plays, tasks and the core modules.  
**📂 Module:** [7-ansible/02-playbooks](7-ansible/02-playbooks/README.md)

- [ ] 🔁 **Warm-up (10 min):** Why does `command: apt-get install -y tree` always say `changed`?
- [ ] 📖 **Learn:** Lessons 2.1–2.3
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 163: Ansible 02 Playbooks (1/2)"`

## Day 164 — Ansible 02 · Playbooks (2/2)

**🎯 Goal:** Dry runs, tags, limits and the idempotence test.  
**📂 Module:** [7-ansible/02-playbooks](7-ansible/02-playbooks/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a task that installs nginx with `cache_valid_time` from memory.
- [ ] 📖 **Learn:** Lessons 2.4–2.6
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 164: Ansible 02 Playbooks (2/2)"`

## Day 165 — Ansible 03 · Variables & facts

**🎯 Goal:** group_vars, host_vars, precedence and facts.  
**📂 Module:** [7-ansible/03-variables-facts-loops](7-ansible/03-variables-facts-loops/README.md)

- [ ] 🔁 **Warm-up (10 min):** `--check --diff` — what does each flag do, and what is the check-mode gotcha?
- [ ] 📖 **Learn:** Lessons 3.1–3.2
- [ ] 🧪 **Practice:** Labs 1 and 3
- [ ] 💾 **Save:** `git commit -m "Day 165: Ansible 03 Variables & facts"`

## Day 166 — Ansible 03 · Conditions, loops & errors

**🎯 Goal:** register, when, loop, block/rescue/always.  
**📂 Module:** [7-ansible/03-variables-facts-loops](7-ansible/03-variables-facts-loops/README.md)

- [ ] 🔁 **Warm-up (10 min):** List the variable precedence order (simplified) from memory.
- [ ] 📖 **Learn:** Lessons 3.3–3.6
- [ ] 🧪 **Practice:** Labs 2 and 4
- [ ] 💾 **Save:** `git commit -m "Day 166: Ansible 03 Conditions, loops & errors"`

## Day 167 — Ansible 04 · Templates

**🎯 Goal:** Jinja2 templates and validating files.  
**📂 Module:** [7-ansible/04-templates-and-handlers](7-ansible/04-templates-and-handlers/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a `block`/`rescue`/`always` skeleton from memory.
- [ ] 📖 **Learn:** Lessons 4.1–4.2
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 167: Ansible 04 Templates"`

## Day 168 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 169 — Ansible 04 · Handlers & services

**🎯 Goal:** Handlers, systemd template units and nginx.  
**📂 Module:** [7-ansible/04-templates-and-handlers](7-ansible/04-templates-and-handlers/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a Jinja2 `for` loop that renders `server 127.0.0.1:PORT;` lines.
- [ ] 📖 **Learn:** Lessons 4.3–4.5
- [ ] 🧪 **Practice:** Labs 2–4
- [ ] 💾 **Save:** `git commit -m "Day 169: Ansible 04 Handlers & services"`

## Day 170 — Ansible 05 · Roles (1/2)

**🎯 Goal:** Role layout, defaults and using roles.  
**📂 Module:** [7-ansible/05-roles-and-collections](7-ansible/05-roles-and-collections/README.md)

- [ ] 🔁 **Warm-up (10 min):** When do handlers run, and how do you force them to run earlier?
- [ ] 📖 **Learn:** Lessons 5.1–5.3
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 170: Ansible 05 Roles (1/2)"`

## Day 171 — Ansible 05 · Roles (2/2)

**🎯 Goal:** Argument specs and collections.  
**📂 Module:** [7-ansible/05-roles-and-collections](7-ansible/05-roles-and-collections/README.md)

- [ ] 🔁 **Warm-up (10 min):** Draw a role's folder tree and say what each folder is for.
- [ ] 📖 **Learn:** Lessons 5.4–5.5
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 171: Ansible 05 Roles (2/2)"`

## Day 172 — Ansible 06 · Vault (1/2)

**🎯 Goal:** Encrypt secrets and use the vars → vault pattern.  
**📂 Module:** [7-ansible/06-vault-and-secrets](7-ansible/06-vault-and-secrets/README.md)

- [ ] 🔁 **Warm-up (10 min):** `import_role` vs `include_role` — when do you use each?
- [ ] 📖 **Learn:** Lessons 6.1–6.3
- [ ] 🧪 **Practice:** Labs 1–2
- [ ] 💾 **Save:** `git commit -m "Day 172: Ansible 06 Vault (1/2)"`

## Day 173 — Ansible 06 · Vault (2/2)

**🎯 Goal:** no_log, vault IDs, rotation and secret managers.  
**📂 Module:** [7-ansible/06-vault-and-secrets](7-ansible/06-vault-and-secrets/README.md)

- [ ] 🔁 **Warm-up (10 min):** Encrypt a string with `ansible-vault encrypt_string` from memory.
- [ ] 📖 **Learn:** Lessons 6.4–6.6
- [ ] 🧪 **Practice:** Labs 3–4
- [ ] 💾 **Save:** `git commit -m "Day 173: Ansible 06 Vault (2/2)"`

## Day 174 — Ansible 07 · Linting

**🎯 Goal:** yamllint, ansible-lint and the test pyramid.  
**📂 Module:** [7-ansible/07-testing-and-quality](7-ansible/07-testing-and-quality/README.md)

- [ ] 🔁 **Warm-up (10 min):** Name 3 ways a secret can leak from an Ansible run, and the fix for each.
- [ ] 📖 **Learn:** Lessons 7.1–7.2
- [ ] 🧪 **Practice:** Lab 1
- [ ] 💾 **Save:** `git commit -m "Day 174: Ansible 07 Linting"`

## Day 175 — 🔄 Review day

- [ ] 🔁 **Redo** the hardest lab of this week from a blank file — no peeking (30 min)
- [ ] ✅ **Re-check** the Checkpoint list of every module you studied this week
- [ ] 🧠 **Recall:** write down 10 commands/concepts from this week from memory, then check them
- [ ] 💾 **Commit & push** your week's work
- [ ] 😌 Rest — consistency beats intensity

## Day 176 — Ansible 07 · Molecule & CI

**🎯 Goal:** Role tests in containers and the quality gate.  
**📂 Module:** [7-ansible/07-testing-and-quality](7-ansible/07-testing-and-quality/README.md)

- [ ] 🔁 **Warm-up (10 min):** Fix from memory: `mode: 0644`, `copy:` without FQCN, `command` without `changed_when`.
- [ ] 📖 **Learn:** Lessons 7.3–7.4
- [ ] 🧪 **Practice:** Labs 2–4
- [ ] 💾 **Save:** `git commit -m "Day 176: Ansible 07 Molecule & CI"`

## Day 177 — Ansible 08 · Capstone: study the platform

**🎯 Goal:** A multi-tier platform with vault and tests.  
**📂 Module:** [7-ansible/08-capstone](7-ansible/08-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Write a Molecule `verify.yml` task that checks an HTTP response.
- [ ] 📖 **Learn:** Project 1 — read `solutions/platform/`, run `./check.sh --e2e`
- [ ] 🧪 **Practice:** Reset the fleet and build everything with one command; prove `changed=0`
- [ ] 💾 **Save:** `git commit -m "Day 177: Ansible 08 Capstone: study the platform"`

## Day 178 — Ansible 08 · Capstone: releases & rollback

**🎯 Goal:** Ship safely, one server at a time.  
**📂 Module:** [7-ansible/08-capstone](7-ansible/08-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** `serial` + `max_fail_percentage` — what do they do together?
- [ ] 📖 **Learn:** Project 1 — the release process
- [ ] 🧪 **Practice:** Run a good release and a bad one; explain exactly what happened on web1 and web2
- [ ] 💾 **Save:** `git commit -m "Day 178: Ansible 08 Capstone: releases & rollback"`

## Day 179 — Ansible 08 · Capstone: Terraform → Ansible

**🎯 Goal:** Provision with Terraform, configure with Ansible.  
**📂 Module:** [7-ansible/08-capstone](7-ansible/08-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain the difference between what Terraform and Ansible are best at.
- [ ] 📖 **Learn:** Project 2 spec
- [ ] 🧪 **Practice:** Generate an inventory with Terraform's `templatefile` and run your playbook against it
- [ ] 💾 **Save:** `git commit -m "Day 179: Ansible 08 Capstone: Terraform → Ansible"`

## Day 180 — Ansible 08 · 🎓 Final graduation

**🎯 Goal:** Confirm you're a DevOps engineer, end to end.  
**📂 Module:** [7-ansible/08-capstone](7-ansible/08-capstone/README.md)

- [ ] 🔁 **Warm-up (10 min):** Explain to an imaginary interviewer how demo-app goes from code to production with Docker, Kubernetes, Terraform and Ansible.
- [ ] 📖 **Learn:** All seven expert checklists (Python, Shell, Bash, Docker, Kubernetes, Terraform, Ansible)
- [ ] 🧪 **Practice:** Any unticked box → redo that lab today. Then add your four capstones to your GitHub profile README.
- [ ] 💾 **Save:** `git commit -m "Day 180: Ansible 08 🎓 Final graduation"`

---

🎉 **You finished the bootcamp.** Keep going: a cloud certification (AWS Solutions Architect Associate or CKA), GitOps with Argo CD, and monitoring with Prometheus + Grafana.
