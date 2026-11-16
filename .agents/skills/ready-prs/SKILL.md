---
name: ready-prs
description: List open PRs from the team and the community that are ready for a human to merge - labeled "Ready for Human Review" by the automated first pass, mergeable, CI green, no requested changes or open threads. Read-only. Use when the user asks which PRs are ready, mergeable, good to merge, worth reviewing next, or for their merge queue.
---

# Ready PRs

The second pass of a two-pass PR flow. A scheduled agent does the first pass: it
reviews every PR, posts an automated review, closes spam and adds the
`Ready for Human Review` label once a PR is good. This skill lists what is
waiting on the human: PRs a maintainer can read and merge now, plus near-misses
that each need one nudge. Never merge, approve, comment, label or otherwise
change a PR.

## Run

```bash
node ~/.agents/skills/ready-prs/scripts/ready-prs.mjs [owner/repo ...] [--label "<name>" | --label none] [--json]
```

- No repo given: it uses the current directory's repo. Outside a repo, use
  `e2e-inc/e2e`.
- The ready label is detected per repo (`Ready for Human Review` or
  `Ready for maintainer review`). `--label` overrides it; `--label none` turns
  the gate off for repos without a first pass.
- About 20s for ~50 open PRs. Run it once; don't re-query PRs by hand.

## What counts as ready

A non-draft PR is ready when all of these hold:

- It has the ready label, and no commit landed after the label was added.
- Merge state is `CLEAN`, `UNSTABLE` or `HAS_HOOKS`, or `BLOCKED` only because
  a required approval is missing.
- CI ran and is neither failing nor running. No CI at all is not ready.
- No reviewer's latest review requests changes. This reads each reviewer's own
  latest review, because GitHub's review decision is empty on repos with no
  required approvals.
- No review thread is unresolved.
- The review bot did not report open issues. Without a ready label, a clean bot
  verdict (Codex 👍, or a cubic "No issues found") is also required.

Groups come from the author's association: owner, member or collaborator is
team; everyone else is community; bot accounts (release PRs) are listed apart.
Ready PRs are sorted smallest first, then oldest first. PRs that miss exactly
one check are listed under "One step away" with the reason.

## Report

Show the script's output as is, then add at most three short notes:

- What to merge first: small, long-waiting PRs, and anything `approved by` a
  teammate.
- Real risks from the notes column: `same files as` (merge one, then recheck the
  other), `bot passed an older commit`, `idle Nd`.
- Near-misses the user can unblock: `new commits after "<label>"` waits for the
  next first pass; merge conflicts on a team PR can be fixed directly.

To read one PR, open its agent review link, or use `pr-review-canvas` for a
full walkthrough.
