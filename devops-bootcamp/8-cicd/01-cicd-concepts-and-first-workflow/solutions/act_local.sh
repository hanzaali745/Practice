#!/usr/bin/env bash
# act_local.sh [ACT ARGS...] — run your workflows on YOUR machine with act (https://github.com/nektos/act)
# Run it from the root of your lab repo. Examples:
#   act_local.sh                    # simulate a "push" event
#   act_local.sh pull_request       # simulate a pull request
#   act_local.sh -l                 # list the jobs act found
#   act_local.sh -j test            # run one job
set -euo pipefail
command -v act >/dev/null || { echo "install act first: see Module 01, Lesson 1.5" >&2; exit 1; }
[[ -d .github/workflows ]] || { echo "run this from the root of your lab repo" >&2; exit 1; }

# Map GitHub's "ubuntu-latest" to a Docker image that looks like a GitHub runner
exec act -P ubuntu-latest=catthehacker/ubuntu:act-24.04 "$@"
