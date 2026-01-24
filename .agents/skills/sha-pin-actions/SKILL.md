---
name: sha-pin-actions
description: Update GitHub Actions to latest versions with SHA pinning using actions-up CLI
license: MIT
---

Update GitHub Actions in workflows to use SHA-pinned versions for security and reproducibility.

## Tool

Use `actions-up` CLI - scans workflows and composite actions, checks for updates, pins to exact commit SHAs.

## Commands

### Auto-update all actions

```bash
npx actions-up -y
```

### Interactive mode (select which to update)

```bash
npx actions-up
```

### Dry run (check without changes)

```bash
npx actions-up --dry-run
```

### Custom directory (e.g., Gitea)

```bash
npx actions-up --dir .gitea
```

### Skip specific actions

```bash
npx actions-up --exclude "my-org/.*"
```

### Filter by release age (only updates older than N days)

```bash
npx actions-up --min-age 7
```

## What it does

- Scans `.github/workflows/*.yml` and `.github/actions/*/action.yml`
- Detects reusable workflow calls
- Updates action refs from tags to SHA with version comment
- Warns about breaking changes (major version updates)

## Example transformation

```yaml
# Before
- uses: actions/checkout@v3
- uses: actions/setup-node@v3

# After
- uses: actions/checkout@08c6903cd8c0fde910a37f88322edcfb5dd907a8 # v5.0.0
- uses: actions/setup-node@49933ea5288caeca8642d1e84afbd3f7d6820020 # v4.4.0
```

## Skip updates with comments

```yaml
# actions-up-ignore-next-line
- uses: actions/checkout@v3

- uses: actions/setup-node@v3 # actions-up-ignore
```

## When to use

- Security hardening CI/CD pipelines
- Ensuring reproducible builds
- Updating outdated action versions
- Before merging PRs that touch workflows
