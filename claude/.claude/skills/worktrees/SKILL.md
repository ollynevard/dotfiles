---
name: worktrees
description: Start, list and clean up work on a ticket in its own git worktree with its own Claude session in herdr. Use when the user asks to start work on a ticket or branch in a project, asks what is in flight, says a branch is done/merged and should be cleaned up, or wants a project converted to the bare worktree layout.
---

# Worktrees

Work happens in one worktree per branch, each with its own Claude session in
its own herdr workspace. Worktrunk (`wt`) manages git; herdr manages terminals
and agents; `wt-herdr` (run by Worktrunk's hooks) ties them together.

## Vocabulary

- **Project**: a folder `~/Code/<project>` in the bare layout: `.bare/` (the
  repository), the **default worktree** (`main/` or `master/`) and one folder per
  other branch, named after it with `/` → `+`.
- **Project group**: the project's herdr parent workspace, labelled with the
  project name, with a shell tab in the default worktree, plus the **worktree
  workspaces** indented under it in herdr's sidebar, one per worktree.
- **Orchestrator**: the Claude session in the herdr workspace **Control** at
  `~/Code`. It starts and cleans up work; it doesn't edit code.

A folder with `.git/` instead of `.bare/` is a normal clone, not yet a project.

## Start work

1. Branch name: follow the project's convention; keep the part after the last
   `/` to the ticket plus 2–3 words (`chore/ENG-717-upgrade-pint`). Never use a
   tracker's generated branch name (Linear's `gitBranchName`).
2. Create the worktree (reuses it if it exists):

   ```bash
   wt -C ~/Code/<project>/main switch --create <branch> --no-cd --yes --format json
   ```

   Drop `--create` for a branch that already exists locally or on origin. The
   hooks copy the files listed in `main/.worktreeinclude` (`.env`, `auth.json`,
   …), pre-trust the folder in Claude and open the worktree workspace in the
   project group, creating the group if needed. Dependencies are not installed:
   the new session sets the project up itself from its README/CLAUDE.md.
3. Find the workspace and its pane (idempotent; also repairs a missing one):

   ```bash
   wt-herdr open ~/Code/<project>/<branch-dir>   # → {workspace_id, pane_id, ...}
   ```

4. Start Claude there and send the opening prompt. Agent name:
   `<project>-<ticket>` lowercase, `[a-z][a-z0-9_-]`, at most 32 characters.

   ```bash
   herdr agent start <name> --kind claude --pane <pane_id> --timeout 60000
   herdr agent prompt <name> "<opening prompt>"
   ```

   If `agent start` reports `agent_not_ready` or the agent is `blocked`, the
   session is waiting on a dialog. Never answer it: tell the user which
   workspace, and send the prompt once they say it's clear.

Follow up with `herdr agent read|wait|prompt <name>`.

## What's in flight

```bash
wt -C ~/Code/<project>/main list --format json          # one project
wt -C ~/Code/<project>/main list --full                 # + PR / CI status
herdr agent list                                        # every session's state
```

Across projects: run the first for each `~/Code/*/.bare`.

## Clean up

When the user says a branch is done or merged:

```bash
wt -C ~/Code/<project>/main remove <branch> --foreground --yes
```

The hooks fast-forward the default worktree first (Worktrunk checks "merged"
against it), then close the worktree workspace and its session. Worktrunk
refuses a worktree with uncommitted changes, and keeps a branch it can't prove
merged ("retained; has unmerged changes"). In both cases tell the user what's
there and ask; only with their say-so run again with `-D` (delete the unmerged
branch) or `-f` (discard changes after Worktrunk backs them up).

## Convert a clone to a project

```bash
bare-migrate <name-under-~/Code> --label "<herdr label>" --yes
```

Ask first: it moves the clone to `<name>-old`, refuses dirty trees, and anything
running from the old path (Docker, dev servers, editors) must be stopped. Never
run it on `~/Code/dotfiles`: configs are symlinked into it. If the project
already has a plain herdr workspace (not a group), offer to close it once the
user has moved any running sessions; `wt-herdr group ~/Code/<project>` creates
the group.

## Rules

- Don't close workspaces, tabs or sessions you didn't create unless asked.
- Services (Docker, dev servers) usually run from one worktree at a time; ask
  before stopping or switching them.
- The group label comes from `git --git-dir ~/Code/<project>/.bare config
  herdr.label`, else the folder name capitalised.
