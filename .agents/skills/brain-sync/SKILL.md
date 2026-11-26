---
name: brain-sync
description: Sync inputs (Plaud recordings, fresh Slack saved messages, flagged mail, Craft Unsorted) into the second brain - Things tasks and Craft notes. Use for /brain-sync or when the user asks to process, triage, or route notes, voice memos, or saved items.
---

# Brain sync

Gather read-only, propose a routing table, apply only approved rows. Never create or modify anything before approval, even when everything looks obvious. The only writes ever: Things add/append, Craft create/append/move, Slack reaction on done items, the state file.

## Flow

1. Gather and classify (read-only).
2. Table: # | source | item | destination. Only rows that create or change something. Skips: one closing line with counts per source. No digests, no commentary. Nothing to route: one line, stop.
3. Wait. The user approves all, vetoes rows ("bez 3 i 5"), or reclassifies ("2 do Crafta, nie Things").
4. Apply approved rows. Update state for every row, vetoed included.
5. Report: one line per row: source, item, destination or vetoed/failed.

## Targets

```
things: create directly
craft:  create directly
linear: propose only. Proposal = English title, one-line body, team (default Engineering, project by topic)
notion: propose only. Proposal = page title, one-paragraph body, location
```

## State

`~/.local/state/brain-sync/state.json`, create the directory on first run. State is the only dedup mechanism.

```json
{
  "last_sync": "<iso>",
  "processed": { "<source>:<id>": { "name": "...", "at": "<iso>", "routed": ["things", "craft:<note title>"] } },
  "failed": { "<source>:<id>": { "attempts": 1, "last_error": "..." } }
}
```

`source` is plaud, slack, fastmail, superhuman, or craft. `routed` values: `things`, `craft:<title>`, `linear:<id>`, `skipped`, `vetoed`.

## Inputs

Resolve executor connections at runtime with `tools.executor.coreTools.connections.list({})`. Namespaces: plaud_mcp, slack_com, fastmail_mcp, superhuman_mail, craft, linear_app_graphql, notion_com_openapi. Cheap listing first, details only for new items. Skip ids already in `processed`, and `failed` entries with attempts >= 3.

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

### Superhuman (e2e)

- `query_email_and_calendar` cannot filter starred. Ask in natural language for inbox threads since `last_sync` where a person waits on Oskar.
- Silent skip: cold outreach, invoices and receipts, automated notifications.
- Route to Things with subject, sender, thread link in notes. Dedup by thread id.
- Never send, draft, trash, or unsubscribe.

### Craft Unsorted

- `craft_read` with `documents list --location unsorted`, then `blocks get <rootBlockId> --format markdown` per new document.
- Extract action items into Things, then file the document: `craft_write` with `documents move --document <rootBlockId> --folder <folderId>` into the matching folder (Projects, Areas/*, Resources/*, Archive; resolve ids with `folders list`). Unsure: leave it in Unsorted and flag it in the table.

### Linear

- Cross-check only, when a Things row may match an issue: `query.issues` with `filter: { assignee: { isMe: { eq: true } }, state: { type: { in: ["started","unstarted"] } } }`. Append matching IDs to task notes.

### Calendars

- Fastmail `search_events`, Superhuman `query_email_and_calendar`. Context only, fetched only when placing a dated task, never in the plan. Avoid days with all-day or travel blocks.

## Classification

Read the whole item. One item can hit several targets.

- Explicit markers win: `[Book]` name prefix routes to that book's Craft note, "zapisz task" to Things, "do Lineara" to a Linear proposal, "do Notion" to a Notion proposal.
- Tasks ("zapisz", "muszę", "przypomnij", "kup", day plans, someone waiting on Oskar): Things.
- Book notes: Craft book note.
- Work items (bugs, features, team work): Linear proposal.
- Company docs (meeting notes, decisions, processes): Notion proposal.
- Other real content: new Craft document in Unsorted, title from content.
- Garbage (test recordings, under 10 meaningful words, stale or bot items): `routed: ["skipped"]`, no row.
- Unsure if noise: skip. Unsure where to route: Craft document in Unsorted, flagged in the table.

## Routing

### Things (Things MCP)

Use the `things` MCP server (`things_mcp` in Executor).

- Verb-first Polish title. Notes carry a source line ("Z nagrania Plaud <date>: <name>", "Ze Slacka: <permalink>", "Z maila: <subject>").
- `things_create_task` with `schedule: "today"` for today, a concrete `YYYY-MM-DD` when known, `"someday"` otherwise. `deadline` only when a date is given.
- Client-facing items get the earliest sensible date.
- `things_find_tasks` with `contains_text: "<keyword>"` first. Existing match: `things_edit_item` with `note` set to the old note plus the new line (it replaces the whole note) instead of a duplicate.

### Craft (Craft MCP)

Use the `craft` integration in Executor: `craft_read` and `craft_write`, each taking one `command` string (`<entity> <action> --help` for syntax).

- New note: `documents create --title <title> --destination unsorted`, then `blocks add --id <rootBlockId> --markdown <body>`.
- Book notes live in Resources/Books, title `<Book> - notatki z książki`. `search "<Book> - notatki z książki"` first; exists: `blocks add --id <rootBlockId> --markdown "## <topic>..."`; missing: `documents create --title ... --folder <Books folderId>`.
- Polish, plain, short sentences. Fix obvious ASR errors in names and terms, drop garbled segments.
