# shellcheck shell=bash
# bare-project.sh: the Project module. The rules of the bare layout, shared by
# wt-rex and bare-migrate (terms in ~/Code/dotfiles/GLOSSARY.md):
#
#   ~/Code/<project>/.bare      bare repository ($PROJECT_GIT)
#   ~/Code/<project>/<default>  default worktree (main, master, ...)
#   ~/Code/<project>/<branch>   one worktree per other branch ("/" -> "+")
#
# Source it; it only defines functions. project_load sets PROJECT_ROOT and
# PROJECT_GIT, and every other function reads them. Functions print their result
# on stdout and report failure only through their return status: they never exit,
# so each caller keeps its own error policy.
#
# Worktrunk's worktree-path template (~/.config/worktrunk/config.toml) can't
# source this, so it repeats the "/" -> "+" rule; keep the two in step.
#
# Bash 3.2 compatible (macOS /bin/bash).

# project_load DIR: set PROJECT_ROOT and PROJECT_GIT for the Project that DIR is
# the root of, or a worktree of. Returns 1 when DIR isn't in a Project.
project_load() {
    local d=$1 g
    if [[ -d $d/.bare ]]; then
        g=$d/.bare
    else
        g=$(git -C "$d" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
    fi
    g=$(cd "$g" && pwd -P) || return 1
    [[ $(basename "$g") == .bare ]] || return 1
    PROJECT_GIT=$g
    PROJECT_ROOT=$(dirname "$g")
}

# project_git ARGS...: run git against the Project's bare repository.
project_git() { git --git-dir="$PROJECT_GIT" "$@"; }

# project_default_branch: origin/HEAD, else origin/main, else local main, else
# master. origin comes first because nothing updates the local default branch
# in this layout except project_sync (`wt-rex sync`).
project_default_branch() {
    local b
    b=$(project_git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) || b=""
    b=${b#origin/}
    if [[ -z $b ]]; then
        if project_git show-ref --verify --quiet refs/remotes/origin/main ||
            project_git show-ref --verify --quiet refs/heads/main; then
            b=main
        else
            b=master
        fi
    fi
    printf '%s' "$b"
}

# project_worktree_dir BRANCH: where BRANCH's worktree lives ("/" -> "+").
project_worktree_dir() { printf '%s/%s' "$PROJECT_ROOT" "${1//\//+}"; }

# project_default_worktree: path of the worktree that has the default branch
# checked out, else where it would live.
project_default_worktree() {
    local b p
    b=$(project_default_branch)
    p=$(project_git worktree list --porcelain | awk -v ref="refs/heads/$b" '
        /^worktree /{p=substr($0,10)} $0=="branch " ref {print p; exit}')
    if [[ -n $p ]]; then printf '%s' "$p"; else project_worktree_dir "$b"; fi
}

# project_sync: fetch origin and fast-forward the default worktree. Worktrunk
# decides "merged" against the local default branch, which nothing else updates
# in this layout. Returns 1 when the fetch or the fast-forward fails, which only
# means the merged check may be stale.
project_sync() {
    local main b
    main=$(project_default_worktree)
    b=$(project_default_branch)
    project_git fetch --quiet --prune origin || return 1
    [[ -d $main ]] || return 0
    git -C "$main" merge --quiet --ff-only "origin/$b" 2>/dev/null
}

# project_label: the Project's label, used for its Rex session: `rex.label` in
# .bare/config, else the folder name capitalised.
project_label() {
    local l n
    l=$(project_git config --get rex.label) || l=""
    if [[ -z $l ]]; then
        n=$(basename "$PROJECT_ROOT")
        l="$(printf '%s' "${n:0:1}" | tr '[:lower:]' '[:upper:]')${n:1}"
    fi
    printf '%s' "$l"
}

# project_set_label LABEL
project_set_label() { project_git config rex.label "$1"; }

# project_trust add|remove DIR: pre-trust DIR in Claude Code, so a new session
# there doesn't stop at the "trust this folder?" dialog, or drop that trust.
# A no-op when ~/.claude.json doesn't exist.
project_trust() {
    local mode=$1 dir=$2 cfg="$HOME/.claude.json" filter tmp
    [[ -f $cfg ]] || return 0
    # shellcheck disable=SC2016 # $d is a jq variable
    case $mode in
        add) filter='.projects[$d] = ((.projects[$d] // {}) + {hasTrustDialogAccepted: true})' ;;
        remove) filter='if .projects[$d] then .projects[$d] |= del(.hasTrustDialogAccepted) else . end' ;;
        *) return 2 ;;
    esac
    tmp=$(mktemp "$cfg.XXXXXX") || return 1
    if jq --arg d "$dir" "$filter" "$cfg" >"$tmp"; then
        mv "$tmp" "$cfg"
    else
        rm -f "$tmp"
        return 1
    fi
}
