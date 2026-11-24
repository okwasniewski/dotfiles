# Workflow

## Stack

- `nix-darwin`: machine config, packages, apps
- `tmux` + `sesh`: terminal sessions, `prefix k` picks a project
- `opencode`, T3 Code: coding agents
- `nvim`, `lazygit`: editing and git

## Remote dev on a runner

Goal: agents run on a runner, you attach from the laptop and they keep working
when you close the lid.

### 1. Bootstrap the runner

```sh
~/dotfiles/scripts/bootstrap.sh devbox
```

Idempotent, re-run any time. It installs Lix, applies the flake host, stows
dotfiles, sets up a local SSH key and turns FileVault off so the box comes back
unattended after a reboot. It prints the manual steps left at the end.

`devbox` is the one profile for every runner, Big Mac included: CLI base, agent
CLIs, the mobile toolchain, Docker, Postgres, T3 Code and Chrome, no desktop
apps. It imports `.nix/common/headless.nix`, which owns the headless bits:
never sleep, restart after power loss, Remote Login, Screen Sharing, and a
launchd agent (`dev.oskar.dotfiles-pull`) that runs `git pull --ff-only` daily
at 09:00.

Reach it over Tailscale rather than port forwarding.

### 2. Same dotfiles on both machines

After nix changes, rebuild on each machine:

```sh
nix-rebuild
```

`nix-rebuild` targets `$DARWIN_HOST` (default `laptop`). The bootstrap script
writes the runner's host (`devbox-<account>`) into its `~/.zshrc.local`.

### 3. Attach

`.ssh/config` has the `bigmac` alias (user `bigmac`, over Tailscale MagicDNS).

```sh
ssh bigmac -t tmux new -A -s main
```

The tmux session outlives the connection, so agents keep running when you
disconnect. For bad links use `mosh bigmac` instead, then `tmux attach`. `mosh`
is installed via nix on every machine.

## Setup / reload

After nix changes:

```sh
nix-rebuild
```

Reload shell:

```sh
exec zsh
```

## Shell layout

`~/.zprofile` owns `PATH`, exported environment and secrets. `~/.zshrc` owns
interactive-only config.

This split is required, not cosmetic: `zsh -lc` is a login but non-interactive
shell that never reads `.zshrc`. launchd agents run that way and have no
inherited PATH at all. Anything a launchd agent or non-interactive tool needs
must be resolvable from `.zprofile`.
