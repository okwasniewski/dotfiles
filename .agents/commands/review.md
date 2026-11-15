---
description: Review branch changes with auto-fix
---

Review changes on current branch against main/master using the `code-review` skill.

## Workflow

1. Get diff scope (compare against main/master, not upstream):

   ```bash
   # Detect default branch
   DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
   git diff origin/$DEFAULT_BRANCH...HEAD --name-only
   ```

2. Review each changed file using the code-review skill

3. Auto-fix safe issues (unused imports, dead code, console.log, typos)

4. Report findings with summary:

   ```
   AUTO: X fixed | Critical: X | Important: X | Nits: X
   ```

5. Wait for user selection before fixing non-auto issues
