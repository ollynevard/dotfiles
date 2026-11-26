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
