#!/bin/sh
# Tests for docker-entrypoint.sh — a tiny test runner in pure POSIX sh.
# Usage: sh test_entrypoint.sh

HERE=$(cd "$(dirname "$0")" && pwd)
EP="$HERE/docker-entrypoint.sh"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
passed=0
failed=0

# run_test NAME EXPECTED_EXIT_CODE COMMAND...
run_test() {
    name="$1"; expected="$2"; shift 2
    "$@" > "$WORK/out" 2>&1
    actual=$?
    if [ "$actual" -eq "$expected" ]; then
        echo "ok   - $name"
        passed=$((passed + 1))
    else
        echo "FAIL - $name (expected exit $expected, got $actual)"
        sed 's/^/       /' "$WORK/out"
        failed=$((failed + 1))
    fi
}

assert_output_contains() {
    if grep -q -- "$1" "$WORK/out"; then
        echo "ok   - output contains '$1'"
        passed=$((passed + 1))
    else
        echo "FAIL - output does not contain '$1'"
        failed=$((failed + 1))
    fi
}

export WAIT_TIMEOUT=0 CONFIG_OUT="$WORK/app.conf"

run_test "no command → usage (exit 2)" 2 env APP_ENV=dev DB_HOST=db sh "$EP"
run_test "missing APP_ENV → exit 1" 1 env -u APP_ENV DB_HOST=db sh "$EP" true
assert_output_contains "APP_ENV is not set"
run_test "bad APP_ENV → exit 1" 1 env APP_ENV=qa DB_HOST=db sh "$EP" true
run_test "bad DB_PORT → exit 1" 1 env APP_ENV=dev DB_HOST=db DB_PORT=abc sh "$EP" true

run_test "renders config and runs the command" 0 \
    env APP_ENV=prod DB_HOST=db.internal DB_PORT=6543 sh "$EP" cat "$WORK/app.conf"
assert_output_contains "environment = prod"
assert_output_contains "database    = db.internal:6543"
assert_output_contains "log_level   = info"

run_test "exit code of the app is passed through" 7 \
    env APP_ENV=dev DB_HOST=db sh "$EP" sh -c 'exit 7'

run_test "times out waiting for a closed port" 1 \
    env APP_ENV=dev DB_HOST=127.0.0.1 DB_PORT=9 WAIT_TIMEOUT=2 sh "$EP" true
assert_output_contains "not reachable after 2s"

echo
echo "$passed passed, $failed failed"
[ "$failed" -eq 0 ]
