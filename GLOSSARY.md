# Glossary

Terms used across the worktree workflow (`bin/`, `worktrunk/`,
`claude/.claude/skills/worktrees/`). The rules behind them live in the Project
module, `bin/.local/lib/bare-project.sh`.

**Project**: a folder `~/Code/<project>` in the bare layout: `.bare/` (the
repository), the default worktree, and one worktree per other branch.
_Avoid_: repo (a Project holds one repository and many checkouts).

**Normal clone**: a folder with `.git/` instead of `.bare/`; not yet a Project.
`bare-migrate` converts one.

**Default worktree**: the worktree that has the default branch checked out
(`main/`, `master/`, ...). The default branch is origin's HEAD, else `main`,
else `master`.

**Worktree**: one checkout per branch, a sibling of `.bare/`, named after the
branch with `/` turned into `+`.

**Project session**: the Project's session in Rex, labelled with the Project's
label (`rex.label` in `.bare/config`, else the folder name capitalised). Its
id is kept in `rex.session` in `.bare/config`. Its first window is the default
worktree.

**Worktree window**: the Rex window (tab) for one worktree in the Project
session, labelled with the last part of the branch name. It's created when
Claude starts there and holds one **Claude** block, where that branch's Claude
session runs.

**Orchestrator**: the Claude session in the Rex session **Control** at
`~/Code`. It starts and cleans up work; it doesn't edit code.

**Trust**: Claude Code's per-folder "trust this folder?" acceptance in
`~/.claude.json`. New worktrees are pre-trusted and lose it when removed.
