# inodes — the reference fix
df -h /var/log/demo-app; df -i /var/log/demo-app                # blocks fine, inodes 100%
find /var/log/demo-app -xdev -type f | cut -d/ -f1-5 | sort | uniq -c | sort -n | tail -3
find /var/log/demo-app/sessions -type f -name 'sess-*.dump' -delete
rmdir /var/log/demo-app/sessions
df -i /var/log/demo-app
