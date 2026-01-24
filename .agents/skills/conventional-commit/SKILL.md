---
name: conventional-commit
description: >
  Create well-formatted git commits using Conventional Commits format.
  Use when committing changes, reviewing commit messages, or splitting
  changes into atomic commits.
---

# Conventional Commits

Create atomic, well-formatted commits following the Conventional Commits spec.

## Format

```
type(scope): description
```

- **Under 72 characters**
- **Imperative mood** — "add feature" not "added feature"
- **Focus on "why"** not "what"

## Types

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code change (no new feature/fix) |
| `docs` | Documentation only |
| `style` | Formatting, whitespace |
| `test` | Adding/updating tests |
| `chore` | Maintenance, dependencies |
| `perf` | Performance improvement |
| `ci` | CI/CD changes |

## Scope

Optional. Derive from primary directory/module changed.

Examples: `auth`, `api`, `ui`, `build`, `deps`

## Atomic Commits

Split changes if they touch:
- Different concerns (unrelated code areas)
- Different types (feature + fix + refactor mixed)
- Different file patterns (source vs config vs docs)

Each commit should be independently revertable.

## Examples

**Good:**
```
feat(auth): add JWT refresh token rotation
fix(api): handle null response in user endpoint
refactor: extract validation logic to shared util
chore: update dependencies
docs(readme): add setup instructions
```

**Bad:**
```
updated stuff                              # vague
Fixed the bug in the authentication        # past tense, too long
WIP                                        # meaningless
feat: add login and fix signup and update deps  # not atomic
```

## Breaking Changes

For breaking changes, add `!` after type/scope:

```
feat(api)!: change response format for user endpoint
```

Or add `BREAKING CHANGE:` in commit body.
