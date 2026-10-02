# opsctl

A small ops toolkit in Bash: health checks, access-log reports, backups and cleanup.

```bash
./opsctl help
./opsctl health -s sshd
./opsctl logs-report ../../../../2-shell-scripting/07-pipes-and-text-processing/data/access.log
./opsctl backup -k 5 /etc/hosts /tmp/backups
./opsctl cleanup -n -d 7 -p '*.log' /tmp
bats tests/          # run the test suite
shellcheck -x opsctl lib/*.sh
```

Install system-wide: `sudo ln -s "$PWD/opsctl" /usr/local/bin/opsctl`
(`opsctl` resolves its own symlink to find `lib/`).
