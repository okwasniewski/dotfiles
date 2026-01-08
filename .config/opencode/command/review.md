---
description: Review branch changes with auto-fix
---

Review changes on current branch against upstream. Auto-fix safe issues, surface real bugs.

## Rules

1. **AUTO-FIX safe issues** - unused imports, dead code, console.log, typos
2. **HUNT FOR BUGS** - logic errors, edge cases, race conditions
3. **WAIT for confirmation** - on BUG/FIX items before fixing
4. **BE CONCISE** - one-line items, clickable `path/file.ts:123` links

## Categories

| Tag            | What                                               | Action          |
| -------------- | -------------------------------------------------- | --------------- |
| **[BUG]**      | Logic errors, security, data loss, race conditions | Report → wait   |
| **[FIX]**      | Type gaps, missing error handling, test gaps       | Report → wait   |
| **[AUTO]**     | Unused imports, dead code, console.log, typos      | Fix immediately |
| **[CONSIDER]** | Refactors, style opinions, nice-to-have            | Mention only    |

### AUTO criteria (all must be true)

- Zero risk of breaking behavior
- <5 seconds to fix
- No judgment call needed

### NOT AUTO (needs confirmation)

- Removing "unused" function (might be used elsewhere)
- Type/logic changes
- Any behavioral change

## Workflow

### Step 1: Get diff scope

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "origin/main"
git diff $(git merge-base HEAD @{u})..HEAD --name-only
```

### Step 2: Review each file

1. Read diff for file
2. Categorize issues
3. Auto-fix [AUTO] items immediately
4. Note [BUG]/[FIX]/[CONSIDER] items

### Step 3: Summary

```
AUTO: X fixed | BUG: X | FIX: X | CONSIDER: X

Issues:
1. [BUG] description — `path:line`
2. [FIX] description — `path:line`

Fix options:
- a) BUG + FIX [recommended]
- b) BUG only
- c) All including CONSIDER
- d) Custom (e.g., "1,3")
```

**STOP. Wait for selection.**

## Severity guide

**BUG:** Business logic errors, race conditions, security issues, null/undefined not handled, edge cases that break

**FIX:** Type safety gaps, missing error handling, test coverage gaps, unsafe casts

**CONSIDER:** Refactoring opportunities, style preferences, micro-optimizations
