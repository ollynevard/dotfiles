#!/usr/bin/env bats

load test_helper

@test "scripts pass shellcheck" {
    command -v shellcheck >/dev/null || skip "shellcheck not installed"
    run shellcheck -x "$LIB" "$BIN/wt-herdr" "$BIN/bare-migrate" "$REPO/install" "$REPO/macos.sh"
    echo "$output"
    [ "$status" -eq 0 ]
}
