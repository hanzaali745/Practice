# hosts-override — the reference fix
dig +short redis; getent hosts redis                            # DNS: 172.x.x.x — getent: 10.255.255.1
grep hosts: /etc/nsswitch.conf                                  # hosts: files dns → /etc/hosts wins
grep -n redis /etc/hosts
# /etc/hosts is bind-mounted by Docker: edit it in place (sed -i would try to replace the file)
grep -v -e '10.255.255.1' -e 'redis migration test' /etc/hosts > /tmp/hosts.new && cat /tmp/hosts.new > /etc/hosts
getent hosts redis
curl -s localhost/visits
