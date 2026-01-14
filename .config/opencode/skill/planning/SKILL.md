---
name: planning
description: >
  Create and refine implementation plans. Use when breaking down features,
  discussing architecture, or preparing work before coding. Plans focus on
  approach and decisions, not code.
---

# Planning

Plans are thinking tools, not specifications. They capture approach and decisions to guide implementation.

## Plan Template

```markdown
# <name> Plan

**Status:** draft | ready | executing | done
**Created:** <date>

## Goal

<!-- One sentence: what are we building/solving? -->

## Context

<!-- Why now? Constraints? Dependencies? -->

## Approach

<!-- High-level strategy, not code. How will we solve this? -->

## Key Decisions

<!-- Architecture choices, tradeoffs, alternatives considered -->

## Tasks

<!-- Ordered list of what to do. Focus on WHAT not HOW -->

- [ ] Task 1
- [ ] Task 2

## Open Questions

<!-- Unresolved issues to figure out -->

## Notes

<!-- Refinement session notes -->
```

## Refinement Principles

1. **One question at a time** — Don't overwhelm with multiple questions
2. **Explore options** — Propose 2-3 approaches with tradeoffs, recommend one
3. **Capture incrementally** — Write decisions to file as agreed
4. **Surface unknowns** — Note open questions that need answers
5. **Exit gracefully** — When user says "looks good" or conversation ends naturally

## Task Philosophy

Tasks should be **goals**, not implementation details:

| ✅ Good | ❌ Bad |
|---------|--------|
| Add caching layer | Create Redis client in src/cache.ts |
| Refactor auth to use JWT | Replace line 45-60 with jwt.sign() call |
| Add user preferences API | Create file at src/api/preferences.ts with... |
| Improve error handling | Add try-catch to functions X, Y, Z |

Tasks should be:
- **Actionable** — Clear what "done" looks like
- **High-level** — Describe what, not how
- **Independently valuable** — Each delivers something useful
- **Revertable** — Can undo if needed

## Plan Quality

A plan is **ready** when it has:
- Clear goal (one sentence)
- Defined approach (strategy, not code)
- Key decisions documented
- Ordered task list
- Open questions identified (if any)

## Content Rules

- **No code snippets** — Describe what, not how
- **Approach over implementation** — Strategy, not syntax
- **Decisions over details** — Capture why, not exact how
- **Living document** — Update as understanding evolves
