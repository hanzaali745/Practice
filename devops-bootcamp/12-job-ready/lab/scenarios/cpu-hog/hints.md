## Hint 1
`top` (press `P` to sort by CPU, `c` for full command lines) or `ps aux --sort=-%cpu | head`. What is it, and who
started it? `ps -o pid,ppid,user,lstart,cmd -p <PID>`.

## Hint 2
Kill it (`kill <PID>`, `kill -9` only if it ignores you) and wait a minute. Is it back? Something keeps starting it:
look in `/etc/cron.d/`, `crontab -l -u root`, and `systemctl list-timers`.

## Hint 3
Stop the **cause**: disable the cron entry (comment it out or remove the file, and note it in the ticket), then kill the
running copy. The bug itself goes to the team that owns the script.
