---
name: conventional-commit
description: >
  Create well-formatted git commits using Conventional Commits format.
  Use when committing changes, reviewing commit messages, or splitting
  changes into atomic commits.
---

# Conventional Commits

The global `commit-msg` hook enforces the format: `type(scope): description`,
types `feat fix docs style refactor perf test build ci chore revert`, optional
`!` for breaking changes, subject up to 72 chars, no em or en dashes. This
skill covers what the hook can't check.

## Subject

- Imperative mood: "add feature", not "added feature".
- Say why when it isn't obvious from the what.
- Scope is optional. Derive it from the main directory or module changed:
  `auth`, `api`, `ui`, `deps`.

## Atomic commits

Split changes that mix:

- unrelated code areas
- types (a feature plus a fix plus a refactor)
- source, config, and docs that don't depend on each other

Each commit should revert cleanly on its own.

## Examples

Good:

```
feat(auth): add JWT refresh token rotation
fix(api): handle null response in user endpoint
refactor: extract validation logic to shared util
```

Bad:

```
fix: updated stuff                              # vague, past tense
feat: add login and fix signup and update deps  # not atomic
```

Breaking changes get `!` (`feat(api)!: change user response format`) or a
`BREAKING CHANGE:` footer in the body.
