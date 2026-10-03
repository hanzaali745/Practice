## Hint 1
`systemctl status demo-app` and `journalctl -u demo-app -n 20 --no-pager`: what error does the service hit at start-up?

## Hint 2
Which user does the service run as (`systemctl cat demo-app`, look for `User=`)? Now check what that user can see:
`sudo -u demo ls -l /opt/demo-app/` and `namei -l /opt/demo-app/app.py` (every directory on the path matters).

## Hint 3
Give the service user exactly what it needs — **read** the code, **enter** the directory — and nothing more.
`chmod 777` "works" and is the wrong answer: any compromised process could then rewrite your app.
