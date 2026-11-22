#!/usr/bin/env bats
# bare-migrate end to end, with herdr and wt-herdr kept off PATH.

load test_helper

setup() {
    isolate
    # Only git and jq from outside the system dirs, so wt-herdr (and herdr) are
    # never found and no real workspaces are touched.
    mkdir "$W/bin"
    ln -s "$(command -v git)" "$W/bin/git"
    ln -s "$(command -v jq)" "$W/bin/jq"
    export PATH="$W/bin:/usr/bin:/bin"
}

@test "migrates a clone with a local branch into the bare layout" {
    make_origin main
    git clone -q "$W/origin.git" "$W/acme"
    git -C "$W/acme" switch -q -c feature/x
    git -C "$W/acme" commit -q --allow-empty -m "local only"
    echo SECRET=1 >"$W/acme/.env"
    echo '{}' >"$HOME/.claude.json"

    run "$BIN/bare-migrate" "$W/acme" --label "ACME" --yes
    [ "$status" -eq 0 ]

    [ -d "$W/acme/.bare" ]
    [ -d "$W/acme-old/.git" ]
    [ "$(git -C "$W/acme/main" symbolic-ref --short HEAD)" = main ]
    [ "$(git -C "$W/acme/feature+x" symbolic-ref --short HEAD)" = feature/x ]
    [ "$(git -C "$W/acme/feature+x" log -1 --format=%s)" = "local only" ]
    [ "$(cat "$W/acme/main/.env")" = SECRET=1 ]
    [ "$(cat "$W/acme/feature+x/.env")" = SECRET=1 ]
    grep -qx .env "$W/acme/main/.worktreeinclude"
    [ "$(git --git-dir="$W/acme/.bare" config herdr.label)" = ACME ]
    run jq -r '.projects | to_entries | map(select(.value.hasTrustDialogAccepted)) | .[].key' "$HOME/.claude.json"
    [ "${lines[0]}" = "$W/acme" ]
    [ "${lines[1]}" = "$W/acme/main" ]
}

@test "refuses a dirty clone and leaves it in place" {
    make_origin main
    git clone -q "$W/origin.git" "$W/acme"
    echo wip >"$W/acme/wip.txt"
    run "$BIN/bare-migrate" "$W/acme" --yes
    [ "$status" -eq 1 ]
    [[ $output == *"uncommitted or untracked"* ]]
    [ -d "$W/acme/.git" ]
    [ ! -e "$W/acme-old" ]
}
