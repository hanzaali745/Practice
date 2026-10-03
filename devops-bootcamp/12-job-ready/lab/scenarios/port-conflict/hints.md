## Hint 1
nginx is answering — with the wrong content. What is actually listening on port 8000? `ss -tlnp 'sport = :8000'`
(the `-p` column needs root: use sudo).

## Hint 2
`systemctl status demo-app` and `journalctl -u demo-app -n 20 --no-pager`: why can't the real app start?
For the other process: `ps -o pid,user,cmd -p <PID>` and `systemctl status <PID>` (which unit started it?).

## Hint 3
Stop the debug server **as a service** (`systemctl stop <unit>`), then start demo-app and confirm `ss -tlnp` shows
demo-app's python on :8000. Two programs can't listen on the same address and port.
