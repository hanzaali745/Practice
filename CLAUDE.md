# Notes for Claude — read at the start of every session

This repository holds the owner's notes and **`devops-bootcamp/`**, a 323-day DevOps course: Step 0 setup → Phases
1–12 (Python, Shell, 2B Linux administration, Bash, Docker, Kubernetes, Terraform, Ansible, CI/CD, Monitoring, ELK,
AWS, Job-ready). `devops-bootcamp/DAILY-PLAN.md` is the day-by-day plan; `sh devops-bootcamp/today.sh` tracks progress
in `devops-bootcamp/my-work/progress.log` (one `done N ...` line per finished day).

## ⏰ Standing request from the owner — check this FIRST in every session
The owner asked to be reminded to build **Phase 13 · Platform skills** (databases/PostgreSQL, secrets management with
Vault, OpenTelemetry tracing with Grafana Tempo/Loki; optional Azure/GCP, Packer, queues) **when they reach Phase 8**.
The full agreed scope is in [`devops-bootcamp/PLANNED-ADDITIONS.md`](devops-bootcamp/PLANNED-ADDITIONS.md).

At the start of a session, if `PLANNED-ADDITIONS.md` still contains `Status: PLANNED`:
1. Find their progress: number of `^done ` lines in `devops-bootcamp/my-work/progress.log` (the file may be missing = 0).
2. Find the first Phase 8 day: the `## Day N — Setup part 3` heading in `devops-bootcamp/DAILY-PLAN.md`.
3. If progress + 1 ≥ that day (or the owner says they've reached Phase 8 / CI/CD), **proactively suggest building
   Phase 13** in your first reply, in one or two sentences — then follow their answer. Don't build it unasked.
4. When an item is built, change its line to `Status: DONE` (the today.sh reminder stops when nothing is PLANNED).

## How the owner wants changes made
- **Don't remove anything.** Changes to the course are additive. If an existing line must change (e.g. day numbers when
  a phase is inserted), keep it minimal, verify no content was lost, and say exactly what changed.
- New material follows the existing format: per module a README (Objectives · Why · Lessons · Common mistakes ·
  Labs ⭐–⭐⭐⭐ · Checkpoint · Next link), a `solutions/` folder, a capstone and an expert checklist per phase.
- Test labs for real where possible (Docker), say clearly what could not be tested, run shellcheck and a link check.
- Work on a branch, commit and push; open or merge a pull request when the owner asks.
