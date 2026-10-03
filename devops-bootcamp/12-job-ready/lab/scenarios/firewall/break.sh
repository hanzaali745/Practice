# "hardening": block outgoing traffic to a list of ports — including Redis's
iptables -A OUTPUT -p tcp --dport 6379 -j DROP -m comment --comment "OPS-3110 block legacy ports"
iptables -A OUTPUT -p tcp --dport 11211 -j DROP -m comment --comment "OPS-3110 block legacy ports"
