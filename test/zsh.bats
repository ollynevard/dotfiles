#!/usr/bin/env bats
# The zsh package: syntax, a clean start in a throwaway HOME, the environment
# that scripts see, and the trash-backed rm function.

load test_helper

ZSH_PKG=$REPO/zsh
ZDOT=$ZSH_PKG/.config/zsh

setup() {
    command -v zsh >/dev/null || skip "zsh not installed"
    isolate
    # Link the package into the throwaway HOME the way Stow does.
    mkdir -p "$HOME/.config"
    ln -s "$ZSH_PKG/.zshenv" "$HOME/.zshenv"
    ln -s "$ZDOT" "$HOME/.config/zsh"
    # Start outside the real home: mise reads .config/mise/config.toml from
    # every parent folder, and the real one isn't trusted in this HOME.
    cd "$HOME"
}

# shell ARGS...: zsh with nothing inherited but HOME and TERM.
shell() {
    env -i HOME="$HOME" TERM=xterm-256color zsh "$@"
}

@test "startup files and functions parse" {
    for f in "$ZSH_PKG/.zshenv" "$ZDOT/.zshenv" "$ZDOT/.zprofile" "$ZDOT/.zshrc"; do
        zsh -n "$f" || { echo "syntax error in $f"; return 1; }
    done
    for f in "$ZDOT"/functions/*; do
        zsh -nc "_f() {
$(cat "$f")
}" || { echo "syntax error in $f"; return 1; }
    done
}

@test "scripts get the environment and PATH (zsh -c)" {
    run shell -c 'print -r -- "$EDITOR|$GOPATH|$ZDOTDIR|${path[1]}"'
    [ "$status" -eq 0 ]
    [ "$output" = "nvim|$HOME/.local/share/go|$HOME/.config/zsh|$HOME/.local/bin" ]
}

@test "login shells keep Homebrew ahead of /usr/bin" {
    [ -d /opt/homebrew ] || skip "no Homebrew"
    run shell -lc 'print -l $path'
    [ "$status" -eq 0 ]
    brew=$(grep -nx /opt/homebrew/bin <<<"$output" | cut -d: -f1)
    usr=$(grep -nx /usr/bin <<<"$output" | cut -d: -f1)
    [ -n "$brew" ] && [ -n "$usr" ] && [ "$brew" -lt "$usr" ]
}

@test "nested login shells (ZDOTDIR inherited) still read ~/.zshenv" {
    [ -d /opt/homebrew ] || skip "no Homebrew"
    # A shell started from another one inherits the exported ZDOTDIR, so zsh
    # reads $ZDOTDIR/.zshenv instead of ~/.zshenv (multiplexer panes, exec zsh -l).
    run env -i HOME="$HOME" TERM=xterm-256color ZDOTDIR="$HOME/.config/zsh" zsh -lc 'print -l $path'
    [ "$status" -eq 0 ]
    [[ $output != *"not found"* ]] || { echo "$output"; return 1; }
    brew=$(grep -nx /opt/homebrew/bin <<<"$output" | cut -d: -f1)
    usr=$(grep -nx /usr/bin <<<"$output" | cut -d: -f1)
    [ -n "$brew" ] && [ -n "$usr" ] && [ "$brew" -lt "$usr" ]
}

# tty_shell ARGS...: like shell, but on a terminal (via script), as in a real
# tab; without one, zle-using init scripts complain. Strips the terminal's
# echoed "^D", backspaces and carriage returns from the output.
tty_shell() {
    script -q /dev/null env -i HOME="$HOME" TERM=xterm-256color zsh "$@" </dev/null |
        sed 's/\^D//g' | tr -d '\r\b\004'
}

@test "interactive login shell starts without printing anything" {
    run tty_shell -il -c exit
    echo "output: $output"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "interactive shell autoloads every function in functions/" {
    run tty_shell -i -c 'for f in $ZDOTDIR/functions/*(:t); do whence -w $f; done; exit'
    echo "$output"
    for f in "$ZDOT"/functions/*; do
        grep -q "^$(basename "$f"): function" <<<"$output"
    done
}

# rm: run the rm function with a stub trash that records its arguments.
rm_() {
    printf '#!/bin/sh\nfor a; do echo "$a"; done >>"%s"\n' "$W/trashed" >"$W/trash"
    chmod +x "$W/trash"
    : >"$W/trashed"
    (cd "$W/files" && RM_TRASH=$W/trash zsh -fc \
        "fpath=('$ZDOT/functions'); autoload -Uz rm; rm $*")
}

setup_files() {
    mkdir -p "$W/files"
    touch "$W/files/a" "$W/files/b" "$W/files/-x"
    ln -s missing "$W/files/dangling"
}

@test "rm sends files to the trash and ignores rm's flags" {
    setup_files
    rm_ -rf a b
    [ "$(cat "$W/trashed")" = "$(printf 'a\nb')" ]
}

@test "rm treats names after -- as files, prefixing a leading dash" {
    setup_files
    rm_ -f -- -x
    [ "$(cat "$W/trashed")" = "./-x" ]
}

@test "rm skips missing names and keeps dangling symlinks" {
    setup_files
    rm_ nope a dangling
    [ "$(cat "$W/trashed")" = "$(printf 'a\ndangling')" ]
}

@test "rm with nothing to trash doesn't call trash" {
    setup_files
    rm_ -rf nope
    [ ! -s "$W/trashed" ]
}

# context DIR: run _prompt_context in DIR and print its variables, one per line.
context() {
    shell -fc "fpath=('$ZDOT/functions'); autoload -Uz _prompt_context; typeset -ga _prompt_links; typeset -gi _prompt_pr_fd
cd '$1' && _prompt_context
print -r -- \"\$STARSHIP_FOLDER|\$STARSHIP_TICKET\$STARSHIP_TICKET_REVIEW|\$STARSHIP_PR|\${(j:,:)_prompt_links}\""
}

@test "prompt folder: the last three folders outside git" {
    mkdir -p "$W/a/b/c/d"
    run context "$W/a/b/c/d"
    [ "$output" = $' …/b/c/d|||' ]
}

@test "prompt folder, ticket and PR in a Project worktree" {
    make_project acme main fix/ENG-7-thing
    git --git-dir="$P/.bare" worktree add -q "$P/fix+ENG-7-thing" fix/ENG-7-thing
    mkdir -p "$P/fix+ENG-7-thing/src/a/b"
    git --git-dir="$P/.bare" config --add prompt.ticketUrl 'https://t.example/{} ENG OPS'
    # A fresh cached PR, so gh isn't run.
    mkdir -p "$HOME/.cache/prompt-pr"
    echo "12 https://gh.example/pull/12" >"$HOME/.cache/prompt-pr/${P//\//%}@fix%ENG-7-thing"
    run context "$P/fix+ENG-7-thing/src/a/b"
    [ "$output" = $' acme/…/a/b|⟦1⟧|⟦2⟧|⟦1⟧,ENG-7,https://t.example/ENG-7,⟦2⟧,#12,https://gh.example/pull/12' ]
}

@test "prompt ticket: only prefixes listed in prompt.ticketUrl" {
    make_project acme main demo-03-x
    git --git-dir="$P/.bare" worktree add -q "$P/demo-03-x" demo-03-x
    git --git-dir="$P/.bare" config --add prompt.ticketUrl 'https://t.example/{} ENG'
    mkdir -p "$HOME/.cache/prompt-pr"
    : >"$HOME/.cache/prompt-pr/${P//\//%}@demo-03-x"
    run context "$P/demo-03-x"
    [ "$output" = $' acme|||' ]
}

@test "prompt PR coloured by state, ticket following it" {
    make_project acme main fix/ENG-7-thing
    git --git-dir="$P/.bare" worktree add -q "$P/fix+ENG-7-thing" fix/ENG-7-thing
    git --git-dir="$P/.bare" config --add prompt.ticketUrl 'https://t.example/{} ENG'
    mkdir -p "$HOME/.cache/prompt-pr"
    c="$HOME/.cache/prompt-pr/${P//\//%}@fix%ENG-7-thing"
    # state: expected PR pill, ticket pill (variable name suffixes; - for none)
    for want in none:-:TICKET draft:PR_DRAFT:TICKET closed:PR_DRAFT:TICKET merged:PR_MERGED:TICKET_DONE \
        review_required:PR_PENDING:TICKET_REVIEW changes_requested:PR_CHANGES:TICKET_REVIEW \
        approved:PR:TICKET_REVIEW open:PR:TICKET_REVIEW; do
        IFS=: read -r state pr ticket <<<"$want"
        case $state in
            none) : >"$c" ;;
            open) echo "12 https://gh.example/pull/12" >"$c" ;;
            *) echo "12 https://gh.example/pull/12 $state" >"$c" ;;
        esac
        run shell -fc "fpath=('$ZDOT/functions'); autoload -Uz _prompt_context; typeset -ga _prompt_links; typeset -gi _prompt_pr_fd
cd '$P/fix+ENG-7-thing' && _prompt_context && print -r -- \${(j: :)\${(ok)parameters[(I)STARSHIP_(PR|TICKET)*]}}"
        echo "$state: $output"
        if [ "$pr" = - ]; then [ "$output" = "STARSHIP_$ticket" ]
        else [ "$output" = "STARSHIP_$pr STARSHIP_$ticket" ]; fi
    done
}

@test "prompt PR checks: heat map until all pass, then a count" {
    make_project acme main fix/ENG-7-thing
    git --git-dir="$P/.bare" worktree add -q "$P/fix+ENG-7-thing" fix/ENG-7-thing
    mkdir -p "$HOME/.cache/prompt-pr"
    c="$HOME/.cache/prompt-pr/${P//\//%}@fix%ENG-7-thing"
    checks() {
        echo "12 https://gh.example/pull/12 open $1" >"$c"
        shell -fc "fpath=('$ZDOT/functions'); autoload -Uz _prompt_context; typeset -ga _prompt_links _prompt_checks; typeset -gi _prompt_pr_fd
cd '$P/fix+ENG-7-thing' && _prompt_context && print -r -- \$STARSHIP_CHECKS'|'\${(j:,:)_prompt_checks}"
    }
    run checks -;      [ "$output" = "|" ]
    run checks ppp;    [[ $output == '⟦3⟧|green,'?*' 3,https://gh.example/pull/12/checks' ]]
    run checks pfr;    [ "$output" = "⟦3⟧|green,■,https://gh.example/pull/12/checks,red,■,https://gh.example/pull/12/checks,yellow,■,https://gh.example/pull/12/checks" ]
    run checks $'pf\nhttps://ci/1\nhttps://ci/2'; [ "$output" = "⟦3⟧|green,■,https://ci/1,red,■,https://ci/2" ]
    run checks "$(printf 'p%.0s' {1..25})f"; [[ $output == '⟦3⟧|red,'?*' 1,https://gh.example/pull/12/checks' ]]
    run checks "$(printf 'p%.0s' {1..20})rrrrrr"; [[ $output == '⟦3⟧|yellow,'?*' 20/26,https://gh.example/pull/12/checks' ]]
}

@test "Claude status line: the context line plus model and context pills" {
    command -v starship >/dev/null || skip "starship not installed"
    mkdir -p "$HOME/.config/starship"
    ln -s "$REPO/starship/.config/starship/starship.toml" "$HOME/.config/starship/starship.toml"
    make_project acme main fix/ENG-7-thing
    git --git-dir="$P/.bare" worktree add -q "$P/fix+ENG-7-thing" fix/ENG-7-thing
    git --git-dir="$P/.bare" config --add prompt.ticketUrl 'https://t.example/{} ENG'
    mkdir -p "$HOME/.cache/prompt-pr"
    echo "12 https://gh.example/pull/12" >"$HOME/.cache/prompt-pr/${P//\//%}@fix%ENG-7-thing"
    json='{"workspace":{"current_dir":"'"$P/fix+ENG-7-thing"'"},"model":{"id":"claude-x","display_name":"Opus 5.5"},
      "context_window":{"current_usage":{"input_tokens":5,"cache_creation_input_tokens":1000,"cache_read_input_tokens":69000}}}'
    run shell -c "print -r -- '$json' | '$REPO/claude/.claude/statusline' | perl -pe 's/\e\[[0-9;]*m//g; s/\e\]8;;([^\e]*)\e\\\\\\\\/<\$1>/g'"
    [ "$status" -eq 0 ]
    [[ $output == *acme*fix/ENG-7-thing* ]]
    [[ $output == *'<https://t.example/ENG-7>ENG-7<>'* ]]
    [[ $output == *'<https://gh.example/pull/12>#12<>'* ]]
    [[ $output == *'Opus 5.5'*' 70k'* ]]
}
