#!/usr/bin/env bash
# Lab 4 — a testable library: functions + "only run main when executed directly"

is_number() { [[ ${1:-} =~ ^[0-9]+$ ]]; }

is_valid_port() { is_number "${1:-}" && (( 10#$1 >= 1 && 10#$1 <= 65535 )); }

is_valid_ip() {
    local ip="${1:-}" octet
    local -a octets
    [[ $ip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] || return 1
    IFS=. read -r -a octets <<< "$ip"
    for octet in "${octets[@]}"; do
        (( 10#$octet <= 255 )) || return 1
    done
}

main() {
    local value
    for value in "$@"; do
        if is_valid_ip "$value"; then echo "$value: ip"
        elif is_valid_port "$value"; then echo "$value: port"
        else echo "$value: invalid"
        fi
    done
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
