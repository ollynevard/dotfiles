# Read by login shells (every new terminal tab on macOS), after /etc/zprofile.
# /etc/zprofile runs path_helper, which puts the system directories back in
# front of ours, so restore our order. Defined in ~/.zshenv.
dotfiles_path
