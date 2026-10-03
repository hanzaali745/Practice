## Hint 1
`df -h` shows which file system is full; `du -sh /var/log/demo-app/* | sort -h` (or `ncdu /var/log/demo-app`) shows what fills it.

## Hint 2
Old rotated logs are safe to remove (or compress: `gzip` shrinks text logs ~10×). But that only buys time:
why are there so many, and why aren't they compressed? Read `/etc/logrotate.d/demo-app`.

## Hint 3
Fix the **policy**: rotate a small number of times (e.g. 7), `compress`, and cap the size (`maxsize 20M`). Prove it with
`logrotate -d /etc/logrotate.d/demo-app` (dry run), then run it for real with `logrotate -f /etc/logrotate.d/demo-app`.
