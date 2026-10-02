#!/usr/bin/env bats
# Lab 4 — unit test individual functions by sourcing the library
#
# Gotcha: a bare `! cmd` line NEVER fails a Bats test (bash's errexit ignores `!`).
# Use `run ! cmd` (Bats 1.5+) for "this must fail" assertions.
bats_require_minimum_version 1.5.0

setup() {
    # shellcheck source=validators.sh
    source "$BATS_TEST_DIRNAME/validators.sh"
}

@test "valid IPs" {
    is_valid_ip 192.168.1.1
    is_valid_ip 0.0.0.0
    is_valid_ip 255.255.255.255
}

@test "invalid IPs" {
    run ! is_valid_ip 256.1.1.1
    run ! is_valid_ip 10.0.0
    run ! is_valid_ip a.b.c.d
    run ! is_valid_ip ""
}

@test "ports" {
    is_valid_port 22
    is_valid_port 65535
    run ! is_valid_port 0
    run ! is_valid_port 65536
    run ! is_valid_port http
}

@test "main classifies values" {
    run main 10.0.0.1 443 nope
    [ "${lines[0]}" = "10.0.0.1: ip" ]
    [ "${lines[1]}" = "443: port" ]
    [ "${lines[2]}" = "nope: invalid" ]
}
