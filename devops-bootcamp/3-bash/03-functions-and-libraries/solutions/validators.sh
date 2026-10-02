#!/usr/bin/env bash
# Lab 2 — validators that communicate only through exit status

is_number() {
    [[ $1 =~ ^[0-9]+$ ]]
}

is_valid_port() {
    is_number "$1" && (( 10#$1 >= 1 && 10#$1 <= 65535 ))
}

is_valid_ip() {
    local ip="$1" octet
    local -a octets
    [[ $ip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] || return 1
    IFS=. read -r -a octets <<< "$ip"
    for octet in "${octets[@]}"; do
        (( 10#$octet <= 255 )) || return 1
    done
}

check() {
    local fn="$1" value="$2"
    if "$fn" "$value"; then echo "✅ $fn $value"; else echo "❌ $fn $value"; fi
}

for v in 42 abc -1; do check is_number "$v"; done
for v in 22 0 65535 70000 http; do check is_valid_port "$v"; done
for v in 192.168.1.1 255.255.255.255 256.1.1.1 10.0.0 a.b.c.d; do check is_valid_ip "$v"; done
