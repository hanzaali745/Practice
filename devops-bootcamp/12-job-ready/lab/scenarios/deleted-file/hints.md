## Hint 1
Compare `df -h /var/log/demo-app` with `du -sh /var/log/demo-app`. When they disagree, space is used by files that
no longer have a name — deleted, but still **open** by some process.

## Hint 2
`lsof -a +L1 /var/log/demo-app` lists open files with zero links (deleted). Which process, which user, which service?
`systemctl status <PID>` tells you which unit a process belongs to.

## Hint 3
Space comes back when the last process closes the file. Killing the PID isn't enough here (look at `Restart=` in
`systemctl cat log-shipper`). This shipper is for a cluster that no longer exists: **stop** the service.
(Emergency trick when you can't restart a process: `: > /proc/<PID>/fd/<FD>` truncates the deleted file in place.)
