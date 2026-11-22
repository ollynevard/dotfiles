# Dotfiles

macOS dotfiles, one [GNU Stow](https://www.gnu.org/software/stow/) package per tool.

## Setup

```sh
git clone --recurse-submodules git@github.com:ollynevard/dotfiles.git ~/Code/dotfiles
cd ~/Code/dotfiles

brew bundle --file brew/Brewfile
mkdir -p ~/.config/omniwm  # so Stow links the file, not the whole folder
stow bat bin claude gh ghostty git mise nvim omniwm ssh starship worktrunk zsh
./macos.sh
```

`.stowrc` sets `--target=~`. Without it, Stow would link into the repo's
parent (`~/Code`), because the repo isn't directly under `~`.

## Packages

| Package     | Links to                                                      |
|-------------|---------------------------------------------------------------|
| `bat`       | `~/.config/bat`                                               |
| `bin`       | `~/.local/bin/*` (worktree scripts)                           |
| `claude`    | `~/.claude/settings.json`, `rules/`, `skills/worktrees`       |
| `gh`        | `~/.config/gh/config.yml`                                     |
| `ghostty`   | `~/.config/ghostty`                                           |
| `git`       | `~/.config/git`                                               |
| `mise`      | `~/.config/mise`                                              |
| `nvim`      | `~/.config/nvim`                                              |
| `omniwm`    | `~/.config/omniwm/settings.toml`                              |
| `ssh`       | `~/.ssh/config`                                               |
| `starship`  | `~/.config/starship`                                          |
| `worktrunk` | `~/.config/worktrunk`                                         |
| `zsh`       | `~/.zshenv`, `~/.config/zsh`                                  |

## Not tracked

- `~/.config/zsh/*.local.zsh`: machine-specific environment and secrets.
- `~/.ssh/config.d/*`: work and other private hosts, pulled in by `Include`.
- `~/.config/gh/hosts.yml`: GitHub auth token.
- `~/.config/omniwm/shell/`: OmniWM's bundled bar and theme defaults, which it
  manages itself. OmniWM's settings window saves through the symlink, so
  changes made there land in the repo.
- Files owned by other tools: `~/.claude/hooks/herdr-agent-state.sh` and
  `~/.config/herdr/config.toml` (herdr), and `~/.agents/skills` (`npx skills`).
