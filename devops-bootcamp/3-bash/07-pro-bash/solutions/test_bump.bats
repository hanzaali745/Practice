#!/usr/bin/env bats
# Lab 4 — Bats tests for bump.sh. Run: bats test_bump.bats

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/bump.sh"
}

@test "patch bump" {
    run "$SCRIPT" 1.4.9 patch
    [ "$status" -eq 0 ]
    [ "$output" = "1.4.10" ]
}

@test "minor bump resets patch" {
    run "$SCRIPT" 1.4.9 minor
    [ "$output" = "1.5.0" ]
}

@test "major bump resets minor and patch" {
    run "$SCRIPT" 1.4.9 major
    [ "$output" = "2.0.0" ]
}

@test "rejects malformed version" {
    run "$SCRIPT" 1.4 patch
    [ "$status" -eq 1 ]
}

@test "rejects unknown part" {
    run "$SCRIPT" 1.4.9 huge
    [ "$status" -eq 1 ]
}
