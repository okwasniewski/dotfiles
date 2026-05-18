---
description: OpenCode review loop until actionable findings are resolved
---

# Review Loop

Run an OpenCode-native code review closeout. Use the `code-review` skill to review the current local work, branch, or PR branch, then fix accepted findings and repeat until no actionable findings remain.

Use when:

- User asks for review, autoreview, or second-model review
- After non-trivial code edits, before final/commit/ship
- Reviewing a local branch or PR branch after fixes

## Contract

- Treat review output as advisory. Never blindly apply it.
- Verify every finding by reading the real code path and adjacent files.
- Read dependency docs/source/types when the finding depends on external behavior.
- Reject unrealistic edge cases, speculative risks, broad rewrites, and fixes that over-complicate the codebase.
- Prefer small fixes at the right ownership boundary. No refactor unless it clearly improves the bug class.
- Keep going until review returns no accepted/actionable findings.
- If a review-triggered fix changes code, rerun focused tests and rerun review.
- Stop as soon as the review pass returns no accepted/actionable findings.
- Do not run an extra review just to get nicer closeout wording, second opinion, or redundant confirmation.
- If rejecting a finding as intentional/not worth fixing, add a brief inline code comment only when it explains a real invariant or ownership decision future reviewers should know.
- Do not push just to review. Push only when the user requested push/ship/PR update.

## Pick Scope

Dirty local work:

```bash
GIT_EDITOR=true git status --short
GIT_EDITOR=true git diff --stat
GIT_EDITOR=true git diff
GIT_EDITOR=true git diff --cached
```

Use this when there are unstaged, staged, or untracked changes in the current checkout.

Branch/PR work:

```bash
GIT_EDITOR=true git fetch origin
base=$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null || git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || printf main)
GIT_EDITOR=true git diff "origin/$base...HEAD" --stat
GIT_EDITOR=true git diff "origin/$base...HEAD"
```

Use the open PR's actual base when available. Otherwise use the remote default branch.

Committed single change:

```bash
GIT_EDITOR=true git show --stat HEAD
GIT_EDITOR=true git show HEAD
```

Use commit review for already-committed work, especially a clean branch where local dirty diff is empty.

## Review Pass

Use the `code-review` skill. Default to a subagent filter when available. Ask it to review the selected scope and return only:

- Actionable findings it accepts
- Findings it rejects, with one-line reason
- Exact files/tests to rerun

Focus findings on bugs, regressions, security, performance, maintainability, and missing tests. Ignore broad style rewrites unless they hide a real issue.

## Fix Loop

For each accepted finding:

- Read the relevant files and adjacent code before editing.
- Apply the smallest correct fix.
- Run focused tests/proof for the changed path.
- Rerun the review pass over the updated scope.
- Repeat until there are no accepted/actionable findings.

If tests fail, fix the failure before rerunning review. If a finding is rejected, record the reason in the final report.

## Parallel Closeout

Format first if formatting can change line locations. Then tests and review can run in parallel when independent.

Tradeoff: tests may force code changes that stale the review. If tests or review lead to code edits, rerun affected tests and rerun review until no accepted/actionable findings remain. Once that rerun is clean, stop.

## Final Report

Include:

- Review scope used
- Tests/proof run
- Findings accepted/rejected, briefly why
- Clean review result from the final review pass, or why a remaining finding was consciously rejected

Do not run another review solely to improve final report wording. If the final review pass produced no accepted/actionable findings, report that exact pass as clean.
