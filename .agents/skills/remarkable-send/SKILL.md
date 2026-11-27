---
name: remarkable-send
description: Send text to Oskar's reMarkable as a clean, readable PDF through executor. Use for "send this to my reMarkable", "put it on the tablet", "I want to read this on paper", or any request to push a doc, plan, summary, article, thread, or PR write-up to the reMarkable.
---

# reMarkable send

Turn the content into Markdown written for paper, render and upload it with `remarkable_markdown_to_pdf`, then look at the rendered pages before reporting.

The reader is away from the computer with a pen. They cannot click, search, scroll sideways, or ask what you meant. The document has to stand on its own.

## Renderer limits

The server renders a 4:3 page that fills the tablet screen: 11pt Literata body, Newsreader headings, a wide right margin left empty for pen notes, title and page number in the footer. Nothing in the Markdown can restyle it, so the writing has to fit it. The style lives in the homelab repo at `zima/remarkable-mcp/render.py`; change the look there, not here.

```
renders:   h1-h4, paragraphs, bold, italic, inline code, links,
           ordered and bullet lists (3 levels), tables, code blocks,
           blockquote, horizontal rule
dropped:   images (replaced by "[Image omitted]")
literal:   ~~strike~~, - [ ] tasks, footnotes, raw HTML, definition lists
code:      lines are CLIPPED after 60 chars, never wrapped
quote:     lines of one blockquote merge into a single paragraph
```

## Document shape

1. `# Title` once. Says what the document is about, not what kind of document it is.
2. Meta line in italics right under it: `*Nov 27, 2026 · source or author · kind*`. Kind is one or two words: proposal, PR summary, meeting prep, article.
3. `## Summary` first. Three to five sentences that carry the whole point. Someone who reads only this section should know the conclusion and what is asked of them.
4. Body in `##` sections, ordered so each one only needs the ones before it. `###` when a section has real parts. Avoid `####`.
5. When the document wants a reaction, end with `## Open questions` or `## Decisions`: a numbered list, one question per item, phrased so it can be answered with a pen mark.
6. `## Sources` last, only when the reader may want to find something later. Link text is what gets read on paper, so write the short URL or `repo#123` as the text.

## Explaining a topic

For "research X and send it" or "help me understand X". The test: after one read Oskar can explain X to someone else and knows whether it matters to his work. Completeness is not the goal.

The reader is a senior engineer and CTO, deep in React Native and native mobile, building AI agents that test apps. Start from zero in the field at hand: assume he has never heard its basic words. Anchor new ideas to his world: simulators and emulators, Docker, CI, build systems, JS runtimes.

A from-zero explainer is the default. Commands, API calls and a hands-on section belong in a second, deeper document, sent only when he asks to go further or already knows the field.

### Research first

- Primary sources: official docs, the spec, the repo, the original paper. Third-party posts only for who uses what.
- Find the current version and its date. The meta line names the version the document describes.
- A number says where it comes from in a few words. A claim from memory or from a third party says so in the same sentence.
- When a question he asked has no sourced answer, say so, list where you looked, and mark any guess as a guess. Never fill the gap with a plausible story.

### Order

The story runs problem, what people tried, where that failed, the new idea, how it works. Each is a `##` section with a title about the topic, not the label below. Skip one only when there is truly nothing to say.

1. **Summary.** What it is in one plain sentence, why it was made, why he would care.
2. **The problem.** The situation that needs solving, with no jargon at all.
3. **Words you need.** The three or four base concepts everything else rests on, each defined in plain words and tied to something he already uses. One small diagram if it carries the core contrast.
4. **Prior art.** One section per earlier approach: how it works, what it does well, what it costs. The costs are what the topic exists to fix.
5. **Where its makers were stuck.** Who built it, what they ran before, and the concrete bottleneck, with numbers.
6. **The idea.** The one insight, stated as what was kept and what was thrown away. Then a table: choice, why, what it costs.
7. **How the pieces sit.** One ASCII diagram, then a short paragraph per part in the order the diagram reads.
8. **What it bought.** Before and after in a table.
9. **The name**, when it is not self-explanatory.
10. **How it went.** Four or five dated lines, not a history chapter.
11. **What you give up.** Limits, and what it leaves to you.
12. **Where you meet it.** Products built on it, and where it touches his stack.
13. **Terms.** Flip-back glossary, one line each.
14. **Check yourself.** Five questions that can only be answered by someone who got the main idea. This replaces Open questions.

### How to explain

- Plain words. Short sentences. If a twelve year old would not know the word, define it or replace it.
- No term is used before it is defined. Introduce it in bold with a plain definition, then use that exact word every time. No synonyms for variety.
- Pick one image for the central idea and carry it through the whole document ("the wall", "the pretend PC"). Do not mix metaphors.
- Every section opens with its conclusion in one sentence. The rest supports it.
- Concrete before abstract: the example or number first, the general rule after.
- One new concept per paragraph.
- Every design choice gets its why and its cost. A fact without a reason does not stick.
- Numbers carry a unit and a comparison point: "125 ms, against seconds for a normal VM".
- Stop before details that only matter to someone building it.
- Budget 6 to 10 pages. Over that, cut depth, not sections.

## Someone else's text

An article, post, or doc the user wants to read as written is sent verbatim. Fetch the full text, not a summary of it.

- Keep the author's words, headings and order. No added summary, no open questions, no unslop pass.
- Strip site chrome: navigation, share buttons, tags, comments, related posts.
- Meta line names the publication date and the site or author. `## Sources` holds the short URL.
- Code and tables still follow the limits below; reflow them without changing what they say.

The Writing section below applies to text you write or rewrite.

## Writing

- Self-contained. Never point at a link for content the reader needs; inline it. Define an acronym or internal name the first time it appears.
- Prose for reasoning, lists for parallel items, tables for comparisons. Do not shred an argument into bullets.
- Short paragraphs, two to four sentences. One idea each.
- Bold for the few terms the eye should land on when flipping back. Not for emphasis in running text.
- Cut what the reader would skip: recaps of the request, process notes, hedging, closing summaries that repeat the opening one.
- Write in the language of the source material.
- Run the prose through the **unslop** skill. No em or en dashes.

## Code

- Hard limit 60 chars per line. Reflow by hand: break arguments onto lines, shorten paths with `...`, drop imports and boilerplate that do not matter to the point.
- At most about 20 lines per block. Show the lines that make the point, not the file.
- No language tag needed, there is no highlighting.
- Before and after belong in two blocks with a sentence between them, not one block with comments.
- Diagrams: ASCII in a code block, within the same 60 chars, or a numbered list of steps.

## Tables

- At most 3 columns, 4 when every cell is one or two words. Column widths are automatic and long cells squeeze the rest.
- Wider data becomes one `###` per row with a short list under it.
- No inline code longer than about 20 chars in a cell.

## Send

Resolve the connection at runtime with `tools.executor.coreTools.connections.list({})`, integration `remarkable_mcp`.

```ts
const r = tools.remarkable_mcp.user.<connection>;
const res = await r.remarkable_markdown_to_pdf({
  markdown,
  document_name: "Zero-config testing for React Native",
  parent_folder: "/Inbox",
});
```

- `document_name`: the title, sentence case, under 60 chars. No date, no extension, no dashes.
- `parent_folder`: `/Inbox` unless the user names another. Meeting material goes to `/Meeting Notes`. Do not create folders unasked.

## Check the render

Never report a send you have not looked at.

1. `remarkable_image({ document: "/Inbox/<name>", page })` for page 1 and for every page with a code block or table. The text part of the result gives the page count.
2. Look for: code cut at the right edge, a table column squeezed to one word per line, a table row split across pages in a way that hurts, literal Markdown syntax in the text.
3. On a defect, fix the Markdown and send again, then `remarkable_delete` the bad copy. The delete pauses for the user's approval: never approve it yourself, and only ever request it for a document created in this session.

Report: document name, folder, page count. Nothing else unless something could not be rendered as asked.
