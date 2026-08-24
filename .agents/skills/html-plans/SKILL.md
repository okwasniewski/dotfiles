---
name: html-plans
description: "Render implementation plans as elegant editorial HTML documents. Use automatically whenever a plan is created or updated (the user never has to ask), plus for /plan render, 'render this plan', 'pretty plan', or 'plan as html'."
---

# HTML Plans

Render a markdown plan from `.agent/plans/` into a self-contained, book-like HTML document. The markdown stays the source of truth; the HTML is a derived artifact for reading and sharing.

## Rules

- Rendering is automatic: whenever you create or update a plan, re-render its HTML in the same turn. Never wait for an explicit request.
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

## After rendering

Open the file so the result is visible: prefer the **terminal-browser** skill (shows it next to the conversation), otherwise `open <file>`. Re-render whenever the markdown plan changes.
