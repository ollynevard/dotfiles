# Shared setup for the bats tests: an isolated HOME and git config (so the real
# ~/.claude.json and SSH commit signing are never touched), plus repo fixtures.

REPO=$(cd "$BATS_TEST_DIRNAME/.." && pwd)
BIN=$REPO/bin/.local/bin
LIB=$REPO/bin/.local/lib/bare-project.sh

isolate() {
    export HOME=$BATS_TEST_TMPDIR/home
    mkdir -p "$HOME"
    export GIT_CONFIG_NOSYSTEM=1
    export GIT_CONFIG_GLOBAL=$HOME/.gitconfig
    git config --global user.name Test
    git config --global user.email test@example.com
    git config --global init.defaultBranch main
    W=$(cd "$BATS_TEST_TMPDIR" && pwd -P)
}

# make_origin DEFAULT [BRANCH...]: a bare origin at $W/origin.git whose HEAD is
# DEFAULT, with one commit on DEFAULT and each extra BRANCH.
make_origin() {
    local default=$1 b
    shift
    git init -q -b "$default" "$W/src"
    printf '.env\n' >"$W/src/.gitignore"
    git -C "$W/src" add .gitignore
    git -C "$W/src" commit -q -m init
    for b in "$@"; do git -C "$W/src" branch "$b"; done
    git clone -q --bare "$W/src" "$W/origin.git"
}

# make_project NAME DEFAULT [BRANCH...]: an empty Project at $W/NAME (just
# .bare, fetched from a fresh origin, no origin/HEAD and no worktrees).
make_project() {
    local name=$1
    shift
    make_origin "$@"
    P=$W/$name
    mkdir "$P"
    git init -q --bare "$P/.bare"
    git --git-dir="$P/.bare" remote add origin "$W/origin.git"
    git --git-dir="$P/.bare" fetch -q origin
    # Newer git creates origin/HEAD on fetch (remote.origin.followRemoteHEAD).
    git --git-dir="$P/.bare" remote set-head origin -d >/dev/null 2>&1 || true
}
