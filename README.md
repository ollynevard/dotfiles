# Dotfiles

macOS dotfiles, one [GNU Stow](https://www.gnu.org/software/stow/) package per tool.

## Setup

```sh
git clone git@github.com:ollynevard/dotfiles.git ~/Code/dotfiles
~/Code/dotfiles/install
```

`install` is safe to re-run, and is also how you pick up new packages. It:

1. Installs the Xcode Command Line Tools and Homebrew if they're missing, then
   the Brewfile (`--no-brew` skips this).
2. Creates the folders other tools keep untracked files in (`REAL_DIRS` in the
   script), so Stow links the files inside them rather than the whole folder.
3. Dry-runs Stow over every top-level folder except `brew` and `test`, and
   stops if an existing file is in the way. Otherwise it restows them all.
4. Runs `macos.sh` and `mise install`, then lists the manual sign-in steps.

`.stowrc` sets `--target=~`. Without it, Stow would link into the repo's
parent (`~/Code`), because the repo isn't directly under `~`.

A new package is just a new top-level folder. If the tool also writes its own
files into that config folder, add the folder to `REAL_DIRS`.

## Packages

| Package     | Links to                                                      |
|-------------|---------------------------------------------------------------|
| `atuin`     | `~/.config/atuin/config.toml`                                 |
| `bat`       | `~/.config/bat`                                               |
| `bin`       | `~/.local/bin/*` (worktree scripts), `~/.local/lib/bare-project.sh` |
| `claude`    | `~/.claude/settings.json`, `statusline-command.sh`, `rules/`, `skills/worktrees` |
| `gh`        | `~/.config/gh/config.yml`                                     |
| `ghostty`   | `~/.config/ghostty`                                           |
| `git`       | `~/.config/git`                                               |
| `mise`      | `~/.config/mise`                                              |
| `mycli`     | `~/.config/mycli/myclirc`                                     |
| `nvim`      | `~/.config/nvim`                                              |
| `omniwm`    | `~/.config/omniwm/settings.toml`                              |
| `ssh`       | `~/.ssh/config`                                               |
| `starship`  | `~/.config/starship`                                          |
| `worktrunk` | `~/.config/worktrunk`                                         |
| `zsh`       | `~/.zshenv`, `~/.config/zsh`                                  |

## Tests

```sh
bats test/
```

`test/` covers the worktree scripts and their shared Project module
(`bin/.local/lib/bare-project.sh`) against throwaway repos, plus shellcheck. It
isn't a Stow package. Terms are defined in [GLOSSARY.md](GLOSSARY.md).

## Not tracked

- `~/.local/share/atuin/`: Atuin's history database and sync key.
- `~/.config/zsh/*.local.zsh`: machine-specific environment and secrets.
- `~/.ssh/config.d/*`: work and other private hosts, pulled in by `Include`.
- `~/.config/gh/hosts.yml`: GitHub auth token.
- `~/.config/omniwm/shell/`: OmniWM's bundled bar and theme defaults, which it
  manages itself. OmniWM's settings window saves through the symlink, so
  changes made there land in the repo.
- Files owned by other tools: `~/.claude/hooks/herdr-agent-state.sh` and
  `~/.config/herdr/config.toml` (herdr), and `~/.agents/skills` (`npx skills`).
