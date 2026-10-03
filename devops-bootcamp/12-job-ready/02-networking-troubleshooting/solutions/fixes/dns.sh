# dns — the reference fix
curl -s localhost/visits                                        # 503 redis unavailable: [Errno -3] Temporary failure in name resolution
getent hosts redis || echo "does not resolve"
cat /etc/resolv.conf                                            # nameserver 192.0.2.53 (unreachable)
printf 'nameserver 127.0.0.11\noptions ndots:0\n' > /etc/resolv.conf     # Docker's embedded DNS
getent hosts redis
curl -s localhost/visits
