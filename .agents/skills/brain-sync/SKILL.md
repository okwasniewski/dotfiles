---
name: brain-sync
description: Sync inputs (Plaud recordings, fresh Slack saved messages, flagged mail, Bear inbox) into the second brain - Things tasks and Bear notes. Use for /brain-sync or when the user asks to process, triage, or route notes, voice memos, or saved items.
---

# Brain sync

Pull new items from every input, classify, PROPOSE the routing, and apply only after the user approves. Never create or modify anything before approval.

## Flow: propose, confirm, apply

1. Gather and classify everything first (read-only calls only).
2. Present the plan as a compact table: # | source | item | destination. Only rows that create or change something. Skipped items are not rows: one closing line with counts per source ("pominięte: Slack 6 botów, Superhuman 2 automaty"). Nothing else in the message: no calendar digest, no Linear digest, no commentary. If there is nothing to route, say so in one line and stop.
3. Wait for approval. The user can approve all, veto single rows ("bez 3 i 5"), or reclassify ("2 do Bear, nie Things").
4. Apply only the approved rows. Update the state file for every row, including vetoed ones (mark them `routed: ["vetoed"]` so they never come back).
5. Report what was actually done.

The confirmation gate is the point of this skill: the user prefers reviewing over full automation to keep slop out of Things and Bear. Do not batch-create silently even when everything looks obvious.

Noise is the other failure mode. A plan full of stale asks and bot posts is as bad as silent creation. When in doubt whether something belongs in the table, drop it and mark it skipped in state.

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
  "slack_processed": { "<message_ts>": { "summary": "...", "routed": "things" } }
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

Only saved messages that are still open work for Oskar. Saved does not mean actionable, most saves are references.

1. Fetch via executor MCP `slack_com.<connection>.slack_search_public_and_private` with `query: "is:saved"`. First page only, never paginate.
2. Dedup by `message_ts` against `slack_processed`.
3. Hard cutoff: anything saved more than 14 days ago is stale. Mark it `routed: "skipped"` in state and never list it. Old saves the user still cares about live in Things already.
4. Silent skip (state only, no row): bot posts and empty messages, messages written by Oskar himself, links and screenshots saved as reference, threads where the context shows someone else already handled it, escalation and alert channels (`#agent-escalation-*`, `#prod-errors`, `#failed-tests*`, `#app-feedback`, `#analytics-issues`).
5. What is left is a person asking Oskar for something concrete and the thread does not show it done. Route to Things.
6. When the user confirms an item is done, add a reaction: `slack_add_reaction({ channel_id, message_ts, emoji: "white_check_mark" })` (the parameter is `emoji`, not `emoji_name`). Routing alone does not get a reaction, done does. Unsaving is not possible via this integration, the user clears Later manually.

### Fastmail (personal mail + calendar)

Official Fastmail MCP via executor: `fastmail_mcp.user.personalFastmailMcp` (read-only token).

- Mail input: `search_email({ query: "in:inbox is:flagged" })` - flagged messages are the user's explicit "handle this" marker, route them to Things with subject, sender, and receivedAt in notes. Do not triage unread mail, too noisy.
- Dedup by message `id` in `fastmail_processed` in the state file.
- Calendar context: `list_calendars` + `search_events({ after, before })`. Use events as planning context when scheduling Things tasks (avoid days with travel, galas, all-day blocks like "[No Work Time]"). Calendar events are never tasks by themselves and never appear in the plan. Only fetch when there is a dated task to place.

### Superhuman (TesterArmy mail + calendar)

Superhuman MCP via executor: `superhuman_mail.user.oskarSuperhuman` (account oskar@tester.army, sits on top of Google Workspace).

- Mail input: `query_email_and_calendar` takes a natural-language `question`, not a Gmail filter, and cannot see starred status. Ask for inbox threads since the last sync where a person waits on Oskar (client asks, receipts required). Cold outreach, invoices, receipts already routed, and automated notifications are silent skips. Route hits to Things with subject, sender, and thread link in notes. Dedup by `thread_id` in `superhuman_processed`.
- Calendar context: `query_email_and_calendar` for the work calendar, only when placing a dated task. Never in the plan.
- Send/draft/trash tools exist: never send, trash, or unsubscribe during sync. Drafting only when the user asks.
- `gmail_mcp` and `google_calendar_mcp` integrations exist as a fallback (need GCP OAuth client, unfinished).

### Bear inbox

1. `bearcli search '#status/to-process' --format json` (load the `bearcli` skill).
2. For each note: extract action items into Things, then retag the note (`tags remove status/to-process`, add the right topic tag or `status/to-review` if unsure).

### Linear

Cross-check only, and only when the plan has a Things row that might match an issue: `linear_app_graphql.<connection>.query.issues` with `filter: { assignee: { isMe: { eq: true } }, state: { type: { in: ["started","unstarted"] } } }`. Append matching issue IDs to task notes. Never mass-create tasks, never list assigned issues in the plan.

## Classification

Read the whole item first. One item can route to several targets: a book note with "kup X" inside produces a Bear append and a Things task.

- Tasks: the speaker/author asks to save or remember something, plans the day, lists todos ("zapisz", "musze", "przypomnij", "kup"), or someone is waiting on the user. Route to Things.
- Book notes: said to be a note from a book, or the recording name has a `[BookTitle]` prefix. Route to a Bear book note.
- Work items: bugs, features, TesterArmy or project work meant for a team. Route to a Linear proposal in the report.
- Company documentation: meeting notes, decisions, process docs for the TesterArmy workspace. Route to a Notion proposal in the report.
- Anything else with real content: Bear inbox note tagged `status/to-process`.
- Garbage (test recordings, under 10 meaningful words, empty bot posts, stale saves): mark processed with `routed: ["skipped"]`, no row in the plan.
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

After applying: one line per item: source, name, destination (or vetoed/failed). Keep it short. Linear and Notion items stay proposals inside the plan table; creating them needs its own explicit ask.
## Voice conventions

Optional markers that make classification deterministic:

- Recording name prefix `[BookTitle]` routes to that book's Bear note.
- "zapisz task ..." routes to Things.
- "do Lineara ..." routes to a Linear proposal.
- "do Notion ..." routes to a Notion proposal.
