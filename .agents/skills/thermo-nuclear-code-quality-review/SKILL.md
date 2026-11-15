---
name: thermo-nuclear-code-quality-review
description: Run an extremely strict maintainability review for abstraction quality, giant files, and spaghetti-condition growth. Use for a thermo-nuclear code quality review, thermonuclear review, deep code quality audit, or especially harsh maintainability review.
---

# Thermo-nuclear code quality review

A strict review of the current branch's changes (default base `main`) for
structure and maintainability, not correctness. The goal is a cleaner design
with the same behavior. If restructuring nearby code gets there, propose it.

## What to look for

1. **A simpler reframing.** Look for the "code judo" move: a reorganization
   that uses the existing architecture better so whole branches, helpers,
   modes, or layers disappear. Deleting complexity beats rearranging it.
2. **File size.** A diff that pushes a file from under 1000 lines to over 1000
   is a blocker unless the file stays clearly organized. Ask what to split
   out first.
3. **Spaghetti growth.** New ad-hoc conditionals, one-off booleans, nullable
   modes, or feature checks scattered through shared flows. Treat them as a
   design problem and point to where a dedicated abstraction, state machine,
   or module should own the logic.
4. **Direct over magic.** Flag brittle or magical behavior, generic mechanisms
   that hide simple data shapes, and thin wrappers that add indirection.
5. **Type boundaries.** Unneeded optionality, `unknown`, `any`, casts, or
   loose object shapes that hide the real invariant. Silent fallbacks that
   paper over an unclear contract.
6. **Canonical layer.** Feature logic leaking into shared code, details
   leaking through APIs, bespoke helpers where the codebase already has one.
7. **Orchestration.** Independent work run sequentially for no reason, or
   related updates that can leave state half-applied.

## Remedies to prefer

- Delete a layer of indirection rather than polishing it.
- Reshape the state model so conditionals disappear instead of moving.
- Move ownership so the feature extends an existing abstraction.
- Replace condition chains with a typed model or explicit dispatcher.
- Split large files into focused modules, separate orchestration from logic.
- Reuse the canonical helper, collapse duplicate branches.

A rename or a cleaner copy of the same messy idea is not enough when a simpler
idea is visible.

## Tone

Direct and serious, never rude. Say plainly when a change makes the codebase
messier or misses a big simplification. Examples:

- `this pushes the file past 1k lines. can we decompose this first?`
- `this adds another special-case branch into an already busy flow. can we move this behind its own abstraction?`
- `why does this need a cast / optional here? can we make the boundary explicit instead?`
- `this moves complexity around but doesn't delete it. is there a simpler model?`

## Output

Order findings by:

1. Structural regressions
2. Missed simplifications
3. Branching and spaghetti growth
4. Boundary, abstraction, and type-contract problems
5. File size and decomposition
6. Legibility

Prefer a few high-conviction comments over a long list of nits.

## Approval bar

Correct behavior is not enough to approve. Treat these as blockers unless the
author justifies them:

- A visible simplification that would delete incidental complexity was skipped.
- A file crossed 1000 lines.
- Ad-hoc branching tangled an existing flow, or feature checks spread across
  shared code.
- An unneeded wrapper, abstraction, or cast-heavy contract.
- A duplicated helper or logic in the wrong layer.

Otherwise, leave specific, actionable feedback toward a cleaner decomposition.
