---
name: html-plans
description: "Render implementation plans as elegant editorial HTML documents. Use automatically whenever a plan is created or updated (the user never has to ask), plus for /plan render, 'render this plan', 'pretty plan', or 'plan as html'."
---

# HTML Plans

Render a markdown plan from `.agent/plans/` into a self-contained, book-like HTML document. The markdown stays the source of truth; the HTML is a derived artifact for reading and sharing.

## Rules

- Rendering is automatic: whenever you create or update a plan, re-render its HTML in the same turn. Never wait for an explicit request.
- Iterate, do not proliferate: each plan has exactly one HTML file at `.agent/plans/<name>-plan.html`. On update, edit that file in place with targeted edits matching the markdown diff - never write a new file, add a `-v2`/date suffix, or regenerate the whole document from scratch when only a section changed.
- All plan prose passes through the **unslop** skill before it lands in the markdown or the HTML.
- Source: `.agent/plans/<name>-plan.md` (see the **planning** skill for the plan format). Output: `.agent/plans/<name>-plan.html` next to it.
- Use `references/template.html`. Copy the `<head>` and CSS verbatim - do not restyle, "improve", or inline-tweak the design. Consistency across plans is the point.
- Never edit the HTML by hand to change plan content. Edit the markdown, re-render.
- The document must stay self-contained: one file, CSS inline, fonts via the Google Fonts link already in the template (system serif fallback works offline).

## Content mapping

- Plan title -> `<h1>`, drop the trailing "Plan" if it reads awkwardly. Keep the `Implementation Plan` kicker.
- Status -> the `.status` pill in the meta line. Created date -> the italic meta text, written out ("March 4, 2026").
- Each `##` section -> numbered `<h2>` ("1. Goal", "2. Context", ...). Subsections -> `<h3>` numbered "1.1" style.
- Key Decisions -> `<dl>`: decision as `<dt>`, rationale and alternatives considered as `<dd>`.
- Tasks -> `<ul class="tasks">`; completed (`- [x]`) items get `class="done"`.
- Prose stays prose. Do not convert paragraphs into bullet lists during rendering.
- Footer cites the source markdown path and render date.

## Privacy: local by default

Plans are private. The rendered HTML stays on disk in `.agent/plans/`. Never
upload, publish, or send a plan to any external service unless the user
explicitly asks to share it in this conversation ("share this plan", "publish
this", "give me a postplan link"). Auto-rendering never implies auto-publishing.

After rendering, report the local file path. To let the user read it, offer to
open it locally (`open <file>` or the terminal-browser skill) - no hosting
needed.

## Sharing (opt-in only)

When, and only when, the user explicitly asks to share:

1. Run `npx postplan upload <file-path>`.
2. Report the returned PostPlan URL.

Re-upload the same absolute path to update the existing URL. Use
`npx postplan upload <file-path> --new` only when a new draft is wanted.

If validation fails, fix the markup and retry. If upload needs authentication,
ask the user to run `npx postplan auth login`, then retry.

Never claim the document is hosted before upload succeeds. A request to share
one plan is not standing permission for future plans.
