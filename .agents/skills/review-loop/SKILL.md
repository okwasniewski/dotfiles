---
name: review-loop
description: Review the current work with a panel of reviewers on different models (T3 Code delegates), verify and fix accepted findings, and repeat until a round comes back clean. Use for review loop, autoreview, second-model or cross-model review, and before commit or ship after non-trivial edits.
---

# Review Loop

You own the code and the verdict. Reviewers on other models find candidates;
you verify each one against the real code, fix what holds up, and run another
round until nothing actionable is left.

## 1. Pick scope

Dirty work: `git status --short`, `git diff`, `git diff --cached`.

Branch or PR:

```bash
GIT_EDITOR=true git fetch origin
base=$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null \
  || git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' \
  || echo main)
git diff "origin/$base...HEAD" --stat
```

Single commit: `git show HEAD`.

Commit dirty work first only if the user asked for commits. Otherwise review
the working tree as is; reviewers run in the same checkout.

## 2. Pick the panel

In T3 Code (`delegate_task` is available), call `orchestrator_capabilities`
once and pick two reviewers on models other than your own, preferring
different providers:

1. Codex `gpt-6.1-sol`, `reasoningEffort: high`
2. Claude `claude-fable-5-2`, `effort: high`
3. Claude `claude-opus-5-5`, `effort: high` (when you are Fable)

Take the first two that are available and not your own model. If fewer than
two are available, run with one and say so in the report. The user can name
other models or a bigger panel; use exactly those.

Outside T3: in Claude Code use the `Agent` tool with a `model` override that
differs from yours; elsewhere use your native subagent. One reviewer is fine
there.

## 3. Run a round

Start every reviewer in the same turn with a new `delegate_task`:
`role: "review"`, default `isolation` (shared checkout), `mode: "async"`,
title `review r<N>: <model>`. Do not poll; wait for the completion wake-ups,
then read each result with `task_status`.

Each reviewer gets the same brief, written fresh each round. Give it the code
to look at, not your opinion of it:

```
Review <scope> in <absolute repo path>. Read-only: do not edit files,
commit, push, or start subagents.
Diff: <exact git command from step 1>
Context: <one or two lines on what the change is for>
If a `code-review` skill is available, follow it. Focus on bugs,
regressions, security, data loss, performance and missing tests. Skip
style, naming and anything a linter or hook enforces.
Already rejected, do not resend unless you have new evidence:
<list from earlier rounds, or "none">
Return a list. Per finding: file:line, severity (high/medium/low), the
defect in one sentence, a concrete failing input or scenario, the fix.
Say "no findings" if there are none.
```

## 4. Triage

Merge the reports and collapse duplicates. For each finding:

- Read the code path and its callers. Check dependency docs or source when
  the claim depends on external behavior.
- Accept it only if you can state the failing scenario yourself. Two models
  agreeing raises priority, not certainty.
- Reject speculative edge cases, broad rewrites, and fixes that cost more
  complexity than the bug. Record a one-line reason.

## 5. Fix

Smallest correct fix at the right ownership boundary. Run focused tests or
other proof for each touched path. Add a code comment for a rejection only
when it documents a real invariant future reviewers will trip on.

## 6. Repeat or stop

- Round had accepted findings and you changed code: run another round with
  fresh delegates and the updated rejected list.
- Round had no accepted findings: stop. Do not run a confirmation round.
- Stop after 3 rounds regardless and report what is still open.

Cancel any reviewer still running when you stop (`task_cancel`). Do not push
unless the user asked for push, ship or a PR update.

## Report

- Scope and panel (models per round)
- Tests or proof run
- Accepted findings and fixes; rejected findings with the reason
- Which round came back clean, or what remains after the cap
