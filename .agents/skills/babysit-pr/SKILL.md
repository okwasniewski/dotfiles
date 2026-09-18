---
name: babysit-pr
description: Monitor a pull request through review bots and CI until green. Use when the user asks to monitor, watch, or babysit a PR.
---

# Babysit PR

Watch a PR until review bots and required checks are green on the latest commit.
Fix what is real, dismiss what is not, stay quiet otherwise.

Repos we work in run AI review bots. Helpful, not always right. Treat every
finding as advisory.

## Resolve the PR

```bash
gh pr view --json number,url,headRefName,baseRefName,headRefOid,isDraft,mergeable
```

No argument means the PR for the current branch. Accept a number or URL
otherwise. Record `headRefOid` - only checks and comments newer than that push
matter.

## Monitor

- Claude Code: use the `Monitor` tool on `gh pr checks --watch` and on the
  comment fetch below. For long waits use `/loop` with self pacing instead of
  tight polling.
- OpenCode and other harnesses: poll every 2-5 min with the commands below. Back
  off when nothing changes.

```bash
gh pr checks --json name,state,bucket,link
gh api repos/{owner}/{repo}/pulls/<n>/comments --jq '.[] | select(.created_at > "<push-iso>") | {id,user:.user.login,path,line,body}'
gh api repos/{owner}/{repo}/pulls/<n>/reviews --jq '.[] | select(.submitted_at > "<push-iso>") | {id,user:.user.login,state,body}'
gh api repos/{owner}/{repo}/issues/<n>/comments --jq '.[] | select(.created_at > "<push-iso>") | {id,user:.user.login,body}'
```

## Handle findings

1. Read the source the bot points at before touching anything. Verify the claim,
   use `code-review` skill for anything non-trivial.
2. Real finding or real CI failure: fix with the smallest correct change. Commit
   via `conventional-commit` skill. Push.
3. Infra flake (runner lost, network, timeout unrelated to diff): rerun with
   `gh run rerun <id> --failed`. Do not touch code.
4. False positive or not worth it: reply with the reason, then resolve the
   thread.

Reply to a review comment:

```bash
gh api repos/{owner}/{repo}/pulls/<n>/comments/<comment-id>/replies -f body="$(cat reply.md)"
```

Resolve the thread (thread id from `reviewThreads` in GraphQL):

```bash
gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -F id=<thread-id>
```

Format every comment left on Oskar's behalf as:

```md
_[MODEL-SLUG] responding on behalf of Oskar_

[actual reply]
```

Single italic line for attribution. Never underline it with `---` or `===` -
Markdown turns that into a heading. Replies concise, plain hyphens only, no em
or en dashes.

## Keep it mergeable

```bash
GIT_EDITOR=true git fetch origin
GIT_EDITOR=true git rebase origin/<base>
git push --force-with-lease
```

Rebase when `mergeable` flips to `CONFLICTING` or base moved under a file this
PR touches. After a push, reset the watermark to the new `headRefOid`.

If an overlapping PR on `main` makes this one obsolete: stop, report to the
user, ask before closing unless closure was explicitly authorized.

## Scope

Fix real shortcomings inside the PR's original goal. Refuse bot-driven scope
creep: broad refactors, style rewrites, speculative edge cases, unrelated files.
Say so in the reply.

## Stop

- Bots and required checks green on latest commit: report ready, stop.
- Merge only if the user explicitly asked. Otherwise never merge.
- Nothing changed since last check: stay silent. No filler comments, no status
  spam.
