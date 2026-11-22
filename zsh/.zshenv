# Read by every zsh: login, interactive, scripts, `zsh -c`. Only exports and
# PATH here: no output, no subprocesses, nothing interactive (that's .zshrc).
# See "Shell" in the README for which file gets what.

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export EDITOR=nvim

# Tool config, cache and data locations (XDG)
export ATUIN_CONFIG_DIR="$XDG_CONFIG_HOME/atuin"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export GOPATH="$XDG_DATA_HOME/go"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export TERMINFO_DIRS="${TERMINFO_DIRS:+$TERMINFO_DIRS:}$XDG_DATA_HOME/terminfo"

# Other tools' history files (mycli's are set in ~/.config/mycli/myclirc)
export LESSHISTFILE="$XDG_STATE_HOME/lesshst"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"

export TF_REGISTRY_CLIENT_TIMEOUT=20

# Stop Apple Terminal writing per-window history to $ZDOTDIR/.zsh_sessions
export SHELL_SESSIONS_DISABLE=1

# Homebrew: what `brew shellenv` prints, written out so no subprocess runs here.
if [[ -d /opt/homebrew ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew
  export HOMEBREW_CELLAR=/opt/homebrew/Cellar
  export HOMEBREW_REPOSITORY=/opt/homebrew
  export INFOPATH="$HOMEBREW_PREFIX/share/info${INFOPATH:+:$INFOPATH}"
fi

# PATH: ours in front of the system's. Each entry appears once (typeset -U), so
# re-running this keeps the first copy. .zprofile runs dotfiles_path again,
# because macOS's /etc/zprofile (path_helper) moves /usr/bin and friends back to
# the front in login shells.
typeset -gU PATH path FPATH fpath
export PATH # zsh leaves a default PATH unexported when it starts without one
dotfiles_path() {
  path=(
    "$HOME/.local/bin" # personal scripts (stowed from dotfiles/bin)
    "$PNPM_HOME"
    ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin}
    ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin}
    $path
  )
}
dotfiles_path
