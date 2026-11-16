---
name: ready-prs
description: List open PRs from the team and the community that look ready to merge (mergeable, CI green, no requested changes, no unresolved threads, review bot clean). Read-only. Use when the user asks which PRs are ready, mergeable, good to merge, worth reviewing next, or for a PR triage of a repo.
---

# Ready PRs

Surface the open PRs that only need a human look and a merge. Never merge,
approve, comment, label or otherwise change a PR.

## Run

```bash
node ~/.agents/skills/ready-prs/scripts/ready-prs.mjs [owner/repo ...]
```

- No repo given: it uses the current directory's repo. Outside a repo, use
  `e2e-inc/e2e`.
- Pass several repos to scan them in one go. Add `--json` for raw data.
- It takes about 30s on a repo with ~50 open PRs. Run it once; don't re-query
  PRs by hand.

## What counts as ready

A non-draft PR is ready when all of these hold:

- GitHub merge state is `CLEAN`, `UNSTABLE` or `HAS_HOOKS`, or `BLOCKED` only
  because it waits for a required approval.
- CI is not failing or running.
- No review requests changes and no review thread is unresolved.
- The review bot is clean: a Codex 👍 on the PR, or a latest cubic summary of
  "No issues found", "0 issues found" or "All reported issues were addressed".
  This is only required in repos where a bot reviews PRs at all.

Groups come from GitHub's author association: owner, member or collaborator is
team; everyone else is community; bot accounts (release PRs) are listed apart.
PRs that miss exactly one check are listed under "One step away" with the
reason.

## Report

Show the script's output as is, then add at most three short notes:

- Suggest an order: small and long-waiting PRs first, team before community
  only when the user asked about the team.
- Flag `cubic clean (older commit)`: the bot passed an earlier commit and the
  newest changes have no bot verdict yet.
- Point out "One step away" items the user can unblock themselves, such as
  `no bot review yet` on a fresh PR or merge conflicts on a team PR.

To go deeper on one PR, use `pr-review-canvas`.
