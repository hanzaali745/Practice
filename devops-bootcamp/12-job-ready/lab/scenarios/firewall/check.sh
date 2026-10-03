redis_not_blocked() { ! iptables -S OUTPUT | grep -E -- '--dport 6379.*-j (DROP|REJECT)'; }
other_rule_kept() { iptables -S OUTPUT | grep -q -- '--dport 11211'; }
ok "no firewall rule blocks Redis (6379)" redis_not_blocked
ok "the unrelated rule for 11211 is still there (you didn't flush everything)" other_rule_kept
ok "/visits answers 200 within 3 s" is_http http://localhost/visits 200 3
ok "users get the real app through nginx" app_healthy
finish
