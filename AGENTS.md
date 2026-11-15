## About Me

Oskar, co-founder & CTO of e2e (https://e2e.com, formerly TesterArmy,
YC-backed). GitHub org: `e2e-inc`. Based in Poland. Loves to build new things.

**Background:** React Native and its native layers. Former React Native Core
Contributor, shipped React Native visionOS, Bottom Tabs, Liquid Glass,
Brownfield. Speaker at React Native conferences, writes technical blog posts.

Personal website: https://oskarkwasniewski.dev

---

- In chat and commit messages, be extremely concise and sacrifice grammar for
  the sake of concision.

- No em dashes or en dashes (U+2014, U+2013) anywhere: chat, comments, commit
  messages, docs, product copy. Use a plain hyphen (-) or rewrite. Leave
  existing dashes in code you did not write alone.

## Git

Name branches `oskar/<topic>`. Prefix git commands with `GIT_EDITOR=true` so
they never wait on an editor.

## Checks

These rules are enforced by hooks. When one fires, fix the cause instead of
bypassing it with `--no-verify`.

- Git (`~/.config/git/hooks`, every repo): Conventional Commits subject up to
  72 chars; no em or en dashes in commit messages or added lines; pushed
  branches must be `oskar/*` (main, master, default branch exempt).
- Claude Code (`~/.claude/hooks`): the package manager must match the
  lockfile; source files may not cross 1000 lines; no new TypeScript `any`.

## Philosophy

Codebase we are working in will outlive you. Every shortcut you take becomes
someone else's burden. Every hack compounds into technical debt that slows the
whole team down.

You are not just writing code. You are shaping the future of this project. The
patterns you establish will be copied. The corners you cut will be cut again.

Fight entropy. Leave the codebase better than you found it.

## Close the Loop

Implementation without verification is incomplete. After building a feature,
test it. Use available tools to interact with your implementation and verify it
works as expected.

1. Build the feature
2. Run/deploy it
3. Interact with your implementation
4. Verify the result

Never consider a task done until you've seen it work.

## General rules

- Comments: add one only for a non-obvious why that the code cannot say. No
  JSDoc or "what this renders" comments by default. Follow the file's existing
  convention when it has one.
- Always clone temporary repositories to /tmp.

- Always lookup the latest version of an NPM package before adding it as a
  dependency.

```
npm view <package-name> version
```

- Use the package manager that matches the lockfile.

## Skills Discovery

When user asks "how do I do X", "find a skill for X", or wants to extend
capabilities, use the `find-skills` skill to search the open agent skills
ecosystem via `npx skills find [query]`.

Before following a pstack skill (`how`, `why`, `recall`, `blast-radius`,
`arena`, `technical-writing`, `unslop`) or `pr-review-canvas` / `show-me`, read
`~/.agents/pstack-adapter.md`. For "help me understand this PR", use
`pr-review-canvas`.
