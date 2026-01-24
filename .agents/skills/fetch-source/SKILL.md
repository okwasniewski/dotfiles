---
name: fetch-source
description: >
  Fetch source code for npm packages, Python packages, Rust crates, or GitHub
  repos to understand their implementation. Use when you need to explore a
  library's internals.
---

# Fetch Source Code

Use `opensrc` to download and explore package source code.

## Commands

```bash
npx opensrc <package>           # npm package (e.g., npx opensrc zod)
npx opensrc pypi:<package>      # Python package (e.g., npx opensrc pypi:requests)
npx opensrc crates:<package>    # Rust crate (e.g., npx opensrc crates:serde)
npx opensrc <owner>/<repo>      # GitHub repo (e.g., npx opensrc vercel/ai)
```

## Rules

- Always run in `/tmp` to avoid cluttering working directory
- Use when you need to understand library internals, not just API surface
