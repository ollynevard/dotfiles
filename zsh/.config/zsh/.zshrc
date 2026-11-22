# Read by interactive shells only, after ~/.zshenv (exports, PATH) and
# .zprofile. Keep exports out of here: scripts and `zsh -c` never see them.
#
# The stages below run in this order on purpose; each says what depends on it.
# See "Shell" in the README for which file gets what.

# 1. Options, history, keys ----------------------------------------------------

mkdir -p "$XDG_STATE_HOME"/{zsh,mycli} "$XDG_CACHE_HOME/zsh"

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=1000000000
SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Emacs keymap. zsh picks vi mode when $EDITOR contains "vi" (nvim).
bindkey -e
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^U" backward-kill-line

WORDCHARS='*?_.[]~=&;!#$%^(){}<>'
ZLE_RPROMPT_INDENT=0 # no space after the right prompt

# 2. Functions and completion --------------------------------------------------
# fpath must be complete before compinit runs.

# Our functions, one per file in functions/, loaded on first call. unfunction
# first, so `zr` picks up edits to a function that's already loaded.
fpath=("$ZDOTDIR/functions" $fpath)
for f in "$ZDOTDIR"/functions/*(N:t); do
  unfunction "$f" 2>/dev/null
  autoload -Uz "$f"
done
unset f

# Completion definitions from Homebrew formulae and zsh-completions
fpath+=("$HOMEBREW_PREFIX/share/zsh/site-functions")
[[ -d $HOMEBREW_PREFIX/opt/zsh-completions/share/zsh-completions ]] &&
  fpath+=("$HOMEBREW_PREFIX/opt/zsh-completions/share/zsh-completions")

# - Zsh Docs: https://zsh.sourceforge.io/Doc/Release/Completion-System.html
# - Zsh Guide: https://zsh.sourceforge.io/Guide/zshguide06.html
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs false
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
_comp_options+=(globdots)

# Bash-style completers
autoload -Uz bashcompinit
bashcompinit
complete -C "$HOMEBREW_PREFIX/bin/aws_completer" aws

# 3. Tool hooks ----------------------------------------------------------------
# Each adds prompt hooks or key bindings. Keep fzf before atuin, so atuin's
# Ctrl-R wins.

(( $+commands[mise] )) && eval "$(mise activate zsh)" # runtimes; prepends to PATH at each prompt
(( $+commands[starship] )) && eval "$(starship init zsh)"
source ~/.orbstack/shell/init.zsh 2>/dev/null || : # docker CLI

(( $+commands[fzf] )) && source <(fzf --zsh)
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# atuin owns Ctrl-R; Up keeps the prefix search from stage 1. Its data goes in
# $XDG_DATA_HOME/atuin only if that folder exists, otherwise in ~/.atuin.
mkdir -p "$XDG_DATA_HOME/atuin"
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

# Print a blank line before each command's output
autoload -Uz add-zsh-hook
_blank_line_before_output() { echo }
add-zsh-hook preexec _blank_line_before_output

# 4. Aliases -------------------------------------------------------------------

alias d="docker"
alias g="git"
alias l="eza --all --long --icons=auto"
alias ls="eza"
alias tree="eza --tree --icons"
alias p="pnpm"
alias vim="nvim"
alias v="vim"
alias t="terraform"
alias ze='vim "$ZDOTDIR/.zshrc"'
alias zr='source "$ZDOTDIR/.zshrc"'
alias grep="grep --color=auto"
alias htop="btop"
alias lg="lazygit"
alias lzd="lazydocker"
alias pip="pip3"
alias assume="source assume"
alias gb="fzf-git-branch"
alias gco="fzf-git-checkout"

# 5. Machine-specific settings and secrets (not tracked) ----------------------
# After everything above so they can override it.

for f in "$ZDOTDIR"/*.local.zsh(N); do source "$f"; done
unset f

# 6. Line-editor plugins (last) ------------------------------------------------
# zsh-syntax-highlighting must be sourced last: it wraps the line-editor
# widgets that exist when it loads, including those fzf, zoxide and atuin added.

for f in \
  "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
do
  [[ -r $f ]] && source "$f"
done
unset f
