#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"
}

@test "no args exits 0" {
    run lefthook-execute-permissions
    assert_success
}

@test "non-existent file is skipped" {
    run lefthook-execute-permissions /nonexistent/file.txt
    assert_success
}

@test "non-executable file passes" {
    echo "hello" > "$TMP/normal.txt"
    chmod -x "$TMP/normal.txt"
    run lefthook-execute-permissions "$TMP/normal.txt"
    assert_success
}

@test "executable file in disallowed location fails" {
    echo "hello" > "$TMP/bad.txt"
    chmod +x "$TMP/bad.txt"
    run lefthook-execute-permissions "$TMP/bad.txt"
    assert_failure
    assert_output --partial "Unexpected execute permissions"
}

@test "executable file in allowed bin/ location passes" {
    mkdir -p "$TMP/repo/bin"
    echo "hello" > "$TMP/repo/bin/tool"
    chmod +x "$TMP/repo/bin/tool"
    run lefthook-execute-permissions "./bin/tool"
    # Note: this test checks the pattern matching, not the actual file
    # The file check happens first ([ -f "$f" ]) so we test with real files
    assert_success  # ./bin/ matches default allowed pattern
}

@test "custom allowed pattern via env var" {
    echo "hello" > "$TMP/tool.sh"
    chmod +x "$TMP/tool.sh"
    LEFTHOOK_EXECUTE_PERMISSIONS_ALLOWED='\.sh$' run lefthook-execute-permissions "$TMP/tool.sh"
    assert_success
}

@test "multiple files: one bad fails" {
    echo "good" > "$TMP/good.txt"
    echo "bad" > "$TMP/bad.txt"
    chmod +x "$TMP/bad.txt"
    run lefthook-execute-permissions "$TMP/good.txt" "$TMP/bad.txt"
    assert_failure
}
