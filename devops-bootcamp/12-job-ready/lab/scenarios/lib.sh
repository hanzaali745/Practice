# lib.sh — helpers for check.sh scripts. lab.sh runs them INSIDE the server, as root, after this file.
failed=0
ok() {                                   # ok "description" command args...   → ✅ or ❌, remembers failures
    local desc=$1
    shift
    if "$@" > /dev/null 2>&1; then echo "  ✅ $desc"; else echo "  ❌ $desc"; failed=1; fi
}
http_code() { curl -s -o /dev/null -w '%{http_code}' --max-time "${2:-5}" "$1"; }
is_http() { [[ $(http_code "$1" "${3:-5}") == "$2" ]]; }     # is_http URL CODE [TIMEOUT]
app_healthy() { curl -sf --max-time 5 http://localhost/health | grep -q '"ok"'; }   # the REAL app answers via nginx
use_pct() { df --output=pcent "$1" | tail -1 | tr -dc '0-9'; }
inode_pct() { df --output=ipcent "$1" | tail -1 | tr -dc '0-9'; }
finish() { exit "$failed"; }
not_world_writable() { (( (0$(stat -c %a "$1") & 2) == 0 )); }   # octal mode: the "others may write" bit is off
