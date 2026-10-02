# Shell Module 03 — Variables, Input & Arguments 🟢

## 🎯 Objectives
- Create and use variables (and avoid the classic spacing mistake)
- Master **quoting**: `"double"`, `'single'`, and why you always write `"$var"`
- Use environment variables and `export`
- Read user input with `read`
- Handle script arguments: `$1`, `$#`, `"$@"`, `shift`
- Use defaults `${var:-default}` and required values `${var:?message}`
- Do arithmetic with `$(( ))`

## 🧠 Why DevOps engineers care
Scripts must be **reusable**: `./deploy.sh api prod` instead of editing the file each time.
Docker, Kubernetes and CI pass configuration as **environment variables**. And unquoted
variables are the #1 cause of shell bugs — including deleting the wrong files.

---

## 📖 Lesson 3.1 — Variables

```sh
name="web-01"          # ✅ NO spaces around =
port=8080
# name = "web-01"      # ❌ the shell runs a command called "name" → "name: not found"

echo "$name"           # use a variable with $
echo "${name}-backup"  # use { } when text follows directly → web-01-backup
readonly ENV="prod"    # constant: can't be changed later
unset port             # delete a variable
```

**Naming:** `lower_case` for your script's variables, `UPPER_CASE` for environment variables and constants.
Letters, digits, `_`; can't start with a digit.

## 📖 Lesson 3.2 — Quoting (THE most important shell lesson)

```sh
file="my report.txt"
touch "$file"          # ✅ creates ONE file: "my report.txt"
touch $file            # ❌ creates TWO files: "my" and "report.txt"

echo "Home is $HOME"   # "double quotes": variables and $(...) ARE expanded
echo 'Home is $HOME'   # 'single quotes': NOTHING is expanded → Home is $HOME
echo "Price: \$5"      # backslash escapes one character
```

> 🧠 **Golden rule: always wrap variables in double quotes: `"$var"`.**

Why it really matters:
```sh
dir=""                 # imagine this is empty because of a typo
rm -rf $dir/*          # ❌ becomes:  rm -rf /*     💀 deletes everything
rm -rf "${dir:?}"/*    # ✅ stops with an error if dir is empty
```

## 📖 Lesson 3.3 — Environment variables

```sh
echo "$HOME $USER $PATH $PWD $SHELL"
env                                 # list all environment variables
printenv PATH                       # show one

APP_ENV=staging                     # normal variable: only this shell sees it
export APP_ENV                      # now child processes (scripts you run) see it too
export LOG_LEVEL=debug              # set + export in one line
DEBUG=1 sh myscript.sh              # set a variable for ONE command only
```

## 📖 Lesson 3.4 — Defaults and required values

```sh
env="${APP_ENV:-dev}"               # use "dev" if APP_ENV is unset or empty
port="${PORT:-8080}"
: "${API_TOKEN:?API_TOKEN must be set}"   # stop the script with this message if missing
echo "${#env}"                      # length of the text (3 for "dev")
```

(`:` is a command that does nothing — it's just a handy way to trigger the `${...:?}` check.)

## 📖 Lesson 3.5 — Reading input

In POSIX `sh` you print the question with `printf`, then `read`:

```sh
printf "Server name: "
read -r server
printf "Continue? [y/N] "
read -r answer
answer="${answer:-N}"
echo "Server=$server answer=$answer"
```

- Always use `read -r` (keeps backslashes as-is).
- `read -p "question"` is a **Bash** feature — it fails in `sh`. You'll use it in Phase 3.

Hidden input (passwords), POSIX style:
```sh
printf "Password: "
stty -echo; read -r password; stty echo
printf "\n"
```

## 📖 Lesson 3.6 — Script arguments

Running `sh deploy.sh api prod 3`:

| Variable | Value |
|----------|-------|
| `$0` | `deploy.sh` (the script name) |
| `$1`, `$2`, `$3` | `api`, `prod`, `3` |
| `$#` | `3` (how many arguments) |
| `"$@"` | all arguments, each kept separate ✅ use this |
| `"$*"` | all arguments glued into one string |
| `$$` | the script's process ID (PID) |
| `$?` | exit code of the last command |

```sh
#!/bin/sh
app="$1"
env="${2:-dev}"            # default if the 2nd argument is missing
replicas="${3:-1}"
echo "Deploying $app to $env with $replicas replicas"

for arg in "$@"; do        # loop over every argument (quoted!)
    echo "arg: $arg"
done
```

`shift` throws away `$1` and moves everything down one place:
```sh
first="$1"
shift
echo "first=$first, the rest: $*"
```

The usage-message pattern (use it in every script that needs arguments):
```sh
if [ $# -lt 1 ]; then
    echo "Usage: $0 <app> [env] [replicas]" >&2    # >&2 = print to stderr (the error channel)
    exit 2                                         # 2 = "you used it wrong"
fi
```

## 📖 Lesson 3.7 — Arithmetic

The shell does **whole-number** maths only:

```sh
a=10
b=3
echo $((a + b))      # 13
echo $((a - b))      # 7
echo $((a * b))      # 30
echo $((a / b))      # 3   (no decimals!)
echo $((a % b))      # 1   (remainder)
count=0
count=$((count + 1)) # increase a counter — the POSIX way
```

Need decimals? Use `awk` (always installed) or `bc`:
```sh
awk 'BEGIN { printf "%.2f\n", 10 / 3 }'     # 3.33
echo "scale=2; 10 / 3" | bc                  # 3.33
```

---

## ⚠️ Common mistakes
- Spaces around `=` → `name: not found`
- Unquoted `$var` → breaks on spaces, or worse
- `"$*"` instead of `"$@"`
- Expecting decimals from `$(( ))`
- Forgetting `export`, so a script you call can't see the variable
- Using Bash-only `read -p`, `$((a ** 2))`, `((count++))` in an `sh` script

---

## 🧪 Labs
Work in `~/Practice/devops-bootcamp/my-work/shell/`. Run every script with `sh` and check with `shellcheck -s sh`.

### Lab 1 ⭐ — Greeter
`greet.sh` asks for your name and team (default team: `DevOps`) and prints a welcome with today's date.

### Lab 2 ⭐ — Arguments inspector
`args.sh` prints the script name, the number of arguments, and each argument numbered on its
own line. With no arguments, print a usage message to stderr and exit with code 2.
Test: `sh args.sh one "two words" three` → must show **3** arguments.

### Lab 3 ⭐⭐ — Deploy command builder
`deploy.sh <app> [env] [version]` — `env` defaults to `dev`; `version` defaults to the
`DEFAULT_VERSION` environment variable, or `latest`. Print the command it *would* run:
`docker run -d --name api-dev -e APP_ENV=dev registry.example.com/api:latest`
Test: `DEFAULT_VERSION=1.2 sh deploy.sh api prod`

### Lab 4 ⭐⭐ — Disk calculator
`diskcalc.sh <used_gb> <total_gb>` prints the whole-number % used, a 2-decimal % (with `awk`),
and free GB. Stop with a clear message if an argument is missing (use `${1:?...}`).

### Lab 5 ⭐⭐⭐ — Quoting challenge
Create files `a file.txt`, `b.txt`, `c d e.txt`. Write `safe_copy.sh <file>` that copies the file
into `backup/`. It must work for all three. Then remove the quotes and watch it break.

---

## ✅ Checkpoint
- [ ] No spaces around `=`, and I always write `"$var"`
- [ ] I can use `$1`, `$#`, `"$@"`, `shift`, and print a usage message
- [ ] I use `${var:-default}` and `${var:?message}`
- [ ] I know `read -p` is Bash-only and how to do it in POSIX

👉 Next: [Module 04 — Conditionals](../04-conditionals/README.md)
