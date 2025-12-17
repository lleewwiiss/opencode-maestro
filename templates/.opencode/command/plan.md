---
description: Create implementation plan from research - detailed, actionable, reviewable (always interactive)
---
<context>
You are creating an implementation plan for a bead. This is a HIGH-LEVERAGE phase - a bad plan leads to hundreds of bad lines of code.

This command is ALWAYS INTERACTIVE. You must engage in dialogue with the human:
1. Present approach options and get confirmation
2. Walk through phases with depth based on risk/complexity (your judgment)
3. Iterate on feedback until approved
4. Only create child beads AFTER plan is finalized

The back-and-forth conversation IS the review. Do not just generate plan.md and hand off.

Save progress to plan.md incrementally as context approaches limit.
</context>

<investigate_before_planning>
Read research.md and key source files COMPLETELY before proposing design options. Do not speculate about code structure or patterns you have not verified. If research references specific files, read them to understand current implementation.

This ensures plans are grounded in actual codebase state, not assumptions about how code might work.
</investigate_before_planning>

<use_parallel_tool_calls>
When gathering context, read multiple files in parallel. Spawn @codebase-analyzer and @codebase-pattern-finder in parallel for independent analyses. Wait for results before synthesizing into design options.

Example: Read research.md, spec.md, and 3 key implementation files in one parallel batch.
</use_parallel_tool_calls>

<avoid_overengineering>
Plans should specify the minimum changes needed to solve the problem. Do not plan for hypothetical future requirements. Do not add abstractions or flexibility that wasn't requested.

Bad: "Add a plugin system for future extensibility"
Good: "Add the specific handler needed for this feature"
</avoid_overengineering>

<epistemic_hygiene>
"I believe X" ≠ "I verified X". When uncertain about an approach, say so explicitly. Flag areas where you're not 100% confident.

This prevents overconfident plans that fail during implementation.
</epistemic_hygiene>

<chestertons_fence>
Before proposing to change existing code patterns, explain WHY they currently exist. If you can't explain it, don't propose changing it without flagging the uncertainty.

This prevents breaking working patterns for unknown reasons.
</chestertons_fence>

<blunt_assessment>
Push back if the human's feedback seems incorrect or would lead to a worse design. You are not a yes-machine. Provide evidence for your position.

Your job is a good plan, not agreement with bad ideas.
</blunt_assessment>

<autonomy_check>
Before significant design decisions: Am I the right entity to decide this? If uncertain AND consequential, ask the human first. Cheap to ask, expensive to guess wrong.

Examples of "ask first": Database schema changes, API contract changes, authentication approaches.
</autonomy_check>

<goal>
Produce a thorough plan.md through interactive refinement with the human. The conversation IS the review - present approach, walk through phases, iterate until approved, then create child beads.
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

<phase name="validate_bead_level">
## Phase 0: Validate Bead Level

Check if this is a child bead (ID contains `.`):

```bash
echo "$1" | grep -q '\.'
```

**If child bead detected:**

Extract parent ID (remove everything after first `.`):
```bash
PARENT_ID=$(echo "$1" | sed 's/\..*//')
```

Display and STOP:
```
===================================================================
  STOP: Cannot plan a child bead
===================================================================

  $1 is a child bead (subtask of an epic).
  Planning should be done at the EPIC level.

  Parent bead: $PARENT_ID

  To plan the epic:
    /plan $PARENT_ID

  To view existing plan:
    cat .beads/artifacts/$PARENT_ID/plan.md

  To implement this child's phase:
    /implement $1

===================================================================
```

**STOP** - Do not proceed with planning on a child bead.

**If NOT a child bead:** Proceed to Phase 1.
</phase>

<phase name="gather_context">
## Phase 1: Gather Context

Read completely before planning:

1. **Research**: `.beads/artifacts/$1/research.md`
2. **Spec** (if exists): `.beads/artifacts/$1/spec.md`
3. **Bead metadata**: `bd show $1 --json`
4. **Key files** identified in research (read them fully)

If research identified areas needing deeper understanding, spawn parallel analyzers:
- @codebase-analyzer: Understand [specific component] implementation details (uses LSP for navigation)
- @codebase-pattern-finder: Find examples of [pattern] we should follow (uses AST-grep for structural search)
- @librarian: Look up official docs or open source examples if needed

WAIT for all to complete before proceeding.

For complex architectural decisions, consider consulting @oracle for design review and tradeoff analysis.
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

Risk Assessment: [Your judgment on overall risk level]
[If high-risk: "This touches [critical area] - I'll walk through each phase carefully"]
[If low-risk: "This is fairly contained - I can move faster through the details"]

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

<phase name="walk_through_phases">
## Phase 5: Walk Through Phases (Interactive)

After writing plan.md, walk through each phase with the human. Use judgment to determine depth:

<determine_engagement_depth>
**High engagement (spend more time, detailed walkthrough):**
- Changes to auth, payments, data models
- Unfamiliar patterns in codebase
- Chesterton's Fence situations (changing existing behavior)
- Human seems uncertain

**Lower engagement (can summarize and move faster):**
- Adding tests
- UI tweaks
- Following well-established patterns
- Human clearly knows the domain
</determine_engagement_depth>

<high_risk_phase_walkthrough>
**For high-risk/complex phases:**

```
Phase [N]: [Phase Name]
───────────────────────

This phase touches [critical area]. Let me walk through it carefully.

**What we're changing:**
[Detailed breakdown of changes]

**Specifically, I'll be changing:**
- `[file:line]` which currently does [X]
- The new behavior will [Y]

**Chesterton's Fence check:**
[If applicable: "I believe [existing pattern] exists because [reason]. 
If I'm wrong, [consequence]. Can you confirm?"]

**Risk:** [What could go wrong]

Any concerns with this phase?
```
</high_risk_phase_walkthrough>

<low_risk_phase_walkthrough>
**For low-risk/simple phases:**

```
Phases [N-M] are straightforward - [brief summary of what they do].
I'll move faster through these unless you want details on any specific one.

Quick summary:
- Phase N: [one-liner]
- Phase M: [one-liner]

Any of these need more detail?
```
</low_risk_phase_walkthrough>

<iterate_on_feedback>
Based on human response:

**If feedback on a phase:**
- Spawn subagent to revise that section
- Cascade changes to dependent phases if needed
- Update plan.md
- Return to present revised phase

**If questions:**
- Discuss thoroughly
- Revise if needed

**If human feedback seems incorrect:**
- Push back with evidence: "I'd caution against [X] because [file:line shows Y]..."
- Provide rationale for the current plan
- But ultimately defer to human if they insist (note the override in plan.md)
</iterate_on_feedback>
</phase>

<phase name="finalize_and_create_beads">
## Phase 6: Finalize and Create Child Beads

Only after human approves the complete plan:

```
Plan Approved: $1
━━━━━━━━━━━━━━━━

Summary of changes during review:
• [Change 1 made based on feedback]
• [Change 2 made based on feedback]
• (or "No changes - plan approved as generated")

[If any overrides noted:]
Human Overrides (noted in plan):
• [Decision where human overrode agent recommendation]
```

<create_child_beads>
**For plans with 2+ phases**, create child beads with RICH descriptions:

```
Creating child beads with detailed descriptions...

$1.1 - [Phase 1 name]
$1.2 - [Phase 2 name]
$1.3 - [Phase 3 name]
```

For each child bead, include a description that enables standalone execution:

```bash
bd create "[Phase 1 name]" --type task --parent $1 --priority [same as parent] --description "$(cat <<'EOF'
## Context
[1-2 sentences: What this phase accomplishes in the larger feature]

## Key Changes
- `[file1.ts]` - [what changes]
- `[file2.ts]` - [what changes]

## Patterns to Follow
- See `[similar_file:line]` for [pattern]
- Use [approach] from research

## Success Criteria
- [ ] [Specific criterion]
- [ ] Tests pass: [specific tests]

## References
- Full plan: `.beads/artifacts/$1/plan.md`
- Research: `.beads/artifacts/$1/research.md`
EOF
)"
```

The description should contain enough context that an agent could work from the bead itself, with plan.md as backup reference.
</create_child_beads>

Update plan.md with child bead mapping:

```markdown
## Child Beads
| Phase | Bead ID | Status |
|-------|---------|--------|
| Phase 1: [name] | $1.1 | open |
| Phase 2: [name] | $1.2 | open |
| Phase 3: [name] | $1.3 | open |
```

<final_handoff>
```
Plan Finalized: $1
━━━━━━━━━━━━━━━━━━

Phases: [N]
Child Beads: [list if created]
Estimated Effort: [time]

Artifact: .beads/artifacts/$1/plan.md

Ready for: /implement $1.1  (or /implement $1 if no children)
```
</final_handoff>
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
- ALWAYS walk through phases interactively - never just write plan.md and hand off
- Push back if human feedback would lead to worse design
- Create child beads ONLY after plan is finalized and approved
- Child bead descriptions must be rich enough for standalone execution
</constraints>
