# Module 12 — Pro Bash: getopts, ShellCheck, Portability, Testing & Style 🔴

## 🎯 Objectives
- Parse options like real Unix tools with `getopts` (and long options manually)
- Know exactly what's **Bash-only** vs **POSIX `sh`** and write portable scripts
- Use ShellCheck and `shfmt` in your editor and CI
- Unit test shell scripts with **Bats**
- Follow a team style guide and know when to switch to Python

## 🧠 Why DevOps engineers care
Senior-level shell means: scripts that behave like proper CLI tools, run in **Alpine** containers
(no Bash by default!), pass linting in CI, have tests, and that teammates can maintain.

---

## 📖 Lesson 12.1 — `getopts` (short options)

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<EOF
Usage: ${0##*/} [-v] [-n] [-e ENV] [-r REPLICAS] APP
  -e ENV       target environment (default: dev)
  -r REPLICAS  number of replicas (default: 1)
  -n           dry run
  -v           verbose
  -h           help
EOF
    exit 2
}

env="dev"; replicas=1; dry_run=false; verbose=false

while getopts ":e:r:nvh" opt; do        # leading ":" = we handle errors ourselves
    case "$opt" in                      # "e:" = -e takes an argument → $OPTARG
        e) env="$OPTARG" ;;
        r) replicas="$OPTARG" ;;
        n) dry_run=true ;;
        v) verbose=true ;;
        h) usage ;;
        :) echo "Option -$OPTARG needs a value" >&2; usage ;;
        \?) echo "Unknown option -$OPTARG" >&2; usage ;;
    esac
done
shift $(( OPTIND - 1 ))                 # remove parsed options → "$@" = remaining args

[[ $# -eq 1 ]] || usage
app="$1"
```

```bash
./deploy.sh -e prod -r 3 -nv api       # combined flags work: -nv
```

## 📖 Lesson 12.2 — Long options (`--env prod`)

`getopts` only supports short options. For long ones, use a `while/case` loop:

```bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        -e|--env)      env="${2:?--env needs a value}"; shift 2 ;;
        --env=*)       env="${1#*=}"; shift ;;
        -n|--dry-run)  dry_run=true; shift ;;
        -h|--help)     usage ;;
        --)            shift; break ;;          # end of options
        -*)            echo "Unknown option: $1" >&2; usage ;;
        *)             args+=("$1"); shift ;;   # positional
    esac
done
```

## 📖 Lesson 12.3 — POSIX `sh` vs Bash

`#!/bin/sh` is **not** Bash. On Debian/Ubuntu it's `dash`; in Alpine it's BusyBox `ash`.

| Bash-only (bashism) | POSIX equivalent |
|---------------------|------------------|
| `[[ $a == b* ]]` | `case $a in b*) ... ;; esac` |
| `[[ -f $f && -r $f ]]` | `[ -f "$f" ] && [ -r "$f" ]` |
| `(( n++ ))` / `(( a > b ))` | `n=$((n + 1))` / `[ "$a" -gt "$b" ]` |
| arrays `arr=(a b)` | positional params: `set -- a b; "$@"` |
| `declare -A` | none — use files or `case` |
| `${var,,}` / `${var^^}` | `tr '[:upper:]' '[:lower:]'` |
| `${var//a/b}` | `sed 's/a/b/g'` |
| `function f {}` | `f() {}` |
| `echo -e` | `printf` |
| `source file` | `. file` |
| `&> file` | `> file 2>&1` |
| `<<< "$str"` | `printf '%s\n' "$str" \|` |
| `set -o pipefail` | not in older POSIX (dash 0.5.11+ supports it) |
| `local` | not POSIX but supported by dash/ash/busybox |

Test portability:
```bash
dash -n script.sh                 # syntax check with a strict POSIX shell
shellcheck -s sh script.sh        # lint as POSIX sh
docker run --rm -v "$PWD:/w" alpine sh /w/script.sh    # run where it matters
```

> 🧠 **Rule of thumb:** use `#!/usr/bin/env bash` for your scripts (Bash is everywhere you control).
> Write POSIX `sh` for Docker `ENTRYPOINT`s in minimal images, installers (`curl | sh`), and git hooks
> shared across platforms.

## 📖 Lesson 12.4 — ShellCheck & shfmt everywhere

```bash
shellcheck -x script.sh           # -x follows `source`d files
shellcheck -S warning *.sh        # minimum severity
shfmt -i 4 -ci -w *.sh            # auto-format: 4-space indent, indented case
shfmt -d *.sh                     # show diff only (CI check)
```

Install the ShellCheck extension in VS Code — it underlines problems as you type.

## 📖 Lesson 12.5 — Testing with Bats

[Bats](https://github.com/bats-core/bats-core) = Bash Automated Testing System.

```bash
sudo apt install bats       # or: npm install -g bats / brew install bats-core
```

`test_bump.bats`:
```bash
#!/usr/bin/env bats

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/bump.sh"
}

@test "patch bump" {
    run "$SCRIPT" 1.4.9 patch
    [ "$status" -eq 0 ]
    [ "$output" = "1.4.10" ]
}

@test "rejects bad version" {
    run "$SCRIPT" 1.4 patch
    [ "$status" -eq 1 ]
}
```

```bash
bats test_bump.bats
```

> ⚠️ **Bats gotcha:** a bare `! some_command` line can **never** fail a test (Bash's `set -e`
> ignores commands starting with `!`). To assert that something fails, use `run ! some_command`
> (Bats 1.5+, add `bats_require_minimum_version 1.5.0` at the top of the file) or check
> `[ "$status" -ne 0 ]` after `run`. See [`solutions/test_validators.bats`](solutions/test_validators.bats).

Make scripts testable: put logic in functions and only call `main` when executed directly:
```bash
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
```
Then tests can `source script.sh` and call individual functions. (Same idea as Python's `__main__`.)

## 📖 Lesson 12.6 — CI for shell scripts

`.github/workflows/shell-ci.yml`:
```yaml
name: shell-ci
on: [push, pull_request]
jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: ShellCheck
        run: shellcheck -x $(git ls-files '*.sh')
      - name: Bats
        run: |
          sudo apt-get update && sudo apt-get install -y bats
          bats $(git ls-files '*.bats')
```

## 📖 Lesson 12.7 — Team style guide (summary of Google's Shell Style Guide + experience)

1. `#!/usr/bin/env bash` + `set -euo pipefail` at the top
2. Header comment: purpose + usage
3. 4-space indent; `then`/`do` on the same line as `if`/`for`
4. Functions for everything, `main "$@"` at the bottom
5. `local` for all function variables; `readonly` for constants; `UPPER_CASE` for constants/env
6. Always quote: `"$var"`, `"${arr[@]}"`, `"$(cmd)"`
7. `[[ ]]` over `[ ]`, `$(...)` over backticks, `(( ))` for arithmetic
8. Errors to stderr; meaningful exit codes; `usage` on bad input
9. `trap` cleanup for temp files; `mktemp` never hand-made temp names
10. `--dry-run` for anything destructive; idempotent by design
11. ShellCheck clean, `shfmt` formatted, Bats tests for logic
12. **Over ~150 lines, complex data, JSON, or API calls → use Python.**

## 📖 Lesson 12.8 — Handy pro snippets

```bash
# Script's own directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Require Bash 4+
(( BASH_VERSINFO[0] >= 4 )) || { echo "Bash 4+ required" >&2; exit 1; }

# Ask for confirmation unless -y was given
confirm() { $assume_yes && return 0; read -r -p "$1 [y/N] " a; [[ $a =~ ^[Yy]$ ]]; }

# Colour only when writing to a terminal
if [[ -t 1 ]]; then GREEN=$'\e[32m'; RESET=$'\e[0m'; else GREEN=""; RESET=""; fi

# Load .env file safely (KEY=VALUE lines)
set -a; source .env; set +a

# Timing
start=$SECONDS; do_work; echo "took $(( SECONDS - start ))s"

# Run with a timeout
timeout 30s long_command || echo "timed out or failed: $?"
```

---

## 🧪 Labs

### Lab 1 ⭐⭐ — getopts CLI
`getopts_demo.sh [-e ENV] [-r N] [-n] [-v] APP` that validates `ENV` ∈ dev/staging/prod and `N`
is a positive integer, then prints the plan. Support `-h`.

### Lab 2 ⭐⭐ — Long options
Rewrite Lab 1 to also accept `--env prod`, `--env=prod`, `--replicas 3`, `--dry-run`, `--help`, `--`.

### Lab 3 ⭐⭐⭐ — Port to POSIX
Port `disk_check.sh` from Module 04 to POSIX `sh` so it passes `dash -n`, `shellcheck -s sh`
and runs under `dash`. (No `[[ ]]`, no `(( ))`.)

### Lab 4 ⭐⭐⭐ — Bats tests
Write Bats tests for `bump.sh` (Module 07) and for `validators` functions (source the library
and test `is_valid_ip` directly). Run them with `bats`.

### Lab 5 ⭐⭐⭐ — Lint the whole course
Run `shellcheck -x` over **every** `.sh` you've written in this bootcamp and fix all findings.
Add the GitHub Actions workflow above to your repo.

---

## ✅ Checkpoint
- [ ] My scripts parse options with `getopts` or a `while/case` loop
- [ ] I know the main bashisms and can write POSIX `sh` when needed
- [ ] I lint with ShellCheck and test with Bats, in CI

👉 Next: [Module 13 — Capstone Projects](../13-capstone/README.md)
