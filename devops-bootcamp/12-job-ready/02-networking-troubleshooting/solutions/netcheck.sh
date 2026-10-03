#!/usr/bin/env bash
# netcheck.sh HOST PORT [http|https] [PATH] — "can I reach it?", answered layer by layer, so you know WHERE it breaks:
#   1 name resolution (as programs see it, then DNS only)  2 route  3 TCP connect  4 TLS (https)  5 HTTP + timings
#   ./netcheck.sh redis 6379
#   ./netcheck.sh demo.lab 443 https /health
set -uo pipefail
host=${1:?usage: netcheck.sh HOST PORT [http|https] [PATH]}
port=${2:?usage: netcheck.sh HOST PORT [http|https] [PATH]}
proto=${3:-}
path=${4:-/}
pass() { printf '  ✅ %s\n' "$*"; }
fail() { printf '  ❌ %s\n' "$*"; exit 1; }
info() { printf '     %s\n' "$*"; }

echo "1. Name resolution"
if [[ $host =~ ^[0-9.]+$ ]]; then
    ip=$host; pass "$host is already an IP"
else
    ip=$(getent ahostsv4 "$host" | awk 'NR==1 {print $1}')
    [[ -n $ip ]] || fail "$host does not resolve (check /etc/hosts, /etc/resolv.conf, nsswitch.conf)"
    pass "$host → $ip (getent: /etc/hosts first, then DNS)"
    if command -v dig > /dev/null; then
        dns=$(dig +short +time=2 +tries=1 "$host" | grep -E '^[0-9.]+$' | head -1)
        if [[ -z $dns ]]; then info "DNS itself has no answer — the name comes from /etc/hosts (or DNS is down)"
        elif [[ $dns != "$ip" ]]; then info "⚠️  DNS says $dns but programs use $ip — an /etc/hosts override?"; fi
    fi
fi

echo "2. Route"
route=$(ip route get "$ip" 2> /dev/null | head -1)
[[ -n $route ]] || fail "no route to $ip"
pass "$route"

echo "3. TCP connect to $ip:$port"
start=$(date +%s%N)
if out=$(nc -z -v -w 3 "$ip" "$port" 2>&1); then
    pass "port open ($(( ($(date +%s%N) - start) / 1000000 )) ms)"
elif grep -qi refused <<< "$out"; then
    fail "connection REFUSED — the host answered: nothing listens on $port (service down? wrong port? bound to 127.0.0.1?)"
else
    fail "TIMEOUT — packets are dropped on the way (firewall/security group, wrong IP, host down)"
fi

if [[ $proto == https ]]; then
    echo "4. TLS"
    cert=$(openssl s_client -connect "$ip:$port" -servername "$host" < /dev/null 2> /dev/null | openssl x509 -noout -subject -ext subjectAltName -enddate 2> /dev/null)
    [[ -n $cert ]] || fail "no TLS handshake (is it really TLS on $port?)"
    while IFS= read -r line; do info "$line"; done <<< "$cert"
    if grep -qE "DNS:$host(,|$)" <<< "$cert"; then pass "certificate is valid for $host"; else info "⚠️  $host is NOT in the certificate's SAN list"; fi
fi

if [[ -n $proto ]]; then
    echo "5. HTTP"
    curl_opts=(-s -o /dev/null --max-time 10 --resolve "$host:$port:$ip"
               -w 'code=%{http_code} dns=%{time_namelookup}s connect=%{time_connect}s tls=%{time_appconnect}s first-byte=%{time_starttransfer}s total=%{time_total}s')
    [[ -n ${CACERT:-} ]] && curl_opts+=(--cacert "$CACERT")
    result=$(curl "${curl_opts[@]}" "$proto://$host:$port$path")
    info "$result"
    if [[ $result == code=[23]* ]]; then pass "HTTP answers"; else fail "HTTP error (code=000: TLS/connection failed; 5xx: the server side)"; fi
fi
