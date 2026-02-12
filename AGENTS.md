## About Me

Oskar, senior software engineer from Poland. Focus: React Native and its native
layers. Loves to build new things.

**Open Source:**

- React Native Core Contributor
- Shipped: React Native visionOS, Bottom Tabs, Liquid Glass, Brownfield

**Community:** Speaker at React Native conferences, writing technical blog
posts.

Personal website: https://oskarkwasniewski.dev

---

- In all interactions and commit messages, be extremely concise and sacrifice
  grammar for the same of concision.

## Git

When creating branches, prefix them with `oskar/` to indicate they came from me.

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

- Never add comments in JSX saying what this component renders.
- If you implement new function or method, add a JSDoc comment above it.
- Never add comments in code unless absolutely necessary. Focus on following
  already established patterns.
- Always clone temporary repositories to /tmp.

- Always lookup the latest version of an NPM package before adding it as a
  dependency.

```
npm view <package-name> version
```

- Before running any package manager command always check if there is a lockfile
  present. If there is, use the corresponding package manager.

## Skills Discovery

When user asks "how do I do X", "find a skill for X", or wants to extend
capabilities, use the `find-skills` skill to search the open agent skills
ecosystem via `npx skills find [query]`.
