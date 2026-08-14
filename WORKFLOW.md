# Workflow

## Stack

- `nix-darwin`: machine config, packages, apps
- `herdr`: terminal workspace server, panes, tabs, agent state
- `hproj`: jump between projects (was `sesh`)
- `ws`: create/manage git worktree workspaces (was `workmux`)
- `opencode`: coding agent inside each workspace
- `nvim`, `lazygit`: popups when needed

`herdr` self-updates and is not managed by nix. Update with `herdr update`.
`ws` and `hproj` live in `~/dotfiles/bin`.

## Mental model

- herdr is a background server, not an app; agents keep running when you detach
- one herdr workspace ("space") per project or per task worktree
- one agent per workspace, laid out as agent on top, small shell below
- `ws` is the stable daily command, independent of the underlying tool

## Daily commands

### Open a project

```sh
Ctrl-s k
```

Opens the `hproj` popup: pinned projects first, then zoxide frecency. Picking
one focuses its existing workspace or creates it and runs its startup command.

Pinned projects live in `.config/herdr/projects.conf` as
`name<TAB>path<TAB>startup command`.

Non-interactive:

```sh
hproj ~/workspace/some-repo
```

### Create or reopen a task workspace

```sh
ws <name>
```

Examples:

```sh
ws auth-refactor
ws fix-ios-build
```

This will:

- create or reopen a git worktree for the branch
- open it as a herdr workspace, grouped under the repo
- copy gitignored seed files into the checkout
- start `opencode` in the focused top pane
- leave a small shell pane underneath for dev server / tests

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

- `ws list`: list worktrees for this repo, marking which are open
- `ws open <name>`: reopen the workspace for an existing worktree
- `ws close <name>`: close the herdr workspace, keep the checkout
- `ws remove <name>`: `git worktree remove` (add `--force` when dirty)
- `ws merge <name>`: merge into the base branch, then remove worktree + branch
- `ws path <name>`: print filesystem path

Run without a name from inside a worktree and it uses the current branch:

```sh
ws remove
ws merge
```

Rule of thumb:

- `close` = hide the space
- `remove` = delete the checkout
- `merge` = merge + clean up

### Seed files

New checkouts get the gitignored files git will not carry over. Order:

1. `<repo>/.ws.conf` if present
2. otherwise `.config/herdr/ws.conf`

One repo-relative path per line, `#` for comments. This replaces workmux's
`files.copy`.

## Keybindings

Prefix:

```sh
Ctrl-s
```

Panes:

- `Alt-h/j/k/l`: focus pane left/down/up/right
- `Ctrl-s h`: split right
- `Ctrl-s v` or `Ctrl-s -`: split down
- `Ctrl-s x`: close pane
- `Ctrl-s z`: zoom pane
- `Ctrl-s r`: resize mode
- `Ctrl-s Shift-P`: rename pane

Tabs:

- `Ctrl-s c`: new tab
- `Alt-[` / `Alt-]`, or `Ctrl-s p` / `Ctrl-s n`: previous/next tab
- `Ctrl-s 1..9`: jump to tab
- `Ctrl-s Shift-X`: close tab

Spaces (workspaces):

- `Alt-Shift-k` / `Alt-Shift-j`: previous/next space
- `Ctrl-s w`: space picker
- `Ctrl-s Shift-1..9`: jump to space
- `Ctrl-s Shift-N`: new space
- `Ctrl-s Shift-G`: new worktree (prefer `ws <name>`)
- `Ctrl-s Shift-D`: close space

Tools and session:

- `Ctrl-s k`: project picker (`hproj`)
- `Ctrl-s g`: `lazygit` popup
- `Ctrl-s e`: `nvim` popup
- `Ctrl-s Space`: goto / navigate mode
- `Ctrl-s b`: toggle sidebar
- `Ctrl-s ?`: help, shows live bindings
- `Ctrl-s Shift-E`: edit scrollback
- `Ctrl-s Shift-R`: reload config
- `Ctrl-s q`: detach, agents keep running

Changed from tmux, worth remembering:

- `Ctrl-s r` is resize mode now, config reload moved to `Ctrl-s Shift-R`
- pane nav is `Alt` not raw `Ctrl`, so nvim and readline keep their keys
- there is no status line; branch and dirty state show on sidebar space rows

## Agent panel

The sidebar replaces `ws sidebar`. herdr reads every pane and marks agents
`working`, `blocked`, `idle` or `done`, sorted by space. Use it to spot which
agent is waiting on you instead of walking panes.

`done` means finished and not yet seen; focusing the tab turns it into `idle`.

## Persistence

- detach with `Ctrl-s q`, panes and agents keep running
- reattach with `herdr`
- after a server restart, layout is restored, agent conversations resume, and
  pane scrollback replays because `experimental.pane_history` is on
- `herdr server stop` kills the session and its pane processes

## Remote dev on the mac mini

Goal: agents run on the mini, you attach from the laptop and they keep working
when you close the lid.

### 1. Prepare the mini

Enable Remote Login (System Settings > General > Sharing > Remote Login), then
stop it sleeping:

```sh
sudo pmset -a sleep 0 disablesleep 1
```

Reach it over Tailscale rather than port forwarding. Both machines already have
the `tailscale-app` cask.

### 2. Same dotfiles on both machines

Clone this repo on the mini and rebuild. This matters more than it looks: herdr
does not send local custom command keybindings to a remote server, so
`Ctrl-s g/e/k` only work if the config, `ws` and `hproj` exist on the mini.

```sh
nix-rebuild
```

### 3. Install herdr on the mini

```sh
curl -fsSL https://herdr.dev/install.sh | sh
```

`herdr --remote` can install it for you, but doing it explicitly avoids the
interactive prompt and the "`~/.local/bin` is not on PATH" warning.

### 4. Keep the server up across reboots

```sh
ln -sfn ~/dotfiles/launchd/dev.herdr.server.plist \
  ~/Library/LaunchAgents/dev.herdr.server.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.herdr.server.plist
herdr status server
```

The agent starts the server through `zsh -lc` so it inherits `~/.zprofile`.
launchd gives agents almost no PATH otherwise.

To update herdr on the mini, take the agent down first, or `KeepAlive` will
restart the old server before the installer can replace it:

```sh
launchctl bootout gui/$(id -u)/dev.herdr.server
herdr update
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.herdr.server.plist
```

### 5. SSH config on the laptop

```
Host mini
  HostName mini.your-tailnet.ts.net
  User okwasniewski
  ServerAliveInterval 30
  ServerAliveCountMax 6
```

### 6. Attach

```sh
herdr --remote mini
```

Local herdr becomes a thin client: it streams the remote session and bridges the
local clipboard, including image paste. Use the mini's own keybindings so the
popup commands work:

```sh
herdr --remote mini --remote-keybindings server
```

### mosh

Skip it as the default. `herdr --remote` drives its own `ssh`, so mosh cannot be
combined with it, and mosh's main selling point (surviving a dropped link) is
already covered: the herdr server outlives the connection, so you just reattach.

Keep mosh for genuinely bad links, where its predictive local echo helps. That
means the tmux-style path instead of the thin client:

```sh
mosh mini
herdr
```

Trade-offs of that path: no local clipboard or image paste bridging, and the
session uses the mini's keybindings. mosh 1.4+ handles 24-bit colour and OSC 52,
so herdr renders fine; confirm mouse reporting works before relying on it.

`mosh` is installed via nix on both machines.

### From a phone

SSH in with a mobile client and run `herdr`. The TUI switches to a single-column
touch layout on narrow terminals.

## Setup / reload

After nix changes:

```sh
nix-rebuild
```

Reload shell:

```sh
exec zsh
```

Reload herdr config:

```sh
herdr server reload-config
```

Update herdr:

```sh
herdr update
```

## Shell layout

`~/.zprofile` owns `PATH`, exported environment and secrets. `~/.zshrc` owns
interactive-only config.

This split is required, not cosmetic: `zsh -lc` is a login but non-interactive
shell that never reads `.zshrc`. herdr runs custom command bindings that way,
and a launchd-started server has no inherited PATH at all. Anything a popup,
agent pane or launchd agent needs must be resolvable from `.zprofile`.

## Notes

- `ws` is the main muscle-memory command
- keep tool names out of daily habits when possible
- per-project dev server commands can move into the bottom shell pane, or a
  per-repo wrapper later
- `.config/herdr/ws.conf` seeds `apps/website/.env` for the common monorepo case;
  override per repo with `<repo>/.ws.conf`
- override the agent per invocation with `WS_AGENT_CMD`, and the split with
  `WS_AGENT_RATIO`

## Lazygit

- in the `files` panel, `C` generates a commit message with OpenAI, then opens
  the commit editor
- requires `OPENAI_API_KEY`, exported from `.zprofile` so the popup sees it
- optional overrides:
  - `OPENAI_MODEL` default: `gpt-5.4-mini`
  - `OPENAI_API_BASE` default: `https://api.openai.com/v1`
