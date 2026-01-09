---
description: Create, refine, or execute implementation plans
---

Manage plans in `.agent/plans/`. Plans focus on approach and decisions, not code.

## Arguments

- `$1` - Plan name OR "execute" OR "list"

## Commands

### List plans: `/plan list`

```bash
ls -la .agent/plans/*.md 2>/dev/null || echo "No plans yet"
```

### Execute current plan: `/plan execute`

Jump to [Execute mode](#execute-mode).

### Refine mode: `/plan <name>`

#### Step 1: Load or create plan

```bash
mkdir -p .agent/plans
```

If `.agent/plans/$1-plan.md` exists:
- Read it
- Summarize: status, goal, completed tasks, open questions
- Ask: "What do you want to refine or discuss?"

If not exists, create with template:

```markdown
# $1 Plan

**Status:** draft
**Created:** <today>

## Goal

<!-- One sentence: what are we building/solving? -->

## Context

<!-- Why now? Constraints? Dependencies? -->

## Approach

<!-- High-level strategy, not code. How will we solve this? -->

## Key Decisions

<!-- Architecture choices, tradeoffs, alternatives considered -->

## Tasks

<!-- Ordered list of what to do. Focus on WHAT not HOW -->

- [ ] Task 1
- [ ] Task 2

## Open Questions

<!-- Unresolved issues to figure out -->

## Notes

<!-- Refinement session notes -->
```

Then start refinement.

#### Step 2: Refinement loop

Guide the plan to completion through conversation:

1. **Understand the goal** - Ask clarifying questions one at a time
2. **Explore approaches** - Propose 2-3 options with tradeoffs, recommend one
3. **Capture decisions** - Write key decisions to file as agreed
4. **Break into tasks** - When approach is clear, suggest task breakdown
5. **Surface questions** - Note open questions that need answers

**Rules:**
- One question at a time
- Write to file incrementally (user can see progress)
- Focus on APPROACH and DECISIONS, not implementation details
- No code snippets in plan - describe what, not how
- Tasks should be actionable but high-level ("Add auth middleware" not "Create file at src/middleware/auth.ts with function...")

**Exit when:**
- User says "looks good" / "done" / "let's execute"
- Natural end of conversation

Before finishing, update status to `ready` if plan has goal + approach + tasks.

---

### Execute mode

`/plan execute` runs tasks from the most recently modified plan in `.agent/plans/`.

#### Step 1: Find and validate plan

```bash
ls -t .agent/plans/*.md | head -1
```

Read the plan. Check:
- Status is `ready` or `executing`
- Has at least one incomplete task (`- [ ]`)

If status is `draft`, ask: "Plan is still draft. Mark as ready and execute?"

#### Step 2: Update status

If first execution, update status to `executing` in file.

#### Step 3: Execute tasks

For each incomplete task (lines matching `- [ ]`):

1. **Show task** - Brief display of what's being done
2. **Implement** - Invoke `@implementer` subagent with:

```
@implementer

TASK: <task description>

CONTEXT FROM PLAN:
- Goal: <goal from plan>
- Approach: <relevant approach details>

Implement this task and commit when done.
```

4. **Update plan** - Mark task complete:
   - Change `- [ ]` to `- [x]`
   - Add completion note if relevant

5. **Continue** - Move to next task immediately

#### Step 4: Completion

When all tasks done:
- Update status to `done`
- Summarize what was accomplished
- Offer: "Create PR?" (run /pr command)

## Plan Philosophy

Plans are thinking tools, not specifications:

- **Approach over implementation** - Describe strategy, not code
- **Decisions over details** - Capture why, not exact how
- **Tasks are goals** - "Add caching layer" not "Create Redis client in src/cache.ts"
- **Living document** - Update as understanding evolves

Good task: "Refactor auth to use JWT instead of sessions"
Bad task: "In src/auth/index.ts, replace line 45-60 with jwt.sign() call"
