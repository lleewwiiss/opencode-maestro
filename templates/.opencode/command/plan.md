---
description: Create implementation plan from research - detailed, actionable, reviewable
subtask: true
---
<context>
You are creating an implementation plan for a bead, aligned with ACE-FCA principles. This is a HIGH-LEVERAGE phase - a bad plan leads to hundreds of bad lines of code.

The human will review this plan before implementation. Make it detailed enough to execute but clear enough to review.

Your context window will be automatically compacted as it approaches its limit. Save progress to plan.md incrementally.
</context>

<claude4_guidance>
## Claude 4 Best Practices

<investigate_before_planning>
Read research.md and key source files COMPLETELY before proposing design options.
Do not speculate about code structure or patterns you have not verified.
If research references specific files, read them to understand current implementation.
</investigate_before_planning>

<use_parallel_tool_calls>
When gathering context, read multiple files in parallel where possible.
Spawn @codebase-analyzer and @codebase-pattern-finder in parallel for independent analyses.
Wait for results before synthesizing into design options.
</use_parallel_tool_calls>

<avoid_overengineering>
Plans should specify the minimum changes needed to solve the problem.
Do not plan for hypothetical future requirements.
Do not add abstractions or flexibility that wasn't requested.
Simple, focused plans lead to better implementations.
</avoid_overengineering>

<explicit_file_references>
Every change in the plan must reference specific files with paths.
Use file:line references from research where possible.
Vague plans lead to vague implementations.
</explicit_file_references>
</claude4_guidance>

<goal>
Produce a thorough plan.md that an implementer can follow step-by-step, with clear success criteria and no open questions.
</goal>

<prerequisites>
- `research.md` must exist and have been reviewed by human
- Bead must be in appropriate status
</prerequisites>

<bead_id>$1</bead_id>

<workflow>

<phase name="gather_context">
## Phase 1: Gather Context

<read_all_inputs>
Read completely before planning:

1. **Research**: `.beads/artifacts/$1/research.md`
2. **Spec** (if exists): `.beads/artifacts/$1/spec.md`
3. **Bead metadata**: `bd show $1 --json`
4. **Key files** identified in research (read them fully)
</read_all_inputs>

<parallel_deep_dive>
If research identified areas needing deeper understanding, spawn parallel analyzers:

- @codebase-analyzer: Understand [specific component] implementation details
- @codebase-pattern-finder: Find examples of [pattern] we should follow

WAIT for all to complete before proceeding.
</parallel_deep_dive>
</phase>

<phase name="design_options">
## Phase 2: Present Design Options

<interactive_design>
Before writing the full plan, present options to the human:

```
Based on research, here's my understanding:

Current State
─────────────
[Key discovery about existing code with file:line]
[Pattern or convention to follow]

Design Options
──────────────
1. [Option A]: [approach]
   Pros: [benefits]
   Cons: [drawbacks]
   Effort: [estimate]
   Design Quality:
     - DRY: [yes/no/partial]
     - Orthogonality: [high/medium/low]
     - Easy to Change: [yes/no]
     - Follows Idioms: [yes/no]

2. [Option B]: [approach]
   Pros: [benefits]
   Cons: [drawbacks]
   Effort: [estimate]
   Design Quality:
     - DRY: [yes/no/partial]
     - Orthogonality: [high/medium/low]
     - Easy to Change: [yes/no]
     - Follows Idioms: [yes/no]

Recommendation: Option [X] because [reason]
  - Best aligns with: [DRY/Orthogonality/Simplicity/etc.]

Open Questions
──────────────
- [Any decision that needs human input]

Which approach? (1/2/other)
```

Do NOT proceed until human confirms approach.
</interactive_design>
</phase>

<phase name="structure">
## Phase 3: Plan Structure

<propose_structure>
After approach is confirmed, propose the plan structure:

```
Proposed Plan Structure
───────────────────────

## Phases:
1. [Phase name] - [what it accomplishes]
2. [Phase name] - [what it accomplishes]
3. [Phase name] - [what it accomplishes]

Does this phasing make sense? Adjust order/granularity?
```

Get approval before writing detailed plan.
</propose_structure>
</phase>

<phase name="write_plan">
## Phase 4: Write Detailed Plan

<document_structure>
Write to `.beads/artifacts/$1/plan.md`:

```markdown
---
date: [ISO timestamp]
bead: $1
approach: [chosen approach from Phase 2]
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

## What We're NOT Doing
[Explicit out-of-scope items - prevents scope creep]

## Implementation Approach
[High-level strategy and reasoning]

---

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes]

### Changes Required

#### 1. [Component/File]
**File**: `path/to/file.ts`
**Changes**:
- [Specific change 1]
- [Specific change 2]

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

## Testing Strategy (REQUIRED)

Apply **Agile Testing** principles (Crispin & Gregory):

### Test Pyramid (bottom to top)
Plan tests following the pyramid - more at the bottom, fewer at top:

```
        /\
       /  \  E2E/UI (few)
      /────\
     /      \  Integration (some)
    /────────\
   /          \  Unit (many)
  ──────────────
```

### Agile Testing Quadrants

**Q1 - Technology-Facing, Supporting Team** (Automated):
- [ ] Unit tests: `path/to/test.ts`
- [ ] Component tests: `path/to/component.test.ts`

**Q2 - Business-Facing, Supporting Team** (Automated):
- [ ] Functional tests / Story tests
- [ ] Examples as specifications (BDD-style if applicable)

**Q3 - Business-Facing, Critiquing Product** (Manual/Exploratory):
- [ ] Exploratory testing scenarios
- [ ] Usability verification

**Q4 - Technology-Facing, Critiquing Product** (Automated where possible):
- [ ] Performance considerations
- [ ] Security considerations (if applicable)

### New Tests to Write
- [ ] [Unit test] - `path/to/test.ts` - [what it verifies]
- [ ] [Unit test] - `path/to/test.ts` - [what it verifies]
- [ ] [Integration test] - `path/to/integration.test.ts` - [what it verifies]

### Existing Tests to Update
- [ ] [Update test for A] - `path/to/existing.test.ts`

### Test Coverage Requirements
- [ ] All new public functions have unit tests
- [ ] Happy path tested
- [ ] Edge cases documented in spec are tested
- [ ] Error paths are tested
- [ ] Tests serve as living documentation

### Exploratory Testing Notes
- [Areas that need manual exploration]
- [Edge cases to probe manually]

### Manual Verification Steps
1. [Specific step]
2. [Another step]

## Build & Test Commands
```bash
# Build
npm run build

# Test
npm test

# Lint
npm run lint
```

## References
- Research: `.beads/artifacts/$1/research.md`
- Similar implementation: `[file:line]`
```
</document_structure>
</phase>

<phase name="review_handoff">
## Phase 5: Review and Handoff

<handoff>
After writing plan, present for review:

```
Plan Created: $1
━━━━━━━━━━━━━━━━

Summary
───────
[1-2 sentence summary of approach]

Phases
──────
1. [Phase 1 name] - [brief description]
2. [Phase 2 name] - [brief description]
3. [Phase 3 name] - [brief description]

Estimated Effort: [time]

Artifact
────────
.beads/artifacts/$1/plan.md

Please review the plan. When approved, run:

  /implement $1

Or provide feedback to adjust the plan.
```
</handoff>
</phase>

</workflow>

<design_principles>
## Design Principles

When evaluating design options, apply these principles:

### From The Pragmatic Programmer
- **DRY**: Will this design avoid knowledge duplication?
- **Orthogonality**: Are components decoupled? Can they change independently?
- **ETC**: Is this design easy to change later?
- **Reversibility**: Can we undo this decision if wrong?

### From A Philosophy of Software Design
- **Deep Modules**: Does this create simple interfaces hiding complexity?
- **Information Hiding**: What complexity can we encapsulate?
- **Define Errors Out**: Can we design the API so errors can't happen?
- **Pull Complexity Down**: Can lower layers absorb complexity?

### From The Art of Readable Code
- **Clarity**: Will the implementation be easy to understand?
- **Simplicity**: Is this the simplest solution that works?
- **Cognitive Load**: How much mental effort to understand?

### Design Option Evaluation
When presenting options in Phase 2, evaluate each against:
- [ ] Follows DRY (no duplication)
- [ ] Components are orthogonal (loosely coupled)
- [ ] Easy to change/extend
- [ ] Simple interface, complexity hidden
- [ ] Clear, readable implementation
- [ ] Follows language idioms
</design_principles>

<ace_fca_alignment>
- **Artifacts over Memory**: Plan persisted to plan.md
- **High-Leverage Review**: Human approves before implementation
- **No Open Questions**: All decisions made before writing plan
- **Actionable Detail**: Implementer can execute step-by-step
</ace_fca_alignment>

<constraints>
- Read research.md COMPLETELY before planning
- Get human approval on approach before writing detailed plan
- No open questions in final plan - resolve everything first
- Include both automated AND manual success criteria
- Include explicit "What We're NOT Doing" section
- Every phase must have testable success criteria
- If plan is too large (>5 phases), recommend /split
- **MANDATORY**: Testing Strategy section must specify new tests to write
- **MANDATORY**: Every new feature/fix must have corresponding tests planned
- Tests are not optional - no tests = incomplete plan
</constraints>
