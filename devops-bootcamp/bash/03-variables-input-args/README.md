# Module 03 — Variables, Input & Arguments 🟢

## 🎯 Objectives
- Create and use variables (and avoid the classic spacing mistake)
- Master **quoting**: `"double"`, `'single'`, and why you always quote `"$var"`
- Use environment variables and `export`
- Read user input with `read`
- Handle script arguments: `$1`, `$#`, `$@`, `shift`
- Use default values `${var:-default}` and required values `${var:?error}`
- Do arithmetic with `$(( ))`

## 🧠 Why DevOps engineers care
Scripts must be **reusable**: `./deploy.sh api prod` instead of editing the script each time.
Config comes from environment variables in Docker, Kubernetes and CI. And unquoted variables
are the #1 source of nasty Bash bugs — including deleting the wrong files.

---

## 📖 Lesson 3.1 — Variables

```bash
name="web-01"          # ✅ NO spaces around =
port=8080
# name = "web-01"      # ❌ bash runs a command called "name"

echo "$name"           # use with $
echo "${name}-backup"  # braces when text follows directly
readonly ENV="prod"    # constant — can't change
unset name             # delete a variable
```

**Naming convention:** `lower_case` for script variables, `UPPER_CASE` for environment
variables/constants.

## 📖 Lesson 3.2 — Quoting (THE most important Bash lesson)

```bash
file="my report.txt"
touch "$file"          # ✅ creates ONE file: "my report.txt"
touch $file            # ❌ creates TWO files: "my" and "report.txt" (word splitting!)

echo "Home is $HOME"   # double quotes: variables EXPAND
echo 'Home is $HOME'   # single quotes: everything LITERAL
echo "Cost: \$5"       # escape a single character
```

> 🧠 **Rule: always put variables in double quotes: `"$var"`.** The only time you leave them
> unquoted is when you *deliberately* want word splitting (rare).

Dangerous example of why this matters:
```bash
dir=""                 # imagine this came empty from a typo
rm -rf $dir/*          # ❌ becomes rm -rf /*   💀
rm -rf "${dir:?}"/*    # ✅ aborts with an error if dir is empty
```

## 📖 Lesson 3.3 — Environment variables

```bash
echo "$HOME $USER $PATH $PWD $SHELL $HOSTNAME"
env                                 # list all environment variables
printenv PATH

APP_ENV=staging                     # shell variable (only this shell)
export APP_ENV=staging              # environment variable (inherited by child processes)
DEBUG=1 ./script.sh                 # set only for that one command
```

## 📖 Lesson 3.4 — Default & required values

```bash
env="${APP_ENV:-dev}"               # use "dev" if APP_ENV is unset or empty
port="${PORT:-8080}"
: "${API_TOKEN:?API_TOKEN must be set}"   # exit with error if missing
echo "${#env}"                      # length of the string
```

## 📖 Lesson 3.5 — Reading input

```bash
read -r -p "Server name: " server
read -r -s -p "Password: " password; echo     # -s = silent (no echo)
read -r -t 10 -p "Continue? [y/N] " answer    # -t = timeout seconds
answer="${answer:-N}"
echo "You chose: $answer"
```

> Always use `read -r` (stops backslashes being interpreted).

## 📖 Lesson 3.6 — Script arguments

`./deploy.sh api prod 3`

| Variable | Value |
|----------|-------|
| `$0` | `./deploy.sh` (script name) |
| `$1`, `$2`, `$3` | `api`, `prod`, `3` |
| `$#` | `3` (number of args) |
| `"$@"` | all args as separate words ✅ |
| `"$*"` | all args as one string |
| `$$` | PID of the script |
| `$?` | exit code of the last command |

```bash
#!/usr/bin/env bash
app="$1"
env="${2:-dev}"            # default if not given
replicas="${3:-1}"
echo "Deploying $app to $env with $replicas replicas"
echo "You passed $# arguments: $*"

for arg in "$@"; do        # loop over all args (quoted!)
    echo "arg: $arg"
done
```

`shift` removes `$1` and moves everything down — useful for processing args one by one:
```bash
first="$1"; shift
echo "first=$first rest=$*"
```

Usage message pattern:
```bash
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <app> [env] [replicas]" >&2
    exit 1
fi
```

## 📖 Lesson 3.7 — Arithmetic

Bash does **integer** maths only:

```bash
a=10; b=3
echo $(( a + b ))      # 13
echo $(( a * b ))      # 30
echo $(( a / b ))      # 3 (integer!)
echo $(( a % b ))      # 1
echo $(( a ** 2 ))     # 100
(( count = a + 1 ))
(( count++ ))
echo "$count"          # 12

# Decimals → use bc or awk
echo "scale=2; 10 / 3" | bc        # 3.33
awk 'BEGIN { printf "%.2f\n", 10/3 }'
```

---

## ⚠️ Common mistakes
- Spaces around `=` in assignments
- Unquoted variables (`$file` instead of `"$file"`)
- Using `$*` instead of `"$@"`
- Expecting decimals from `$(( ))`
- Forgetting `export` so child processes don't see the variable

---

## 🧪 Labs

### Lab 1 ⭐ — Greeter
`greet.sh` asks for name and team with `read -r -p`, defaults team to `DevOps`, and prints
a greeting with the current date.

### Lab 2 ⭐ — Arguments inspector
`args.sh` prints script name, number of args, each argument on its own line (numbered),
and exits with a usage message (to stderr, exit code 1) if no args were given.
Test with: `./args.sh one "two words" three`.

### Lab 3 ⭐⭐ — Deploy command builder
`deploy.sh <app> [env] [version]` — env defaults to `dev`, version defaults to `$DEFAULT_VERSION`
env var or `latest`. Print the `docker run` command it *would* execute:
`docker run -d --name api-dev -e APP_ENV=dev registry.example.com/api:latest`

### Lab 4 ⭐⭐ — Disk calculator
`diskcalc.sh <used_gb> <total_gb>` prints integer % used **and** a 2-decimal % using `awk`,
plus free GB.

### Lab 5 ⭐⭐⭐ — Quoting challenge
Create a folder with files named `a file.txt`, `b.txt`, `c d e.txt`. Write a script that takes
a filename as `$1` and copies it to `backup/` — it must work for every file. Then deliberately
remove the quotes and observe what breaks.

---

## ✅ Checkpoint
- [ ] No spaces around `=`; I always quote `"$var"`
- [ ] I can use `$1`, `$#`, `"$@"`, `shift`, and print a usage message
- [ ] I use `${var:-default}` and `${var:?message}`

👉 Next: [Module 04 — Conditionals](../04-conditionals/README.md)
