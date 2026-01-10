---
description: Create PR with gh CLI
---

Create a pull request for current branch using gh CLI.

## Rules

1. **Auto-push** - push branch if not on remote
2. **Smart title** - derive from branch name or commits
3. **Concise body** - bullet summary of changes
4. **No confirmation** - create PR immediately

## Workflow

### Step 1: Check state

```bash
git branch --show-current
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "not-tracking"
git log origin/main..HEAD --oneline
```

### Step 2: Push if needed

If branch not tracking remote:

```bash
git push -u origin HEAD
```

### Step 3: Analyze changes

```bash
git diff origin/main..HEAD --stat
git log origin/main..HEAD --pretty=format:"%s"
```

### Step 4: Create PR

```bash
gh pr create --title "<title>" --body "<body>"
```

**Title format:** Same as commit - `type(scope): description`

**Body format:**

```markdown
## Summary

- bullet 1
- bullet 2
```

### Step 5: Output

Output PR URL in this format:

```
:pr: [PR Title](PR_URL)
```

## Examples

Good titles:
- `feat(auth): add JWT refresh token rotation`
- `fix(api): handle null response in user endpoint`
- `refactor: extract validation logic to shared util`
