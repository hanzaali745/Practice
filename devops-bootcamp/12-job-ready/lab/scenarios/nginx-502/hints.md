## Hint 1
502 means nginx couldn't get an answer from its upstream. nginx tells you why: `tail /var/log/nginx/error.log`.

## Hint 2
Where does nginx send requests (`grep -r proxy_pass /etc/nginx/`), and where does the app really listen
(`ss -tlnp`)? Test the app directly, skipping nginx: `curl -v http://127.0.0.1:8000/health`.

## Hint 3
Fix the upstream, then **always** `nginx -t` before `systemctl reload nginx` — a typo in a reload of a broken file takes
the whole site down.
