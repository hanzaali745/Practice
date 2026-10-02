# 💪 Phase 3: Bash

> **Finish Phase 2 (Shell Scripting) first.** Everything you learned there still works in Bash.
> This phase teaches what Bash **adds** on top — and how senior engineers use it in production.

## Shell vs Bash in one picture

| You want to… | POSIX sh (Phase 2) | Bash (this phase) |
|--------------|--------------------|-------------------|
| Test a condition | `[ "$a" = "b" ]` | `[[ $a == b* ]]` (patterns, regex, `&&` inside) |
| Do maths | `n=$((n + 1))` | `(( n++ ))`, `(( a > b ))` |
| Count from 1 to 10 | `$(seq 1 10)` | `{1..10}`, `for (( i=1; i<=10; i++ ))` |
| Store a list | one string with spaces | **arrays** `servers=(web-01 web-02)` |
| Store key → value | not possible | **associative arrays** `declare -A port=([ssh]=22)` |
| Change text | `sed`, `tr` | `${name^^}`, `${path##*/}`, `${s//_/-}` |
| Ask a question | `printf "Q: "; read -r a` | `read -r -p "Q: " a` |
| Fail on pipeline errors | ❌ not available | `set -o pipefail` |
| Run code on every error | ❌ not available | `trap '...' ERR` |
| Local variables | ❌ (subshell trick) | `local name=...` |

**Rule:** Bash scripts start with `#!/usr/bin/env bash`, run with `bash script.sh` (or `./script.sh`),
and are checked with `shellcheck script.sh`.

## Modules

| # | Module | Level | You'll be able to… |
|---|--------|-------|--------------------|
| 01 | [From sh to Bash](01-from-sh-to-bash/README.md) | 🟡 | use `[[ ]]`, `(( ))`, `{1..10}`, `read -p`, here-strings |
| 02 | [Arrays & String Manipulation](02-arrays-and-strings/README.md) | 🟡 | lists, dictionaries, `${var//x/y}` |
| 03 | [Functions & Libraries](03-functions-and-libraries/README.md) | 🟡 | `local`, logging libraries, `BASH_SOURCE` |
| 04 | [Strict Mode & Debugging](04-strict-mode-and-debugging/README.md) | 🔴 | `set -euo pipefail`, `trap ERR`, `PS4` tracing |
| 05 | [Remote Servers: SSH, scp & rsync](05-remote-servers-ssh/README.md) | 🔴 | SSH keys, `~/.ssh/config`, fleet commands in parallel |
| 06 | [Real DevOps Scripts](06-real-devops-scripts/README.md) | 🔴 | backups, deploys with rollback, provisioning |
| 07 | [Pro Bash](07-pro-bash/README.md) | 🔴 | `getopts`, long options, Bats tests, CI, style guide |
| 08 | [Bash Capstone](08-capstone/README.md) | 🏆 | `opsctl` — a multi-command ops toolkit |

## How to run the solutions

```bash
cd ~/Practice/devops-bootcamp/3-bash/02-arrays-and-strings/solutions
bash port_map.sh            # or: ./port_map.sh  (they're executable)
shellcheck port_map.sh
```

## Bash cheat sheet

```bash
#!/usr/bin/env bash
set -euo pipefail

name="web-01"; echo "Host: ${name^^}"            # WEB-01
(( count = 5 + 3 )); (( count++ ))               # arithmetic
[[ $name == web-* && -f /etc/hosts ]] && echo ok # pattern + file test
[[ $ver =~ ^([0-9]+)\.([0-9]+)$ ]] && echo "${BASH_REMATCH[1]}"

servers=(web-01 web-02); servers+=(db-01)
echo "${servers[@]}" "${#servers[@]}"            # all, count
declare -A port=([ssh]=22 [https]=443); echo "${port[ssh]}"

for i in {1..5}; do echo "$i"; done
for (( i = 0; i < 3; i++ )); do echo "$i"; done
while IFS= read -r line; do echo "$line"; done < <(some_command)

f() { local x="$1"; echo "$x"; }
read -r -p "Continue? [y/N] " answer
trap 'echo "error on line $LINENO"' ERR
```

## 🏅 Bash expert checklist (you're "expert" when you can do all of these without notes)

- [ ] Explain every difference in the table above and choose sh or Bash for a given job
- [ ] Use indexed and associative arrays, always quoting `"${arr[@]}"`
- [ ] Do basename/dirname/extension/replace with parameter expansion only
- [ ] Explain the `set -e` gotchas: `(( i++ ))` when i=0, `local x=$(cmd)`, `cmd | while read`
- [ ] Use `set -euo pipefail`, `trap ... EXIT` and `trap ... ERR` with line numbers
- [ ] Parse options with `getopts` and with a long-option `while/case` loop
- [ ] Log in with SSH keys, use `~/.ssh/config`, `rsync` safely, and run a command across a fleet in parallel
- [ ] Write a deploy script with release folders, an atomic symlink switch and rollback
- [ ] Make scripts idempotent and give them a `--dry-run`
- [ ] Unit test functions with Bats, and run ShellCheck + Bats in CI
- [ ] Know when a script should be rewritten in Python (and do it, using Phase 1)

👉 Start: [Module 01 — From sh to Bash](01-from-sh-to-bash/README.md)
