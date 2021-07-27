# Zsh extensions
test -e "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" && source "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
test -e "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" && source "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
test -e "/usr/local/share/zsh-completions" && FPATH="/usr/local/share/zsh-completions:$FPATH"

# History
export HISTFILE="$XDG_DATA_HOME/zsh/history"
bindkey "\e[A" history-search-backward
bindkey "\e[B" history-search-forward

export WORDCHARS='*?_.[]~=&;!#$%^(){}<>'

# Completion
# - Zsh Docs: http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Completion-System
# - Zsh Guide: http://zsh.sourceforge.net/Guide/zshguide06.html#l144
mkdir -p "$XDG_CACHE_HOME/zsh"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Starship Prompt
test -e "/usr/local/bin/starship" && eval "$(starship init zsh)"

# iTerm2
test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"

# NVM
export NVM_DIR="$XDG_CONFIG_HOME/nvm"
test -e "/usr/local/opt/nvm/nvm.sh" && source "/usr/local/opt/nvm/nvm.sh"
test -e "/usr/local/opt/nvm/etc/bash_completion.d/nvm" && source "/usr/local/opt/nvm/etc/bash_completion.d/nvm"

# Aliases
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias l="ls -alh"
alias ls="ls -G"
alias k="kubectl"

# Environment
test -e "$ZDOTDIR/env.local.zsh" && source "$ZDOTDIR/env.local.zsh"

# Terraform
export TF_REGISTRY_CLIENT_TIMEOUT=20

# Brew
export PATH="/usr/local/sbin:$PATH"


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

