---
name: brain-sync
description: Sync inputs (Plaud recordings, Slack saved messages, GitHub, Bear inbox, Linear) into the second brain - Things tasks and Bear notes. Use for /brain-sync or when the user asks to process, triage, or route notes, voice memos, or saved items.
---

# Brain sync

Pull new items from every input, classify, route into the second brain (Things + Bear), propose Linear/Notion items. Report what went where.

## Targets and defaults

```
things: create directly
bear:   create directly
linear: propose only (no default team set yet; when approved: team Engineering, project by topic)
notion: propose only (no default database or page set yet)
```

When the user sets a default, record it here and switch that target to direct creation.

## State

State lives in `~/.local/state/brain-sync/state.json`. Create the directory on first run. Never store state inside dotfiles. State is the only dedup mechanism, keep it accurate.

```json
{
  "last_sync": "2026-09-20T12:00:00Z",
  "processed": { "<plaud_file_id>": { "name": "...", "at": "...", "routed": ["things", "bear:<note title>"] } },
  "failed": { "<plaud_file_id>": { "attempts": 1, "last_error": "404" } },
  "slack_processed": { "<message_ts>": { "summary": "...", "routed": "things" } },
  "github_processed": { "<notification_or_pr_id>": { "summary": "...", "routed": "things" } }
}
```

## Inputs

Run the cheap listing calls first, fetch details only for new items.

### Plaud (voice notes)

1. List via executor MCP `plaud_mcp.<connection>.list_files` with `date_from` = date of `last_sync` minus 1 day. Find the connection with `tools.search({ namespace: "plaud_mcp", query: "list files" })`.
2. Drop processed IDs and failed IDs with attempts >= 3.
3. `get_transcript` per new recording. On error bump `failed`, continue.
4. Plaud MCP is read-only, recordings cannot be archived remotely.

### Slack saved messages

1. Fetch via executor MCP `slack_com.<connection>.slack_search_public_and_private` with `query: "is:saved"`.
2. Dedup by `message_ts` against `slack_processed`.
3. Skip: empty bot messages, threads already resolved in context, pure-reference saves.
4. After routing, add a white_check_mark reaction to the message (`slack_add_reaction`) as a "handled" marker. Unsaving is not possible via this integration, the user clears Later manually.

### GitHub

1. `gh api notifications` plus `gh pr status` and review requests (`gh search prs --review-requested=@me --state=open`).
2. Dedup by notification/PR id in `github_processed`.
3. Route review requests and failing CI on own PRs to Things. Skip bot noise and already-merged threads.

### Bear inbox

1. `bearcli search '#status/to-process' --format json` (load the `bearcli` skill).
2. For each note: extract action items into Things, then retag the note (`tags remove status/to-process`, add the right topic tag or `status/to-review` if unsure).

### Linear

Input, cross-check only: `linear_app_graphql` query for issues assigned to me in started/unstarted states. Use them to enrich related Things tasks (append issue IDs to notes), never to mass-create tasks.

## Classification

Read the whole item first. One item can route to several targets: a book note with "kup X" inside produces a Bear append and a Things task.

- Tasks: the speaker/author asks to save or remember something, plans the day, lists todos ("zapisz", "musze", "przypomnij", "kup"), or someone is waiting on the user. Route to Things.
- Book notes: said to be a note from a book, or the recording name has a `[BookTitle]` prefix. Route to a Bear book note.
- Work items: bugs, features, TesterArmy or project work meant for a team. Route to a Linear proposal in the report.
- Company documentation: meeting notes, decisions, process docs for the TesterArmy workspace. Route to a Notion proposal in the report.
- Anything else with real content: Bear inbox note tagged `status/to-process`.
- Garbage (test recordings, under 10 meaningful words, empty bot posts): mark processed with `routed: ["skipped"]`.
- Unsure: Bear note tagged `status/to-review`, flag it in the report.

## Routing rules

### Things

Use the `things` CLI.

- Verb-first title in Polish. Details in `--notes` with a source line ("Z nagrania Plaud <date>: <name>", "Ze Slacka: <permalink>", "Z GitHub: <url>").
- `--when today` when it is for today, a concrete date when known, `someday` otherwise. `--deadline` only when a date is given.
- Known bug: a deadline lands one day early. Verify with `things list` after adding and mention the shift in the report.
- Client-facing items get the earliest sensible date.
- Before adding, run `things search "<keyword>"`. When the item matches an existing task, append the link with `things note --append` instead of duplicating.
- Rescheduling is AppleScript, not the CLI: `tell application "Things3" to schedule (item 1 of (to dos of list "Upcoming" whose name is "X")) for ((current date) + N * days)`. Flat statements only, handlers break `schedule`.

### Bear

Load the `bearcli` skill first.

- Book note title: `<Book> - notatki z ksiazki` (search for the book title first). Tag: `books/notes`.
- Note exists: append a `## <topic>` section. Missing: create it.
- Write in Polish. Plain language, short sentences. Never use em dashes or en dashes, use hyphens or periods. Fix obvious ASR errors in names and terms. Drop garbled segments instead of transcribing them.
- Inbox notes: derive the title from content, tag `status/to-process`.

### Linear

Never create issues automatically while set to "propose only". Put a proposal in the report: suggested title, one-line body, which team. English titles and descriptions.

### Notion

Company Notion via executor MCP (`notion_com_openapi`). While set to "propose only", put a proposal in the report: suggested page title, one-paragraph body, suggested location.

## Report

End with one line per item: source, name, classification, destination. Then failures and Linear or Notion proposals. Keep it short.

## Voice conventions

Optional markers that make classification deterministic:

- Recording name prefix `[BookTitle]` routes to that book's Bear note.
- "zapisz task ..." routes to Things.
- "do Lineara ..." routes to a Linear proposal.
- "do Notion ..." routes to a Notion proposal.
