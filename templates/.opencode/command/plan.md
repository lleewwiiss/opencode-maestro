---
description: Create implementation plan from research - detailed, actionable, reviewable
subtask: true
---
<context>
You are creating an implementation plan for a bead. This is a HIGH-LEVERAGE phase - a bad plan leads to hundreds of bad lines of code.

The human will review this plan before implementation. Make it detailed enough to execute but clear enough to review.

Save progress to plan.md incrementally as context approaches limit.
</context>

<claude4_guidance>
<investigate_before_planning>
Read research.md and key source files COMPLETELY before proposing design options. Do not speculate about code structure or patterns you have not verified. If research references specific files, read them to understand current implementation.
</investigate_before_planning>

<use_parallel_tool_calls>
When gathering context, read multiple files in parallel. Spawn @codebase-analyzer and @codebase-pattern-finder in parallel for independent analyses. Wait for results before synthesizing into design options.
</use_parallel_tool_calls>

<avoid_overengineering>
Plans should specify the minimum changes needed to solve the problem. Do not plan for hypothetical future requirements. Do not add abstractions or flexibility that wasn't requested.
</avoid_overengineering>
</claude4_guidance>

<goal>
Produce a thorough plan.md that an implementer can follow step-by-step, with clear success criteria and no open questions.
</goal>

<principles>
- **ETC (Easy To Change)**: Plan designs that are flexible. Ask "will this be easy to modify later?"
- **Tracer Bullets**: Plan for working end-to-end first, then iterate. Get feedback early rather than building everything then integrating.
- **Orthogonality**: Design components to be independent. Eliminate effects between unrelated things.
- **Design it twice**: Consider at least two approaches before committing. The first idea is rarely the best.
- **Strategic vs tactical**: Invest in good design now. Tactical "just make it work" accumulates complexity debt.
- **Pull complexity downward**: It's better for implementation to be complex than for interfaces to be complex.
- **Deep modules**: Simple interfaces hiding complex implementation. Shallow modules (complex interface, simple implementation) add complexity.
- **Write less code**: The best code is no code. Question whether each component is necessary.
- **High-leverage review point**: A bad plan leads to hundreds of bad lines of code. Invest time here.
</principles>

<prerequisites>
- `research.md` must exist and have been reviewed by human
- Bead must be in appropriate status
</prerequisites>

<bead_id>$1</bead_id>

<workflow>

<phase name="gather_context">
## Phase 1: Gather Context

Read completely before planning:

1. **Research**: `.beads/artifacts/$1/research.md`
2. **Spec** (if exists): `.beads/artifacts/$1/spec.md`
3. **Bead metadata**: `bd show $1 --json`
4. **Key files** identified in research (read them fully)

If research identified areas needing deeper understanding, spawn parallel analyzers:
- @codebase-analyzer: Understand [specific component] implementation details
- @codebase-pattern-finder: Find examples of [pattern] we should follow

WAIT for all to complete before proceeding.
</phase>

<phase name="design_options">
## Phase 2: Present Design Options

Before writing the full plan, present options to the human:

```
Based on research, here's my understanding:

Current State
─────────────
[Key discovery about existing code with file:line]

Design Options
──────────────
1. [Option A]: [approach]
   Pros: [benefits]
   Cons: [drawbacks]
   Effort: [estimate]

2. [Option B]: [approach]
   Pros: [benefits]
   Cons: [drawbacks]
   Effort: [estimate]

Recommendation: Option [X] because [reason]

Open Questions
──────────────
- [Any decision that needs human input]

Which approach? (1/2/other)
```

Do NOT proceed until human confirms approach.
</phase>

<phase name="structure">
## Phase 3: Plan Structure

After approach is confirmed, propose the plan structure:

```
Proposed Plan Structure
───────────────────────
## Phases:
1. [Phase name] - [what it accomplishes]
2. [Phase name] - [what it accomplishes]
3. [Phase name] - [what it accomplishes]

Does this phasing make sense?
```

Get approval before writing detailed plan.
</phase>

<phase name="write_plan">
## Phase 4: Write Detailed Plan

Write to `.beads/artifacts/$1/plan.md`:

```markdown
---
date: [ISO timestamp]
bead: $1
approach: [chosen approach]
estimated_effort: [time estimate]
---

# [Feature/Task Name] Implementation Plan

## Overview
[1-2 sentences: what we're building and why]

## Current State
[What exists now, key constraints from research]

### Key Discoveries
- [Finding with file:line reference]
- [Pattern to follow]
- [Constraint to respect]

## Desired End State
[Specification of what "done" looks like]

## Implementation Approach
[High-level strategy and reasoning for chosen approach]

## What We're NOT Doing
[Explicit out-of-scope items - prevents scope creep]

---

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes]

### Changes Required

#### 1. [Component/File]
**File**: `path/to/file.ts`
**Changes**:
- [ ] [Specific change 1]
- [ ] [Specific change 2]

```typescript
// Code snippet if helpful for clarity
```

### Success Criteria

#### Automated Verification
- [ ] Build passes: `npm run build`
- [ ] Tests pass: `npm test`
- [ ] Type check: `npm run typecheck`

#### Manual Verification
- [ ] [Specific manual test step]
- [ ] [Edge case to verify]

---

## Phase 2: [Descriptive Name]
[Same structure...]

---

## Testing Strategy

### New Tests to Write
- [ ] `path/to/test.ts` - [what it verifies]
- [ ] `path/to/test.ts` - [what it verifies]

### Existing Tests to Update
- [ ] `path/to/existing.test.ts` - [what changes]

### Test Coverage Requirements
- [ ] All new public functions have unit tests
- [ ] Happy path tested
- [ ] Edge cases documented in spec are tested
- [ ] Error paths are tested

## Build & Test Commands
```bash
npm run build
npm test
npm run lint
```

## References
- Research: `.beads/artifacts/$1/research.md`
- Similar implementation: `[file:line]`
```
</phase>

<phase name="child_beads">
## Phase 5: Create Child Beads (Optional)

Check bead type:
```bash
bd show $1 --json
```

**For Epics or plans with 3+ phases**: Offer to create child beads:

```
Plan has [N] phases. Create child beads for atomic tracking?

Child beads would be:
  $1.1 - Phase 1: [name]
  $1.2 - Phase 2: [name]
  $1.3 - Phase 3: [name]

Create child beads? (yes / no)
```

If user approves:
```bash
bd create "[Phase 1 name]" --type task --parent $1 --priority [same as parent]
bd create "[Phase 2 name]" --type task --parent $1 --priority [same as parent]
bd create "[Phase 3 name]" --type task --parent $1 --priority [same as parent]
```

Update plan.md with child bead mapping.
</phase>

<phase name="review_handoff">
## Phase 6: Review and Handoff

Present for review:

```
Plan Created: $1
━━━━━━━━━━━━━━━━

Summary: [1-2 sentence summary]

Phases:
1. [Phase 1 name]
2. [Phase 2 name]
3. [Phase 3 name]

Estimated Effort: [time]

Artifact: .beads/artifacts/$1/plan.md

Please review. When approved:
  /implement $1
```
</phase>

</workflow>

<constraints>
- Read research.md COMPLETELY before planning
- Get human approval on approach before writing detailed plan
- No open questions in final plan - resolve everything first
- Include both automated AND manual success criteria
- Include explicit "What We're NOT Doing" section
- Every phase must have testable success criteria
- Testing Strategy section must specify new tests to write
</constraints>
