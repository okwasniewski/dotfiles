---
description: Commit and create PR in one go
---

Commit current changes and create a pull request. Uses `conventional-commit` skill for the commit and `pr-creator` skill for the PR.

## Workflow

1. **Commit phase** — follow `/commit` workflow:
   - Check state: `git status --porcelain && git diff --cached --stat`
   - If on `main`/`master` → create topic branch automatically
   - Stage if nothing staged but changes exist
   - Analyze diff for atomic commit opportunities
   - Generate message using conventional-commit skill format
   - Commit immediately

2. **Push** — push branch to remote with `-u` flag

3. **PR phase** — follow `/pr` workflow:
   - Use pr-creator skill to create PR
   - Include all commits since branching from base
