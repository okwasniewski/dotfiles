# pstack adapter

`blast-radius`, `how`, `recall`, `technical-writing`, `unslop` and `why` are
vendored verbatim from pstack (`cursor/plugins`, `pstack/skills/`) through
`npx skills`. `.skill-lock.json` records the upstream tree hash. Update them
with `npx skills update -g` and never edit them in place. Local overrides go
here.

pstack is written for Cursor. Map its names to the tool you run in:

| pstack says | Do this |
| --- | --- |
| `Task` subagent | Your subagent tool: Claude Code `Agent`, opencode `task`. Zed has none, so do the step inline. |
| `readonly: true` | A read-only explore agent (Claude Code `Explore`). Also tell it not to edit files. |
| `AskQuestion` | Your ask-the-user tool, or ask in plain text. |
| Model slugs, `pstack-models.mdc` | Ignore. Use the session model unless the user names one. |
| Another skill in bold or backticks | Read `~/.agents/skills/<name>/SKILL.md` and follow it. If it is not installed (`arena`, `poteto-mode`, `session-pickup`, `automate-me`, `principle-*`), skip that step and say so. |
| Cursor Automations, Bugbot, cloud agents | Skip and say so. |

Transcripts, for `recall`:

- Claude Code (also T3 Code Claude threads):
  `~/.claude/projects/<slug>/<session>.jsonl`. The slug is the workspace path
  with every `/` and `.` turned into `-`.
- Codex (T3 Code Codex threads): `~/.codex/sessions/YYYY/MM/DD/*.jsonl`.
- opencode: `opencode session list`, then `opencode session export <id>`.
- Zed: `~/Library/Application Support/Zed/threads/`, SQLite, skip unless asked.

Also vendored the same way, outside pstack: `pr-review-canvas`
(`cursor/plugins`, `cursor-team-kit/skills/`) and `show-me`
(`humanlayer/skills`). Both are marked user-invoked only, so read the
`SKILL.md` directly and follow it. Pick one:

- `pr-review-canvas`: "help me understand this PR", or any full review.
- `show-me`: a narrow question about a PR or code ("how does X flow now",
  "what changed in Y"), including follow-ups after a canvas.

Where either one serves or `open`s an HTML file:

- T3 Code: show the file with `html_preview`, then `html_render`. No server.
- Terminal: `open /tmp/pr-review-<n>.html`. No server needed, the page is
  self-contained.

`pr-review-canvas` fixes:

- Fetch: also run `gh pr view <n> -R <owner>/<repo> --json
  commits,reviews,comments,statusCheckRollup`. The skill's calls miss commits,
  review verdicts, top-level comments and CI.
- Assembly: in the Python script, read `styles.css`, `renderer.js` and
  `template.html` from `~/.agents/skills/pr-review-canvas/`, not by relative
  path.
- Imports: `renderer.js` hides every import line, added ones too. When a PR
  adds a dependency or a new module, say so in the file note.
- Keys: a `data-diff` key missing from the patches JSON renders nothing, with
  no error. Before showing the page, check every key resolves:

  ```bash
  comm -23 \
    <(grep -o 'data-diff="[^"]*"' /tmp/pr-review-<n>-body.html | cut -d'"' -f2 | sort -u) \
    <(jq -r 'keys[]' /tmp/pr-patches-<n>.json | sort)
  ```

  Empty output means all keys match.

`show-me` for a PR: read the PR body and full diff first, keep to two or three
visuals, and end with a short list of what a reviewer should check.

Oskar's overrides:

- Dashes: unslop rule 13 bans hyphen-as-dash. Oskar's rule is softer: no em or
  en dashes, but a spaced hyphen ` - ` is fine.
- Concision: unslop rule 33 (no over-compression) applies to docs, PR bodies,
  plans and skills. Chat replies and commit messages stay terse.
