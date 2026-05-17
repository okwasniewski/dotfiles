---
name: bearcli
description: Use bearcli to safely read, search, edit, tag, archive, and organize Bear.app notes. Use when working with Bear notes, note IDs, Bear tags, migrations from Obsidian, note cleanup, or personal knowledge management in Bear.
---

# Bear CLI

Use `bearcli` for Bear.app note operations. Prefer structured JSON output and conservative edits.

## When To Use

- User asks to read, summarize, rewrite, or update a Bear note.
- User provides a Bear note ID or title.
- User asks to organize Bear tags or clean imported notes.
- User asks to inspect Bear notes, attachments, tasks, pins, archive, trash, or search results.
- User asks to migrate or clean notes imported from Obsidian.

## Core Rules

- Use `--format json` for all reads and mutations unless plain text is explicitly better.
- Prefer note IDs over titles. Titles are case-insensitive and can collide.
- Never delete or trash notes during cleanup unless explicitly asked.
- Never bulk rewrite note content without first sampling affected notes.
- Preserve modification dates for mechanical cleanup with `--no-update-modified` when supported.
- For bulk tag work, prefer `bearcli tags rename`, `tags add`, `tags remove`, and `tags delete`; they do not change note modification dates.
- Treat Bear tags as content. Escaped or quoted tags inside note bodies can create weird sidebar tags.
- Be careful with `bearcli write`: it replaces the entire note and can remove attachment references if omitted.
- For note rewrites with attachments, read content first and preserve attachment markdown references.

## Discovery

Count notes:

```bash
bearcli list --count --format json
bearcli list --location archive --count --format json
bearcli list --location trash --count --format json
```

List note metadata:

```bash
bearcli list --format json --fields id,title,tags,created,modified,length,todos,done,attachments
bearcli list -n 50 --sort modified:desc --format json --fields id,title,tags,modified,length
```

Read one note:

```bash
bearcli show <note-id> --format json --fields id,title,tags,created,modified,content
bearcli cat <note-id> --format json
```

Search notes:

```bash
bearcli search '@untagged' --format json --fields id,title,tags,length
bearcli search '#work' --format json --fields id,title,tags,matches
bearcli search '@todo' --format json --fields id,title,todos,done
bearcli search '@attachments' --format json --fields id,title,attachments
```

Search within a note:

```bash
bearcli search-in <note-id> --string 'exact text' --format json
```

## Editing Notes

Small exact edit:

```bash
bearcli edit <note-id> --at 'old text' --replace 'new text' --no-update-modified --format json
```

Append or prepend:

```bash
bearcli append <note-id> --content 'text' --format json
```

Full rewrite:

```bash
bearcli show <note-id> --format json --fields hash,content
bearcli write <note-id> --base <hash> --content '<full replacement content>' --format json
```

Use `--base` for full rewrites when possible to avoid overwriting concurrent Bear edits.

## Tag Operations

List tags:

```bash
bearcli tags list --format json
bearcli list --format json --fields id,title,tags | jq '[.[] | .tags[]?] | group_by(.) | map({tag: .[0], count: length}) | sort_by(-.count, .tag)'
```

Rename or merge tags:

```bash
bearcli tags rename old-tag new-tag --force --format json
```

Add or remove tags on one note:

```bash
bearcli tags add <note-id> work work/project --format json
bearcli tags remove <note-id> old-tag --format json
```

Delete a tag from all notes:

```bash
bearcli tags delete --name old-tag --format json
```

## Bear Tagging Model

Use Bear's native strengths:

- Broad top-level tags.
- Nested tags with `/` for detail.
- Few stable parents, more specific children only when useful.
- Keep `@untagged` empty.
- Avoid social/import hashtags as top-level taxonomy.
- Avoid duplicate meaning across tags.

Good parent tags for Oskar's notes:

- `journal`: daily, weekly, monthly, yearly notes.
- `work`: active work notes and project context.
- `engineering`: technical notes by platform/topic.
- `product`: product, startup, GTM, customer, idea notes.
- `writing`: posts, talks, content, website.
- `sources/readwise`: imported reading and highlights.
- `books`: book notes and reading notes.
- `finance`: money, taxes, property, receipts, investments.
- `travel`: trips, packing, conference logistics.
- `health`: training, medical, wellbeing.
- `personal`: home, life admin, hobbies.
- `planning`: goals, productivity, systems.
- `tools`: tools and workflows.
- `security`: security-specific notes.
- `templates`: reusable note templates.
- `status`: workflow state only.

Use `status/to-process` for imported material needing review. Use `status/to-review` when unsure instead of leaving a note untagged.

## Obsidian Import Cleanup

Common cleanup targets:

- Remove migration-only `obsidian` tag after notes have useful tags.
- Merge quoted tags like `"book_note"` into `books/notes`.
- Delete accidental code tags caused by snippets, for example Vim substitution examples.
- Collapse social hashtags from Readwise/TikTok/Twitter imports unless they are genuinely useful.
- Keep source tags like `sources/readwise/articles`, `sources/readwise/tweets`, `sources/readwise/podcasts`.

Safe workflow:

1. Count and sample first.
2. Normalize obvious tags with `tags rename`.
3. Delete noisy tags only after checking affected notes.
4. Tag `@untagged` notes with high-confidence rules.
5. Put ambiguous notes in `status/to-review`.
6. Verify counts and final tag list.

Verification:

```bash
bearcli list --count --format json
bearcli search '@untagged' --count --format json
bearcli tags list --format json
```

## Writing And Summarizing Notes

When rewriting personal notes:

- Keep the user's voice.
- Prefer concise, direct Polish or English matching the note.
- Remove duplicated sections.
- Preserve useful facts and decisions.
- Avoid AI-ish phrases like "overall positive signal" unless the user wants that style.
- Keep tags at the bottom or let `bearcli tags add` manage them.

For hiring notes, a good structure is:

```markdown
# Candidate - hiring

## Pytania
- [x] ...

## Notatki
- ...

## Decyzja
Hire / No hire / Follow-up

Short rationale.
#tag
```

## Common Commands

Open a note in Bear:

```bash
bearcli open <note-id>
```

Archive, restore, trash:

```bash
bearcli archive <note-id> --format json
bearcli restore <note-id> --format json
bearcli trash <note-id> --format json
```

Pin operations:

```bash
bearcli pin list --format json
bearcli pin add <note-id> --format json
bearcli pin remove <note-id> --format json
```

Attachments:

```bash
bearcli attachments list <note-id> --format json
```

## Safety Checklist

Before bulk operations:

- Count affected notes.
- Sample note titles and content.
- Prefer tag mutations over content rewrites.
- Avoid trash/archive unless requested.
- Keep a review queue for ambiguous notes.

After operations:

- Verify note count.
- Verify `@untagged` count.
- Verify final tag list.
- Spot-check edited notes.
