## Hint 1
502 from nginx means nginx is fine but the thing *behind* it isn't answering. Is demo-app running?
`systemctl status demo-app` — look at "Active:" and how often it restarted.

## Hint 2
The service keeps crashing. Its error output goes to the journal: `journalctl -u demo-app -n 30 --no-pager`.
What exactly does Python complain about?

## Hint 3
`systemctl cat demo-app` shows the unit file **and every drop-in override** on top of it. Fix the value in the override,
then `systemctl daemon-reload` (systemd re-reads unit files only then) and restart the service.
