# firewall — the reference fix
nc -vz -w 3 redis 6379 || true                                  # timed out → packets are dropped, not refused
iptables -L OUTPUT -n -v --line-numbers                         # rule 1: DROP tcp dpt:6379 (packet counter rising)
iptables -D OUTPUT -p tcp --dport 6379 -j DROP -m comment --comment "OPS-3110 block legacy ports"
nc -vz -w 3 redis 6379
curl -s localhost/visits
