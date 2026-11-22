# Drop duplicate PATH/FPATH entries (e.g. when the shell is nested or re-sourced)
typeset -U PATH path FPATH fpath

# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Zsh extensions
test -e "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh" && source "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
test -e "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" && source "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
test -e "$HOMEBREW_PREFIX/opt/zsh-completions/share/zsh-completions" && FPATH="$HOMEBREW_PREFIX/opt/zsh-completions/share/zsh-completions:$FPATH"

# History
mkdir -p "$XDG_STATE_HOME"/{zsh,mycli}
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
# Other tools' history files (mycli's are set in ~/.config/mycli/myclirc)
export LESSHISTFILE="$XDG_STATE_HOME/lesshst"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"

# Emacs keymap. zsh picks vi mode when $EDITOR contains "vi" (nvim).
bindkey -e
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^U" backward-kill-line

export WORDCHARS='*?_.[]~=&;!#$%^(){}<>'

# Completion
# - Zsh Docs: http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Completion-System
# - Zsh Guide: http://zsh.sourceforge.net/Guide/zshguide06.html#l144
mkdir -p "$XDG_CACHE_HOME/zsh"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs false
autoload -Uz compinit
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
_comp_options+=(globdots)

# Bash completion
autoload bashcompinit
bashcompinit
complete -C '$HOMEBREW_PREFIX/bin/aws_completer' aws

# Starship Prompt
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
test -e "$HOMEBREW_PREFIX/bin/starship" && eval "$(starship init zsh)"

# mise (node, pnpm and other runtimes; global versions in ~/.config/mise/config.toml)
command -v mise > /dev/null && eval "$(mise activate zsh)"

# NPM
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"

# Go
export GOPATH="$XDG_DATA_HOME/go"

# OrbStack: docker CLI and shell integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Aliases
alias d="docker"
alias g="git"
alias l="eza --all --long --icons=auto"
alias ls="eza"
alias tree="eza --tree --icons"
alias p="pnpm"
alias vim="nvim"
alias v="vim"
alias t="terraform"
alias ze="vim ~/.config/zsh/.zshrc"
alias zr="source ~/.config/zsh/.zshrc"
alias grep="grep --color=auto"
alias htop="btop"
alias lg="lazygit"
alias lzd="lazydocker"
alias pip="pip3"
alias assume="source assume"

# rm moves files to the macOS Trash (Finder's Put Back works). rm flags are ignored.
unalias rm 2>/dev/null # an old alias would shadow the function on re-source
function rm {
  local -a files; local opts=1
  for a in "$@"; do
    if (( opts )) && [[ $a == -- ]]; then opts=0
    elif (( opts )) && [[ $a == -* ]]; then :
    elif [[ -e $a || -L $a ]]; then files+=("${a/#-/./-}") # trash has no "--"
    fi
  done
  (( ${#files} )) || return 0
  /usr/bin/trash "${files[@]}"
}

# Environment
test -e "$ZDOTDIR/env.local.zsh" && source "$ZDOTDIR/env.local.zsh"

export EDITOR=nvim

# Terminfo
export TERMINFO_DIRS=$TERMINFO_DIRS:$XDG_DATA_HOME/terminfo

export ZLE_RPROMPT_INDENT=0 # Remove space at end of right prompt

# Terraform
export TF_REGISTRY_CLIENT_TIMEOUT=20

# Print a newline before commands are executed
function preexec() {
  echo ""
}

# fzf
command -v fzf > /dev/null && source <(fzf --zsh)

fzf-git-branch() {
    git rev-parse HEAD > /dev/null 2>&1 || return

    git branch --color=always --all --sort=-committerdate |
        grep -v HEAD |
        fzf --height 50% --ansi --no-multi --preview-window right:65% \
            --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
        sed "s/.* //"
}

fzf-git-checkout() {
    git rev-parse HEAD > /dev/null 2>&1 || return

    local branch

    branch=$(fzf-git-branch)
    if [[ "$branch" = "" ]]; then
        echo "No branch selected."
        return
    fi

    # If branch name starts with 'remotes/' then it is a remote branch. By
    # using --track and a remote branch name, it is the same as:
    # git checkout -b branchName --track origin/branchName
    if [[ "$branch" = 'remotes/'* ]]; then
        git checkout --track $branch
    else
        git checkout $branch;
    fi
}

alias gb='fzf-git-branch'
alias gco='fzf-git-checkout'

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# zoxide
command -v zoxide > /dev/null && eval "$(zoxide init zsh)"

# atuin: owns Ctrl-R (must come after fzf). Up arrow keeps the prefix search above.
# Data goes in $XDG_DATA_HOME/atuin only if that folder exists; otherwise atuin uses ~/.atuin.
mkdir -p "$XDG_DATA_HOME/atuin"
command -v atuin > /dev/null && eval "$(atuin init zsh --disable-up-arrow)"

# yazi: `y` opens yazi and cds to wherever you quit it
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp" # bypass the trash-backed rm function
}

# Personal scripts (stowed from dotfiles/bin) and other user-installed tools
export PATH="$HOME/.local/bin:$PATH"
