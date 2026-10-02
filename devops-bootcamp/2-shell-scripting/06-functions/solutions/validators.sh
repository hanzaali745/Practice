#!/bin/sh
# Lab 2 — validators that only return a status

is_number() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
    esac
}

is_valid_port() {
    is_number "$1" && [ "$1" -ge 1 ] && [ "$1" -le 65535 ]
}

# ( ) body: IFS and the positional parameters changed here can't leak out
is_valid_ip() (
    case "$1" in
        *[!0-9.]*|*..*|.*|*.) return 1 ;;      # only digits and single dots
    esac
    IFS=.
    # shellcheck disable=SC2086  # we WANT word splitting on dots here
    set -- $1
    [ $# -eq 4 ] || return 1
    for octet in "$@"; do
        [ "${#octet}" -le 3 ] && [ "$octet" -le 255 ] || return 1
    done
)

check() {
    if "$1" "$2"; then echo "✅ $1 $2"; else echo "❌ $1 $2"; fi
}

for v in 42 abc -1; do check is_number "$v"; done
for v in 22 0 65535 70000 http; do check is_valid_port "$v"; done
for v in 192.168.1.1 255.255.255.255 256.1.1.1 10.0.0 1.2.3.4.5 a.b.c.d; do check is_valid_ip "$v"; done
