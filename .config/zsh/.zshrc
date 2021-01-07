# Zsh extensions
test -e "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" && source "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
test -e "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" && source "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
test -e "/usr/local/share/zsh-completions" && FPATH="/usr/local/share/zsh-completions:$FPATH"

# History
export HISTFILE="$XDG_DATA_HOME/zsh/history"
bindkey "\e[A" history-search-backward
bindkey "\e[B" history-search-forward

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

