# a debug option left on writes one tiny file per user session — thousands of them
mkdir -p /var/log/demo-app/sessions
python3 - <<'EOF'
import os
for i in range(20000):
    try:
        with open(f"/var/log/demo-app/sessions/sess-{i:06d}.dump", "w") as f:
            f.write("{}")
    except OSError:                     # out of inodes: exactly the point
        break
EOF
chown -R demo:demo /var/log/demo-app/sessions
