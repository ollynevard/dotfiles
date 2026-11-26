---
name: worktrees
description: Start, list and clean up work on a ticket in its own git worktree with its own Claude session in Rex. Use when the user asks to start work on a ticket or branch in a project, asks what is in flight, says a branch is done/merged and should be cleaned up, or wants a project converted to the bare worktree layout.
---

# Worktrees

Work happens in one worktree per branch, each with its own Claude session in
its own Rex window. Worktrunk (`wt`) manages git; Rex manages terminals;
`wt-rex` (also run by Worktrunk's hooks) ties them together.

## Vocabulary

Full definitions: `~/Code/dotfiles/GLOSSARY.md`.

- **Project**: `~/Code/<project>` with `.bare/` (the repository), the **default
  worktree** (`main/` or `master/`) and one worktree folder per other branch.
- **Project session**: the Project's Rex session. Its first window is the
  default worktree; each other worktree is a **worktree window** in it,
  labelled with the last part of the branch name.
- **Orchestrator**: the Claude session in the Rex session **Control** at
  `~/Code`. It starts and cleans up work; it doesn't edit code.

A folder with `.git/` instead of `.bare/` is a normal clone, not yet a Project.
Don't build worktree paths yourself: take them from command output.

## Start work

1. Branch name: follow the project's convention; keep the part after the last
   `/` to the ticket plus 2–3 words (`chore/ENG-717-upgrade-pint`). Never use a
   tracker's generated branch name (Linear's `gitBranchName`).
2. Create the worktree (reuses it if it exists):

   ```bash
   wt -C ~/Code/<project>/main switch --create <branch> --no-cd --yes --format json
   ```

   Drop `--create` for a branch that already exists locally or on origin. The
   JSON's `path` is the worktree folder. The hooks copy the files listed in
   `main/.worktreeinclude` (`.env`, `auth.json`, …), pre-trust the folder in
   Claude and create the Project session if needed. Dependencies are not installed: the new session sets the
   project up itself from its README/CLAUDE.md.
3. Start Claude in the worktree window with the opening prompt:

   ```bash
   wt-rex claude <path> "<opening prompt>"   # → {claude_block_id, started, ...}
   ```

   It creates the worktree window with a single **Claude** block (the user
   splits it when they want a shell there). It's idempotent: if `started` is
   false, Claude was already running there and the prompt was not sent; read
   the block before sending anything.

Follow up with the block id (`-s` takes the session id or label):

```bash
rex capture -s <session> -b <block> --trim | tail -40   # read the screen
rex send -s <session> -b <block> "<text>" && rex send-key -s <session> -b <block> enter
```

If the screen shows a dialog (trust, permission, a question), never answer it:
tell the user which session and window, and send the prompt once they say it's
clear.

## What's in flight

```bash
wt-rex agents                                           # every agent's state (working, blocked, idle, done)
wt -C ~/Code/<project>/main list --format json          # one project
wt -C ~/Code/<project>/main list --full                 # + PR / CI status
```

Across projects: run `wt list` for each `~/Code/*/.bare`.

## Clean up

When the user says a branch is done or merged:

```bash
wt -C ~/Code/<project>/main remove <branch> --foreground --yes
```

The hooks fast-forward the default worktree first (Worktrunk checks "merged"
against it), then close the worktree window and its Claude session. Worktrunk
refuses a worktree with uncommitted changes, and keeps a branch it can't prove
merged ("retained; has unmerged changes"). In both cases tell the user what's
there and ask; only with their say-so run again with `-D` (delete the unmerged
branch) or `-f` (discard changes after Worktrunk backs them up).

## Convert a clone to a project

```bash
bare-migrate <name-under-~/Code> --label "<label>" --yes
```

Ask first: it moves the clone to `<name>-old`, refuses dirty trees, and anything
running from the old path (Docker, dev servers, editors) must be stopped. Never
run it on `~/Code/dotfiles`: configs are symlinked into it. If the project
already has a plain Rex session, offer to close it once the user has moved any
running work; `wt-rex group ~/Code/<project>` creates the Project session (it
adopts an existing session with the Project's label).

## Rules

- Don't close sessions, windows or blocks you didn't create unless asked.
- Services (Docker, dev servers) usually run from one worktree at a time; ask
  before stopping or switching them.
- To relabel a Project session, set `git --git-dir ~/Code/<project>/.bare config
  rex.label "<label>"` and rename the session (`rex session rename`).
