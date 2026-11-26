#!/usr/bin/env bats
# The Project module (bin/.local/lib/bare-project.sh), tested through its
# interface against throwaway repositories.

load test_helper

setup() {
    isolate
    # shellcheck source=../bin/.local/lib/bare-project.sh
    source "$LIB"
}

# --- project_load --------------------------------------------------------------

@test "project_load from the project root" {
    make_project acme main
    project_load "$P"
    [ "$PROJECT_ROOT" = "$P" ]
    [ "$PROJECT_GIT" = "$P/.bare" ]
}

@test "project_load from inside a worktree" {
    make_project acme main feature/x
    git --git-dir="$P/.bare" worktree add -q "$P/feature+x" feature/x
    mkdir "$P/feature+x/sub"
    project_load "$P/feature+x/sub"
    [ "$PROJECT_ROOT" = "$P" ]
    [ "$PROJECT_GIT" = "$P/.bare" ]
}

@test "project_load rejects a normal clone" {
    make_origin main
    git clone -q "$W/origin.git" "$W/clone"
    run project_load "$W/clone"
    [ "$status" -eq 1 ]
}

@test "project_load rejects a folder outside git" {
    mkdir "$W/plain"
    run project_load "$W/plain"
    [ "$status" -eq 1 ]
    run project_load "$W/missing"
    [ "$status" -eq 1 ]
}

# --- project_default_branch ----------------------------------------------------

@test "default branch follows origin/HEAD" {
    make_project acme trunk main
    git --git-dir="$P/.bare" remote set-head origin --auto >/dev/null
    project_load "$P"
    run project_default_branch
    [ "$output" = trunk ]
}

@test "default branch falls back to origin/main" {
    make_project acme main
    project_load "$P"
    run project_default_branch
    [ "$output" = main ]
}

@test "default branch falls back to a local main" {
    make_project acme master
    git --git-dir="$P/.bare" branch main origin/master
    project_load "$P"
    run project_default_branch
    [ "$output" = main ]
}

@test "default branch falls back to master" {
    make_project acme develop
    project_load "$P"
    run project_default_branch
    [ "$output" = master ]
}

# --- worktree paths ------------------------------------------------------------

@test "project_worktree_dir turns / into +" {
    make_project acme main
    project_load "$P"
    run project_worktree_dir chore/ENG-1/fix-it
    [ "$output" = "$P/chore+ENG-1+fix-it" ]
}

@test "project_default_worktree finds the checkout wherever it is" {
    make_project acme main
    git --git-dir="$P/.bare" worktree add -q "$P/elsewhere" main
    project_load "$P"
    run project_default_worktree
    [ "$output" = "$P/elsewhere" ]
}

@test "project_default_worktree falls back to the expected path" {
    make_project acme main
    project_load "$P"
    run project_default_worktree
    [ "$output" = "$P/main" ]
}

# --- label ---------------------------------------------------------------------

@test "label defaults to the folder name capitalised" {
    make_project acme main
    project_load "$P"
    run project_label
    [ "$output" = Acme ]
}

@test "project_set_label overrides the label" {
    make_project acme main
    project_load "$P"
    project_set_label "ACME Web"
    run project_label
    [ "$output" = "ACME Web" ]
}

# --- sync ----------------------------------------------------------------------

@test "project_sync fast-forwards the default worktree to origin" {
    make_project acme main
    git --git-dir="$P/.bare" worktree add -q "$P/main" main
    git -C "$W/src" commit -q --allow-empty -m next
    git -C "$W/src" push -q "$W/origin.git" main
    project_load "$P"
    project_sync
    [ "$(git -C "$P/main" rev-parse HEAD)" = "$(git -C "$W/src" rev-parse HEAD)" ]
}

@test "project_sync fails without changing a diverged default worktree" {
    make_project acme main
    git --git-dir="$P/.bare" worktree add -q "$P/main" main
    git -C "$P/main" commit -q --allow-empty -m local
    local before
    before=$(git -C "$P/main" rev-parse HEAD)
    git -C "$W/src" commit -q --allow-empty -m next
    git -C "$W/src" push -q "$W/origin.git" main
    project_load "$P"
    run project_sync
    [ "$status" -ne 0 ]
    [ "$(git -C "$P/main" rev-parse HEAD)" = "$before" ]
}

# --- trust ---------------------------------------------------------------------

@test "trust is a no-op without ~/.claude.json" {
    run project_trust add /some/dir
    [ "$status" -eq 0 ]
    [ ! -e "$HOME/.claude.json" ]
}

@test "trust add and remove keep the rest of ~/.claude.json" {
    echo '{"theme":"dark","projects":{"/a":{"x":1}}}' >"$HOME/.claude.json"
    project_trust add /a
    project_trust add /b
    run jq -c . "$HOME/.claude.json"
    [ "$output" = '{"theme":"dark","projects":{"/a":{"x":1,"hasTrustDialogAccepted":true},"/b":{"hasTrustDialogAccepted":true}}}' ]
    project_trust remove /a
    project_trust remove /missing
    run jq -c . "$HOME/.claude.json"
    [ "$output" = '{"theme":"dark","projects":{"/a":{"x":1},"/b":{"hasTrustDialogAccepted":true}}}' ]
}

@test "trust leaves ~/.claude.json alone when it isn't valid JSON" {
    echo 'not json' >"$HOME/.claude.json"
    run project_trust add /a
    [ "$status" -ne 0 ]
    [ "$(cat "$HOME/.claude.json")" = 'not json' ]
    [ -z "$(find "$HOME" -name '.claude.json.*')" ]
}

@test "trust rejects an unknown mode" {
    echo '{}' >"$HOME/.claude.json"
    run project_trust grant /a
    [ "$status" -eq 2 ]
}
