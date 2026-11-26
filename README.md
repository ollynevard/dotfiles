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
2. Dry-runs Stow over every top-level folder except `brew` and `test`, and
   stops if an existing file is in the way. Otherwise it restows them all.
3. Runs `macos.sh` and `mise install`, then lists the manual sign-in steps.

`.stowrc` sets `--target=~`. Without it, Stow would link into the repo's
parent (`~/Code`), because the repo isn't directly under `~`. It also sets
`--no-folding`: Stow makes every folder a real directory and links only files,
so files other tools write next to their config stay out of the repo.

A new package is just a new top-level folder. A new file in an existing package
isn't linked until you re-run `install` (or `stow -R <pkg>`).

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
| `zsh`       | `~/.zshenv`, `~/.config/zsh/` (see [Shell](#shell))           |

## Shell

zsh reads several startup files, each for a different kind of shell. Put each
setting in the file read by the shells that need it:

| File                         | Read by                          | Put here                                                  |
|------------------------------|----------------------------------|-----------------------------------------------------------|
| `~/.zshenv`                  | every zsh, including scripts and `zsh -c` | Exports (`EDITOR`, XDG and tool dirs, Homebrew) and `PATH`. No output, no subprocesses. |
| `~/.config/zsh/.zshenv`      | nested shells, which inherit `ZDOTDIR` and so skip `~/.zshenv` | Only sources `~/.zshenv`. |
| `~/.config/zsh/.zprofile`    | login shells (every new tab on macOS) | Only restores our `PATH` order after macOS's `/etc/zprofile` reshuffles it. |
| `~/.config/zsh/.zshrc`       | interactive shells               | Options, history, key bindings, completion, prompt, tool hooks, aliases. |
| `~/.config/zsh/functions/*`  | interactive shells, on first call | One function per file, body only, named after the function. (Trap functions such as `TRAPWINCH` can't be autoloaded, so `_prompt_setup` defines its own.) |
| `~/.config/zsh/*.local.zsh`  | interactive shells, near the end | Machine-specific settings and secrets. Not tracked.       |

`~/.zshenv` sets `ZDOTDIR`, which is how zsh finds the rest in `~/.config/zsh`.

`.zshrc` runs in numbered stages, and the order matters: `fpath` is complete
before `compinit`, fzf loads before atuin (so atuin gets Ctrl-R), local files
can override everything, and zsh-syntax-highlighting loads last because it
wraps the key bindings that exist when it loads. Add new things to the stage
they belong in.

`zr` re-sources `.zshrc`, including edited functions. A new file in
`functions/` needs `stow -R zsh` (or `./install`) first.

`rm` is a function that moves files to the macOS Trash, so Finder's Put Back
works. `command rm` deletes for real.

### Prompt

Starship draws the prompt (layout and colours in `starship.toml`), and the
`_prompt_*` functions, wired up by `_prompt_setup` right after `starship init`,
add what Starship can't do on its own:

- **Collapsing.** When you press Enter, the prompt shrinks to its rule (the
  previous command's result and time) and `❯ cmd`, so scrollback keeps every
  command and result without repeating the folder and git line. The prompt is
  rendered once per prompt in precmd rather than by Starship on every redraw.
- **Ribbon.** Pills that touch (the git ones) are fused into one ribbon: a
  closing cap followed by an opening cap becomes a single round divider.
- **Blank lines.** A blank line goes before each command's output. To avoid a
  double blank after commands that print nothing, the shell asks the terminal
  for the cursor position before and after each command, and the prompt skips
  its own blank line when the cursor hasn't moved. If the terminal doesn't
  answer, the check switches off for that shell after a 0.3s wait.
- **AWS.** `_prompt_aws` copies `$AWS_PROFILE` into one of two variables so a
  profile with `prod` in its name (any case) shows as a red pill and any other
  as grey.
- **Notifications.** `_prompt_notify` sends a macOS notification when a command
  took 30 seconds or more.

## Tests

```sh
bats test/
```

`test/` covers the worktree scripts and their shared Project module
(`bin/.local/lib/bare-project.sh`) against throwaway repos, plus shellcheck.
`zsh.bats` starts the zsh package in a throwaway HOME: every file parses, an
interactive shell starts without printing anything, `zsh -c` gets the
environment and `PATH`, and `rm` sends the right files to the Trash. `test/`
isn't a Stow package. Terms are defined in [GLOSSARY.md](GLOSSARY.md).

## Not tracked

- `~/.local/share/atuin/`: Atuin's history database and sync key.
- `~/.config/zsh/*.local.zsh`: machine-specific environment and secrets.
- `~/.ssh/config.d/*`: work and other private hosts, pulled in by `Include`.
- `~/.config/gh/hosts.yml`: GitHub auth token.
- `~/.config/omniwm/shell/`: OmniWM's bundled bar and theme defaults, which it
  manages itself. OmniWM's settings window saves through the symlink, so
  changes made there land in the repo.
- Files owned by other tools: `~/.claude/skills/rex` and `~/.config/rex/`
  (Rex), and `~/.agents/skills` (`npx skills`).
