---
description: Review branch changes with auto-fix
---

Review changes on current branch against upstream using the `code-review` skill.

## Workflow

1. Get diff scope:

   ```bash
   git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "origin/main"
   git diff $(git merge-base HEAD @{u})..HEAD --name-only
   ```

2. Review each changed file using the code-review skill

3. Auto-fix safe issues (unused imports, dead code, console.log, typos)

4. Report findings with summary:

   ```
   AUTO: X fixed | Critical: X | Important: X | Nits: X
   ```

5. Wait for user selection before fixing non-auto issues
