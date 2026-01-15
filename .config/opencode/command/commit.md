---
description: Smart commit with conventional format
---

Create commit(s) from current changes using the `conventional-commit` skill.

## Arguments

- First argument: `$1` - If set to `main`, skip branch safety check and commit directly to main/master

## Workflow

1. Check state: `git status --porcelain && git diff --cached --stat`

2. **Branch check** (skip if first argument is `main`):
   - If on `main`/`master` → create topic branch automatically

3. **Stage** if nothing staged but changes exist

4. **Analyze diff** for atomic commit opportunities:
   - If changes should be split → suggest breakdown, help stage separately

5. **Generate message** using conventional-commit skill format

6. **Commit immediately** — no confirmation needed
