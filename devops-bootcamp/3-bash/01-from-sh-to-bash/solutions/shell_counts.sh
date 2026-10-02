#!/usr/bin/env bash
# Lab 4 — count login shells using process substitution
set -euo pipefail

bash_users=0
nologin_users=0

while IFS=: read -r _user _pw _uid _gid _gecos _home shell; do
    if [[ $shell == */bash ]]; then
        (( ++bash_users ))
    elif [[ $shell == */nologin || $shell == */false ]]; then
        (( ++nologin_users ))
    fi
done < <(getent passwd)        # getent also includes network (LDAP) users

# These values survive because the loop did NOT run in a pipe's subshell
echo "bash users:    $bash_users"
echo "nologin users: $nologin_users"
