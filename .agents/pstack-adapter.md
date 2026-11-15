# pstack adapter

`arena`, `blast-radius`, `how`, `recall`, `technical-writing`, `unslop` and
`why` are vendored verbatim from pstack (`cursor/plugins`, `pstack/skills/`)
through `npx skills`. `.skill-lock.json` records the upstream tree hash. Update
them with `npx skills update -g` and never edit them in place. Local overrides
go here.

pstack is written for Cursor. Map its names to the tool you run in:

| pstack says | Do this |
| --- | --- |
| `Task` subagent | Your subagent tool: Claude Code `Agent`, opencode `task`. Zed has none, so do the step inline. |
| `readonly: true` | A read-only explore agent (Claude Code `Explore`). Also tell it not to edit files. |
| `AskQuestion` | Your ask-the-user tool, or ask in plain text. |
| Model slugs, `pstack-models.mdc` | Ignore. Use the session model unless the user names one. |
| Another skill in bold or backticks | Read `~/.agents/skills/<name>/SKILL.md` and follow it. If it is not installed (`poteto-mode`, `session-pickup`, `automate-me`, `principle-*`), skip that step and say so. |
| Cursor Automations, Bugbot, cloud agents | Skip and say so. |

Transcripts, for `recall`:

- Claude Code (also T3 Code Claude threads):
  `~/.claude/projects/<slug>/<session>.jsonl`. The slug is the workspace path
  with every `/` and `.` turned into `-`.
- Codex (T3 Code Codex threads): `~/.codex/sessions/YYYY/MM/DD/*.jsonl`.
- opencode: `opencode session list`, then `opencode session export <id>`.
- Zed: `~/Library/Application Support/Zed/threads/`, SQLite, skip unless asked.

Oskar's overrides:

- Dashes: unslop rule 13 bans hyphen-as-dash. Oskar's rule is softer: no em or
  en dashes, but a spaced hyphen ` - ` is fine.
- Concision: unslop rule 33 (no over-compression) applies to docs, PR bodies,
  plans and skills. Chat replies and commit messages stay terse.
