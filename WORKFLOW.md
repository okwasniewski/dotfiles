# Workflow

## Stack

- `nix-darwin`: machine config, packages, apps
- `tmux` + `sesh`: terminal sessions, `prefix k` picks a project
- `opencode`, T3 Code: coding agents
- `nvim`, `lazygit`: editing and git

## Remote dev on the mac mini

Goal: agents run on the mini, you attach from the laptop and they keep working
when you close the lid.

### 1. Bootstrap the mini

```sh
~/dotfiles/scripts/bootstrap-macmini.sh
```

Idempotent, re-run any time. It installs Lix, applies the `macmini` flake host,
stows dotfiles, sets up a local SSH key and turns FileVault off so the box comes
back unattended after a reboot. It prints the manual steps left at the end.

The `macmini` host (`.nix/hosts/macmini`) owns the headless bits: never sleep,
restart after power loss, Remote Login, Screen Sharing, and a launchd agent
(`dev.oskar.dotfiles-pull`) that runs `git pull --ff-only` daily at 09:00.

Reach it over Tailscale rather than port forwarding.

### 2. Same dotfiles on both machines

After nix changes, rebuild on each machine:

```sh
nix-rebuild
```

`nix-rebuild` targets `$DARWIN_HOST` (default `laptop`). The bootstrap script
sets `DARWIN_HOST=macmini` in the mini's `~/.zshrc.local`.

### 3. SSH config on the laptop

```
Host mini
  HostName oskars-mac-mini
  User bigmac
  ServerAliveInterval 30
  ServerAliveCountMax 6
```

### 4. Attach

```sh
ssh mini -t tmux new -A -s main
```

The tmux session outlives the connection, so agents keep running when you
disconnect. For bad links use `mosh mini` instead, then `tmux attach`. `mosh` is
installed via nix on both machines.

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

## Lazygit

- in the `files` panel, `C` generates a commit message with OpenAI, then opens
  the commit editor
- requires `OPENAI_API_KEY`, exported from `.zprofile` so lazygit sees it
- optional overrides:
  - `OPENAI_MODEL` default: `gpt-5.4-mini`
  - `OPENAI_API_BASE` default: `https://api.openai.com/v1`
