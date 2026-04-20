# Workflow

## Stack

- `nix-darwin`: machine config, packages, apps
- `tmux`: terminal workspace + pane/window navigation
- `sesh`: jump between tmux sessions/projects
- `workmux`: create/manage isolated git worktrees tied to tmux windows
- `opencode`: coding agent inside each workspace
- `nvim`: popup editor when needed

## Mental model

- one tmux session per project
- one workmux workspace per task/branch
- one agent per workspace
- `ws` is the stable daily command, independent of underlying tool

## Daily commands

### Open project session

Inside tmux:

```sh
Ctrl-s k
```

This opens the `sesh` picker.

### Create or reopen task workspace

```sh
ws <name>
```

Examples:

```sh
ws auth-refactor
ws fix-ios-build
ws docs-update
```

This will:

- create or reopen the worktree
- open a tmux window for it
- start `opencode` in yolo mode
- open a small bottom shell for dev server / tests
- focus the `opencode` pane

### Workspace commands

```sh
ws list
ws open <name>
ws close <name>
ws remove <name>
ws merge <name>
ws path <name>
```

Meaning:

- `ws list`: list all worktrees
- `ws open <name>`: reopen tmux window for existing workspace
- `ws close <name>`: close tmux window only
- `ws remove <name>`: remove worktree
- `ws merge <name>`: merge branch, then clean up
- `ws path <name>`: print filesystem path

If already inside a worktree:

```sh
ws remove
ws merge
```

## tmux navigation

Prefix:

```sh
Ctrl-s
```

Window navigation:

- `Alt-h`: previous window
- `Alt-l`: next window

Pane navigation:

- `Ctrl-h`: left pane
- `Ctrl-j`: down pane
- `Ctrl-k`: up pane
- `Ctrl-l`: right pane

Useful bindings:

- `Ctrl-s r`: reload tmux config
- `Ctrl-s e`: open `nvim` popup
- `Ctrl-s g`: open `lazygit` popup
- `Ctrl-s b`: toggle workmux sidebar

## Sidebar

Show agent overview:

```sh
ws sidebar
```

Move between agents:

```sh
ws sidebar next
ws sidebar prev
ws sidebar jump 1
```

Use sidebar to:

- see active agents
- jump between workspaces
- notice waiting/done agents quickly

## Typical flow

Start project session, then spawn tasks:

```sh
ws feature-a
ws feature-b
ws bugfix-c
```

Then move around using:

- tmux window navigation
- `ws sidebar`
- `ws open <name>`

## Finishing work

Keep branch, remove worktree:

```sh
ws remove <name> --keep-branch
```

Merge + clean everything:

```sh
ws merge <name>
```

Just close the tmux window for later:

```sh
ws close <name>
```

Rule of thumb:

- `close` = hide window
- `remove` = delete worktree
- `merge` = merge + cleanup

## Setup / reload

After nix changes:

```sh
nix-rebuild
```

Reload shell:

```sh
exec zsh
```

Reload tmux:

```sh
Ctrl-s r
```

## Current shell commands

```sh
ws() {
  # `ws foo` => `workmux add -o foo`
  # `ws remove foo` => `workmux remove foo`
}

oc='OPENCODE_EXPERIMENTAL_PLAN_MODE=1 OPENCODE_PERMISSION='"'"'"allow"'"'"' opencode'
```

## Notes

- `ws` is the main muscle-memory command
- keep tool names out of daily habits when possible
- project-specific dev server commands can move into per-project `.workmux.yaml` later
- global workmux file copy currently includes `apps/website/.env` for your common monorepo case
- if that repo needs more custom behavior, add a nested `.workmux.yaml` in `apps/website/`
