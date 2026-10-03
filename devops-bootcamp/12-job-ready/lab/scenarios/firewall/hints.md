## Hint 1
DNS works (`getent hosts redis`)? Then test the connection itself: `nc -vz -w 3 redis 6379`. A **timeout** means
packets vanish (dropped); **connection refused** means the host answered "nothing listens here".

## Hint 2
Who is dropping them? Look at this machine's own firewall first: `iptables -S` and `iptables -L OUTPUT -n -v --line-numbers`
(the packet counters show which rule matches).

## Hint 3
Delete exactly the rule that hurts (`iptables -D OUTPUT <number>`), not the whole firewall. Keep the other rule —
it may be wanted. And find out where the change is managed, or it will come back on the next run.
