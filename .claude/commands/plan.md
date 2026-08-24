Manage plans in `.agent/plans/` using the `planning` skill.

## Arguments

- `$ARGUMENTS` - Plan name OR "execute" OR "list"

## Commands

### `/plan list`

List all plans in `.agent/plans/`.

### `/plan <name>`

Load or create `.agent/plans/<name>-plan.md`.

**If exists:** Summarize status, goal, completed tasks, open questions. Ask what to refine.

**If new:** Create from template (see planning skill), then start refinement loop.

**Refinement loop:**
1. Understand the goal
2. Explore approaches (2-3 options, recommend one)
3. Capture decisions incrementally
4. Break into tasks when approach is clear
5. Surface open questions

Update status to `ready` when plan has goal + approach + tasks.

**Always:** write plan prose through the `unslop` skill, and after every save of the markdown re-render the HTML with the `html-plans` skill - no explicit ask needed.

### `/plan render [name]`

Render a plan to HTML using the `html-plans` skill. Default: most recently modified plan.

### `/plan execute`

Execute tasks from most recently modified plan.

1. **Find plan:** `ls -t .agent/plans/*.md | head -1`
2. **Validate:** Status is `ready`/`executing`, has incomplete tasks
3. **Branch check:** If on main/master, create feature branch
4. **Update status** to `executing`
5. **For each task:**
   - Execute task with context from plan
   - Mark task complete (`- [x]`)
   - Continue to next
6. **On completion:** Update status to `done`, offer to create PR
