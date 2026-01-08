---
description: Smart commit with conventional format
---

Create well-formatted commit(s) from current changes.

## Rules

1. **Branch safety** - if on main/master, create `oskar/<topic>` branch first
2. **Atomic commits** - suggest splitting if changes touch multiple concerns
3. **Conventional format** - `type(scope): description` under 72 chars
4. **Imperative mood** - "add feature" not "added feature"

## Workflow

### Step 1: Check state

```bash
git branch --show-current
git status --porcelain
git diff --cached --stat
git diff --stat
```

### Step 2: Branch check

If on `main` or `master`:
- Derive branch name from changes automatically
- Create and checkout `oskar/<topic>` branch
- Do NOT ask for confirmation

### Step 3: Stage if needed

If nothing staged but changes exist:
- Stage all changes automatically
- Do NOT ask for confirmation

### Step 4: Analyze diff

```bash
git diff --cached
```

Check if changes should be split:
- Different concerns (unrelated code areas)
- Different types (feature + fix + refactor mixed)
- Different file patterns (source vs config vs docs)

If splitting recommended → suggest breakdown and help stage separately.

### Step 5: Generate message

**Format:** `type(scope): description`

**Types:**
- `feat` - new feature
- `fix` - bug fix
- `refactor` - code change (no new feature/fix)
- `docs` - documentation
- `style` - formatting
- `test` - tests
- `chore` - maintenance

**Scope:** optional, derive from primary directory/module changed

**Description:**
- Under 72 chars
- Focus on "why" not "what"
- Present tense, imperative

### Step 6: Commit

Show proposed message and commit immediately:

```bash
git commit -m "<message>"
```

Do NOT ask for confirmation before committing.

## Examples

Good:
- `feat(auth): add JWT refresh token rotation`
- `fix(api): handle null response in user endpoint`
- `refactor: extract validation logic to shared util`
- `chore: update dependencies`

Bad:
- `updated stuff` (vague)
- `Fixed the bug in the authentication system` (too long, past tense)
- `WIP` (meaningless)
