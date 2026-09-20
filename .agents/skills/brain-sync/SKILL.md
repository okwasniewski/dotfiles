---
name: brain-sync
description: Sync inputs (Plaud recordings, fresh Slack saved messages, flagged mail, Bear inbox) into the second brain - Things tasks and Bear notes. Use for /brain-sync or when the user asks to process, triage, or route notes, voice memos, or saved items.
---

# Brain sync

Gather read-only, propose a routing table, apply only approved rows. Never create or modify anything before approval, even when everything looks obvious. The only writes ever: Things add/append, Bear create/append/retag, Slack reaction on done items, the state file.

## Flow

1. Gather and classify (read-only).
2. Table: # | source | item | destination. Only rows that create or change something. Skips: one closing line with counts per source. No digests, no commentary. Nothing to route: one line, stop.
3. Wait. The user approves all, vetoes rows ("bez 3 i 5"), or reclassifies ("2 do Bear, nie Things").
4. Apply approved rows. Update state for every row, vetoed included.
5. Report: one line per row: source, item, destination or vetoed/failed.

## Targets

```
things: create directly
bear:   create directly
linear: propose only. Proposal = English title, one-line body, team (default Engineering, project by topic)
notion: propose only. Proposal = page title, one-paragraph body, location
```

## State

`~/.local/state/brain-sync/state.json`, create the directory on first run. State is the only dedup mechanism.

```json
{
  "last_sync": "<iso>",
  "processed": { "<source>:<id>": { "name": "...", "at": "<iso>", "routed": ["things", "bear:<note title>"] } },
  "failed": { "<source>:<id>": { "attempts": 1, "last_error": "..." } }
}
```

`source` is plaud, slack, fastmail, superhuman, or bear. `routed` values: `things`, `bear:<title>`, `linear:<id>`, `skipped`, `vetoed`.

## Inputs

Resolve executor connections at runtime with `tools.executor.coreTools.connections.list({})`. Namespaces: plaud_mcp, slack_com, fastmail_mcp, superhuman_mail, linear_app_graphql, notion_com_openapi. Cheap listing first, details only for new items. Skip ids already in `processed`, and `failed` entries with attempts >= 3.

### Plaud

- `list_files` with `date_from` = `last_sync` minus 1 day.
- `get_transcript` per new recording. On error bump `failed`, continue.

### Slack saved

- `slack_search_public_and_private` with `query: "is:saved"`. First page only.
- Older than 14 days: skipped, never listed.
- Silent skip: bot posts, empty messages, Oskar's own messages, links and screenshots saved as reference, threads where context shows someone else handled it, bot-fed alert, escalation, feedback and monitoring channels.
- Row only when a person asks Oskar for something concrete and the thread does not show it done. Route to Things.
- Done confirmed by the user: `slack_add_reaction` with `white_check_mark`. Routing alone gets no reaction.

### Fastmail (personal)

- `search_email` with `in:inbox is:flagged` only. Route to Things with subject, sender, receivedAt in notes. Never triage unread.

### Superhuman (TesterArmy)

- `query_email_and_calendar` cannot filter starred. Ask in natural language for inbox threads since `last_sync` where a person waits on Oskar.
- Silent skip: cold outreach, invoices and receipts, automated notifications.
- Route to Things with subject, sender, thread link in notes. Dedup by thread id.
- Never send, draft, trash, or unsubscribe.

### Bear inbox

- Load the `bearcli` skill. `bearcli search '#status/to-process' --format json`.
- Extract action items into Things, then retag: remove `status/to-process`, add a topic tag, or `status/to-review` when unsure.

### Linear

- Cross-check only, when a Things row may match an issue: `query.issues` with `filter: { assignee: { isMe: { eq: true } }, state: { type: { in: ["started","unstarted"] } } }`. Append matching IDs to task notes.

### Calendars

- Fastmail `search_events`, Superhuman `query_email_and_calendar`. Context only, fetched only when placing a dated task, never in the plan. Avoid days with all-day or travel blocks.

## Classification

Read the whole item. One item can hit several targets.

- Explicit markers win: `[Book]` name prefix routes to that book's Bear note, "zapisz task" to Things, "do Lineara" to a Linear proposal, "do Notion" to a Notion proposal.
- Tasks ("zapisz", "muszę", "przypomnij", "kup", day plans, someone waiting on Oskar): Things.
- Book notes: Bear book note.
- Work items (bugs, features, team work): Linear proposal.
- Company docs (meeting notes, decisions, processes): Notion proposal.
- Other real content: Bear inbox note tagged `status/to-process`, title from content.
- Garbage (test recordings, under 10 meaningful words, stale or bot items): `routed: ["skipped"]`, no row.
- Unsure if noise: skip. Unsure where to route: Bear note tagged `status/to-review`, flagged in the table.

## Routing

### Things (`things` CLI)

- Verb-first Polish title. Notes carry a source line ("Z nagrania Plaud <date>: <name>", "Ze Slacka: <permalink>", "Z maila: <subject>").
- `--when today` for today, a concrete date when known, `someday` otherwise. `--deadline` only when a date is given; it lands one day early, verify with `things list` and mention it.
- Client-facing items get the earliest sensible date.
- `things search "<keyword>"` first. Existing match: `things note --append` instead of a duplicate.

### Bear (`bearcli` skill)

- Book note title `<Book> - notatki z ksiazki`, tag `books/notes`. Search first; exists: append a `## <topic>` section; missing: create.
- Polish, plain, short sentences. Fix obvious ASR errors in names and terms, drop garbled segments.
