# zsh reads $ZDOTDIR/.zshenv instead of ~/.zshenv when ZDOTDIR is already set,
# which it is in any shell started from another (ZDOTDIR is exported): herdr
# panes, exec zsh -l, editor terminals. Pull the real one in. It's safe to
# re-run: typeset -U keeps the first copy of each PATH entry.
source "$HOME/.zshenv"
