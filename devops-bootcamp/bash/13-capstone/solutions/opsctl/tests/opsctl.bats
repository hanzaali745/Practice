#!/usr/bin/env bats
# Run: bats tests/
bats_require_minimum_version 1.5.0

setup() {
    OPSCTL="$BATS_TEST_DIRNAME/../opsctl"
    WORK="$(mktemp -d)"
}

teardown() {
    rm -rf "$WORK"
}

@test "help lists commands" {
    run "$OPSCTL" help
    [ "$status" -eq 0 ]
    [[ $output == *"health"* && $output == *"backup"* ]]
}

@test "unknown command exits 2" {
    run "$OPSCTL" frobnicate
    [ "$status" -eq 2 ]
}

@test "health passes with generous thresholds" {
    run "$OPSCTL" health -d 100 -m 100
    [ "$status" -eq 0 ]
}

@test "health fails for a missing process" {
    run "$OPSCTL" health -d 100 -m 100 -s definitely-not-running-xyz
    [ "$status" -eq 1 ]
}

@test "health rejects bad threshold" {
    run "$OPSCTL" health -d abc
    [ "$status" -eq 1 ]
}

@test "logs-report counts requests and errors" {
    cat > "$WORK/access.log" <<'LOG'
1.1.1.1 - - [01/May/2024:10:00:01 +0000] "GET / HTTP/1.1" 200 10 "-" "x"
1.1.1.1 - - [01/May/2024:10:00:02 +0000] "GET /a HTTP/1.1" 404 10 "-" "x"
2.2.2.2 - - [01/May/2024:10:00:03 +0000] "GET /b HTTP/1.1" 500 10 "-" "x"
LOG
    run "$OPSCTL" logs-report "$WORK/access.log"
    [ "$status" -eq 0 ]
    [[ $output == *"4xx: 1  5xx: 1  of 3"* ]]
}

@test "backup creates archive + checksum and prunes" {
    mkdir -p "$WORK/src" && echo hi > "$WORK/src/f"
    for _ in 1 2 3; do
        run "$OPSCTL" backup -k 2 "$WORK/src" "$WORK/bk"
        [ "$status" -eq 0 ]
        sleep 1
    done
    [ "$(find "$WORK/bk" -name '*.tar.gz' | wc -l)" -eq 2 ]
    (cd "$WORK/bk" && sha256sum -c --quiet ./*.sha256)
}

@test "backup dry-run creates nothing" {
    mkdir -p "$WORK/src"
    run "$OPSCTL" backup -n "$WORK/src" "$WORK/bk"
    [ "$status" -eq 0 ]
    [ ! -d "$WORK/bk" ]
}

@test "cleanup deletes only old matching files" {
    touch "$WORK/new.log" "$WORK/old.txt"
    touch -d '10 days ago' "$WORK/old.log" "$WORK/old.txt"
    run "$OPSCTL" cleanup -d 7 -p '*.log' "$WORK"
    [ "$status" -eq 0 ]
    [ ! -e "$WORK/old.log" ]
    [ -e "$WORK/new.log" ]
    [ -e "$WORK/old.txt" ]
}

@test "cleanup refuses /" {
    run "$OPSCTL" cleanup -n /
    [ "$status" -eq 1 ]
    [[ $output == *"refusing"* ]]
}
