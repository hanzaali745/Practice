# a forgotten log shipper keeps a 48 MB buffer file open...
systemd-run --unit=log-shipper --description="ships logs to the old ELK cluster (decommissioned)" \
    --property=Restart=always --uid=demo python3 -c '
import time
f = open("/var/log/demo-app/ship-buffer.log", "w")
f.write("x" * 48_000_000)
f.flush()
while True:
    time.sleep(3600)
' > /dev/null 2>&1
for _ in $(seq 1 50); do [[ $(stat -c %s /var/log/demo-app/ship-buffer.log 2>/dev/null) == 48000000 ]] && break; sleep 0.2; done
# ...and someone "cleaned up" by deleting it. The space is NOT freed while a process holds the file open.
rm /var/log/demo-app/ship-buffer.log
