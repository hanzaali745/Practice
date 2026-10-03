## Hint 1
Read the 503 body: `curl -s localhost/visits`. Then ask the system to resolve the name the app uses:
`getent hosts redis` (resolves exactly like the app does) and `dig redis` (asks the DNS server directly).

## Hint 2
Which DNS server is this machine using? `cat /etc/resolv.conf`. Can it even reach it? `dig @<server> redis`.
What should it be? Look at a healthy machine on the same network — from your laptop:
`docker run --rm --network troubleshoot_default alpine cat /etc/resolv.conf`.

## Hint 3
On Docker networks the resolver is Docker's embedded DNS, `127.0.0.11`. Restore `nameserver 127.0.0.11`
(keep `options ndots:0`), then test with `getent hosts redis` and `curl localhost/visits`. In the postmortem: why did
config management push the wrong file, and why was there no backup?
