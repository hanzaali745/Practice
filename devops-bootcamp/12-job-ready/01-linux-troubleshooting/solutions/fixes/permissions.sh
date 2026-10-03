#!/usr/bin/env bash
# permissions — the reference fix
journalctl -u demo-app -n 20 --no-pager                         # python3: can't open file ... [Errno 13] Permission denied
namei -l /opt/demo-app/app.py                                   # drwx------ root /opt/demo-app, -rw------- root app.py
chown root:demo /opt/demo-app/app.py                            # root owns the code; the service's group may read it
chmod 640 /opt/demo-app/app.py
chmod 755 /opt/demo-app                                         # enter + list; nobody but root may write
systemctl restart demo-app
curl -s localhost/health
