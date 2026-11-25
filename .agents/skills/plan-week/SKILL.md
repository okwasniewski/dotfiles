---
name: plan-week
description: Plan or replan the week across Things, both calendars (Fastmail personal, Superhuman work), and Linear. Use for /plan-week or when the user asks to plan, replan, or clean up their week or day schedule.
---

# Plan week

Distribute Things tasks across the coming days using real calendar constraints. Apply the changes, then report the final layout as a table.

## Gather (all before deciding)

1. Things, via the `things` MCP server (`things_mcp` in Executor): `things_overview` with `lookahead_days` covering the horizon, plus `things_find_tasks` with `schedule` `today`, `upcoming`, `anytime` and `inbox`. Group by `scheduledDate`. Items with no scheduled date and repeating tasks (`isRecurring: true`, such as Owsianka, Sport, Weekly Review) are off limits.
2. Personal calendar: Fastmail MCP `search_events({ after, before })` for the horizon (today through Sunday next week).
3. Work calendar: Superhuman MCP `query_email_and_calendar` / `get_availability` for the same horizon.
4. Linear: issues assigned to Oskar in started/unstarted states, for context in notes only.

## Rules

- Calendar wins. A day with travel, a gala, a conference, or an all-day block gets no deep work. `[No Work Time]` days (usually Sundays) get no work tasks at all.
- Per weekday budget: 1-2 deep-work tasks plus about 3 quick ones. Do not stack more.
- Overdue tasks and client-facing items (a client is waiting) go to the earliest workday.
- Phone-call tasks (doctors, offices, insurance) go Mon-Fri, morning slots.
- Personal errands prefer Saturday; nothing on `[No Work Time]` days.
- Respect existing deadlines.
- Tasks that pair with an event (like "Przełożyć ortodontę" before the wizyta) must land before that event.
- Backlog with no week slot goes to Someday, never deleted.
- Do not touch tasks completed or in progress, and do not reorder within a day.

## Mechanics

- Reschedule: `things_edit_item` with `uuid` and `schedule: "YYYY-MM-DD"` (or `"today"`).
- Move to Someday: `things_edit_item` with `schedule: "someday"`.
- Always act by `uuid`, never by name: duplicate names exist (Fryzjer).
- Verify after applying: `things_find_tasks` with `schedule: "upcoming"`, grouped by `scheduledDate`.

## Report

Table: day | tasks (deep work first). Then one line each for: what moved to Someday, calendar conflicts found, deadlines at risk (deadline within the horizon but task scheduled late). Mention nothing else.
