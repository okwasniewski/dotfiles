---
name: plaud-sync
description: Sync new Plaud recordings into Bear, Things, Linear, and Notion. Use for /plaud-sync or when the user asks to process, triage, or route Plaud voice notes.
---

# Plaud sync

Pull new Plaud recordings, classify each transcript, route content to Bear, Things, Linear, or Notion. Report what went where.

## Targets and defaults

```
things: create directly
bear:   create directly
linear: propose only (no default team set yet)
notion: propose only (no default database or page set yet)
```

When the user sets a default (Linear team, Notion database), record it here in place of "propose only" and switch that target to direct creation.

## State

State lives in `~/.local/state/plaud-sync/state.json`. Create the directory on first run. Never store state inside dotfiles.

```json
{
  "last_sync": "2026-09-20T12:00:00Z",
  "processed": {
    "<file_id>": { "name": "...", "at": "...", "routed": ["things", "bear:<note title>"] }
  },
  "failed": {
    "<file_id>": { "attempts": 1, "last_error": "404" }
  }
}
```

## Steps

1. Read the state file. First run (no file): use date_from = 7 days ago.
2. List recordings via executor MCP: `tools.plaud_mcp.<connection>.list_files` with `date_from` = date of `last_sync` minus 1 day. Find the exact connection path with `tools.search({ namespace: "plaud_mcp", query: "list files" })`.
3. Drop IDs already in `processed`. Drop IDs in `failed` with attempts >= 3.
4. Fetch `get_transcript` for each remaining recording. On error: bump the `failed` counter, continue with the rest.
5. Classify and route (rules below). Record each recording in `processed` right after routing it.
6. Write the state file. Print the report.

Plaud MCP is read-only. The state file is the only dedup mechanism, keep it accurate.

## Classification

Read the whole transcript first. One recording can route to several targets: a book note with "kup X" inside produces a Bear append and a Things task.

- Tasks: the speaker asks to save or remember something, plans the day, lists todos ("zapisz", "musze", "przypomnij", "kup"). Route to Things.
- Book notes: the speaker says it is a note from a book, or the recording name has a `[BookTitle]` prefix. Route to a Bear book note.
- Work items: bugs, features, TesterArmy or project work meant for a team. Route to a Linear proposal in the report.
- Company documentation: meeting notes, decisions, process docs meant for the TesterArmy workspace. Route to a Notion proposal in the report.
- Anything else with real content: Bear inbox note tagged `status/to-process`.
- Garbage (test recordings, under 10 meaningful words): skip, mark processed with `routed: ["skipped"]`.
- Unsure: Bear note tagged `status/to-review`, flag it in the report.

## Routing rules

### Things

Use the `things` CLI.

- Verb-first title in Polish. Details go in `--notes` with the source line "Z nagrania Plaud <date>: <name>".
- `--when today` when it is for today, `someday` otherwise. `--deadline` only when the speaker gives a date.
- Known bug: a deadline lands one day early. Verify with `things list` after adding and mention the shift in the report.
- Before adding, run `things search "<keyword>"` to avoid duplicates.

### Bear

Load the `bearcli` skill first.

- Book note title: `<Book> - notatki z ksiazki` (match the existing note by searching for the book title first). Tag: `books/notes`.
- Note exists: append a `## <topic>` section. Missing: create it.
- Write in Polish. Plain language, short sentences. Never use em dashes or en dashes, use hyphens or periods. Fix obvious ASR errors in names and terms. Drop garbled segments instead of transcribing them.
- Inbox notes: derive the title from content, tag `status/to-process`.

### Linear

Never create issues automatically while set to "propose only". Put a proposal in the report: suggested title, one-line body, which team. The user creates it or asks to.

### Notion

Company Notion via executor MCP (`notion_com_openapi`). While set to "propose only", put a proposal in the report: suggested page title, one-paragraph body, suggested location. The user creates it or asks to.

## Report

End with one line per recording: name, classification, destination. Then failures and Linear or Notion proposals. Keep it short.

## Slack saved messages

Second source besides Plaud. Fetch via executor MCP: `slack_com.<connection>.slack_search_public_and_private` with `query: "is:saved"`.

- Track handled messages in the state file under `slack_processed` keyed by `message_ts`.
- Skip: empty bot messages, threads already resolved in context (someone replied with a fix), messages the user only saved as reference.
- Actionable saved messages become Things tasks: verb-first Polish title, permalink plus one-line context in `--notes`, `--when` based on urgency (client-facing goes earliest).
- When a saved message matches an existing task, append the permalink to that task with `things note --append` instead of creating a duplicate.
- Unsure whether still relevant: list it in the report instead of creating a task.

## Voice conventions

Optional markers that make classification deterministic:

- Recording name prefix `[BookTitle]` routes to that book's Bear note.
- "zapisz task ..." routes to Things.
- "do Lineara ..." routes to a Linear proposal.
- "do Notion ..." routes to a Notion proposal.
