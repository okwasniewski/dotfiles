# Dotfiles

1. Clone this repo to `~/`

```sh
git clone git@github.com:okwasniewski/dotfiles.git
```

2. Install Nix (Lix)

```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

3. Build and activate nix-darwin (host: `laptop` or `macmini`)

```sh
cd ~/dotfiles
nix build ./.nix#darwinConfigurations.laptop.system --extra-experimental-features "nix-command flakes"
sudo ./result/sw/bin/darwin-rebuild switch --flake ./.nix#laptop
```

Mac mini: run `scripts/bootstrap-macmini.sh` instead, see `WORKFLOW.md`.

4. Run `stow .` to symlink dotfiles

5. Fix SSH config permissions

```sh
chmod 600 ~/.ssh/config
```

## Checks

Rules that agents and I kept getting wrong live in hooks, not prose.

Git hooks in `.config/git/hooks`, enabled for every repo by `core.hooksPath`
in `.config/git/config`. Each one runs the repo's own `.git/hooks/<name>`
afterwards, so per-repo hooks keep working.

- `commit-msg`: Conventional Commits subject, max 72 chars, no em or en dashes.
  Merge, revert, fixup and squash messages pass.
- `pre-commit`: no em or en dashes on added lines. Files marked
  `linguist-vendored` or `linguist-generated` in `.gitattributes` are skipped.
- `pre-push`: branches must be `oskar/*`. `main`, `master` and the remote's
  default branch are exempt.

Claude Code `PreToolUse` hooks in `.claude/hooks`, registered in
`.claude/settings.json`:

- `package-manager.mjs`: blocks npm, yarn, pnpm or bun when the nearest
  lockfile belongs to another manager. Global installs and registry queries
  (`npm view`) pass.
- `file-guards.mjs`: blocks an edit that pushes a source file past 1000 lines
  or adds a TypeScript `any`.

Test them with `scripts/test-hooks.sh`. Skip a git hook once with
`--no-verify`.
