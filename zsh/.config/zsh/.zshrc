# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Zsh extensions
test -e "/opt/homebrew/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh" && source "/opt/homebrew/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
test -e "/opt/homebrew/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" && source "/opt/homebrew/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
test -e "/opt/homebrew/opt/zsh-completions/share/zsh-completions" && FPATH="/opt/homebrew/opt/zsh-completions/share/zsh-completions:$FPATH"

# History
mkdir -p "$XDG_STATE_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

export WORDCHARS='*?_.[]~=&;!#$%^(){}<>'

# Completion
# - Zsh Docs: http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Completion-System
# - Zsh Guide: http://zsh.sourceforge.net/Guide/zshguide06.html#l144
mkdir -p "$XDG_CACHE_HOME/zsh"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs false
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
_comp_options+=(globdots)

# Starship Prompt
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
test -e "/opt/homebrew/bin/starship" && eval "$(starship init zsh)"

# NVM
export NVM_DIR="$XDG_CONFIG_HOME/nvm"
test -e "/opt/homebrew/opt/nvm/nvm.sh" && source "/opt/homebrew/opt/nvm/nvm.sh"
test -e "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Vim
#export VIMINIT='set nocp | let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

# Aliases
alias g="git"
alias l="exa --all --long --icons"
alias ls="exa"
alias tree="exa --tree --icons"
alias k="kubectl"
alias pn="pnpm"
alias vim="nvim"
alias v="vim"
alias t="terraform"
alias ze="vim ~/.config/zsh/.zshrc"
alias zr="source ~/.config/zsh/.zshrc"
alias grep="grep --color=always"
alias lzd="lazydocker"
alias pip="pip3"
alias rm="trash-put"

# Environment
test -e "$ZDOTDIR/env.local.zsh" && source "$ZDOTDIR/env.local.zsh"

export EDITOR=nvim

# Terminfo
export TERMINFO_DIRS=$TERMINFO_DIRS:$XDG_DATA_HOME/terminfo

# Terraform
export TF_REGISTRY_CLIENT_TIMEOUT=20

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

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# MacOS settings
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$XDG_CONFIG_HOME/hammerspoon/init.lua"

