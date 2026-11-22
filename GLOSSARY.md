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

**Project group**: the Project's parent workspace in herdr, labelled with the
Project's label (`herdr.label` in `.bare/config`, else the folder name
capitalised). It keeps a "repo" tab in `.bare/` and a shell tab in the default
worktree.

**Worktree workspace**: the herdr workspace for one worktree, nested under the
Project group, where that branch's Claude session runs.

**Orchestrator**: the Claude session in the herdr workspace **Control** at
`~/Code`. It starts and cleans up work; it doesn't edit code.

**Trust**: Claude Code's per-folder "trust this folder?" acceptance in
`~/.claude.json`. New worktrees are pre-trusted and lose it when removed.
