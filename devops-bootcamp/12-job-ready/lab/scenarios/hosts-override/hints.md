## Hint 1
Compare `dig +short redis` with `getent hosts redis`. `dig` asks a DNS server directly; programs (and `getent`) follow
the system's resolver order. Do they agree?

## Hint 2
The order is in `/etc/nsswitch.conf` (`hosts: files dns`): **files** first — that's `/etc/hosts`.

## Hint 3
Remove the stale line from `/etc/hosts`, then `getent hosts redis` and `curl localhost/visits`. "It's never DNS" —
it's often name resolution that isn't DNS at all.
