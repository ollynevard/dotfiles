# ZSH plugins
test -e "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" && source "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
test -e "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" && source "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Starship Prompt
test -e "/usr/local/bin/starship" && eval "$(starship init zsh)"

# iTerm2
test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"

# NVM
export NVM_DIR="$HOME/.nvm"
test -e "/usr/local/opt/nvm/nvm.sh" && source "/usr/local/opt/nvm/nvm.sh"
test -e "/usr/local/opt/nvm/etc/bash_completion.d/nvm" && source "/usr/local/opt/nvm/etc/bash_completion.d/nvm"

# Aliases
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias k="kubectl"

