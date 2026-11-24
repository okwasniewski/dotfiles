# Dotfiles

Fresh Mac: run the bootstrap with `laptop` or `devbox`.

| Host | For | Gets |
| --- | --- | --- |
| `laptop` | the main machine | everything: desktop apps, App Store apps, Dock |
| `devbox` | any runner, Big Mac included | CLI base, agent CLIs, mobile toolchain, Docker, Postgres, T3 Code, Chrome, headless settings. No desktop apps |

```sh
curl -fsSL https://raw.githubusercontent.com/okwasniewski/dotfiles/main/scripts/bootstrap.sh | bash -s laptop
```

It installs the Command Line Tools, Lix and Homebrew, clones this repo to
`~/dotfiles`, applies the nix-darwin host, stows the dotfiles and prints the
manual steps left (1Password SSH agent, secrets, apps without a cask). Re-run
it any time, it is idempotent.

What a host gets is composed from `.nix/common`: `darwin.nix` and
`packages.nix` go to every Mac, a host adds `mobile.nix` (iOS, Android, React
Native), `backend.nix` (Docker, Postgres) or `headless.nix` (never sleep, SSH,
Screen Sharing, daily dotfiles pull). Put a new tool in the smallest module
that needs it.

Before running it:

- `laptop` expects the macOS account `okwasniewski`. A `devbox` can run under
  any account listed in `devboxUsers` in `.nix/flake.nix`, each one becomes the
  flake host `devbox-<account>`. The script checks and stops early if the
  account is not there.
- On `laptop`, have the Apple ID at hand: on the first run the script opens the
  App Store and waits for the sign-in, because `mas` cannot sign in by itself.

Moving from another Mac: run `scripts/mac-inventory.sh > inventory.txt` on the
old one first and diff its apps, Dock and casks against the nix host.

## Checks

Rules that agents and I kept getting wrong live in hooks, not prose.

Git hooks in `.config/git/hooks`, enabled for every repo by `core.hooksPath`
in `.config/git/config`. Each one runs the repo's own `.git/hooks/<name>`
afterwards, so per-repo hooks keep working.

- `commit-msg`: Conventional Commits subject, max 72 chars, no em or en dashes.
  Merge, revert, fixup and squash messages pass.
- `pre-commit`: no em or en dashes on added lines. Files marked
  `linguist-vendored` or `linguist-generated` in `.gitattributes` are skipped.
- `pre-push`: no checks, only runs the repo's own hook.

Claude Code `PreToolUse` hooks in `.claude/hooks`, registered in
`.claude/settings.json`:

- `package-manager.mjs`: blocks npm, yarn, pnpm or bun when the nearest
  lockfile belongs to another manager. Global installs and registry queries
  (`npm view`) pass.
- `file-guards.mjs`: blocks an edit that pushes a source file past 1000 lines
  or adds a TypeScript `any`.

Test them with `scripts/test-hooks.sh`. Skip a git hook once with
`--no-verify`.

## Agent config

`.agents/` is the single source for every agent tool:

- `.agents/skills/`: skills. `.claude/skills` and `.config/opencode/skills`
  are symlinks to it.
- `.agents/commands/`: slash commands, symlinked as `.claude/commands` and
  `.config/opencode/command`. Write them for both tools: `description`
  frontmatter and `$ARGUMENTS`.
- `.agents/mcp.json`: MCP servers. `scripts/sync-agent-config.mjs` writes them
  into opencode, Zed and `.config/mcp-config.json`. Claude Code keeps user MCP
  servers in `~/.claude.json`, which is machine state, so add new ones there
  with `claude mcp add --scope user --transport http <name> <url>`.

After editing `.agents/`, run `scripts/sync-agent-config.mjs`. CI runs it with
`--check` and fails on drift, together with `scripts/test-hooks.sh`.
