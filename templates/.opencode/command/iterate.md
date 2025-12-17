---
description: Iterate on existing implementation plan based on feedback
---
<context>
You are updating an existing implementation plan based on user feedback.

Be surgical: make precise edits, not wholesale rewrites. Preserve good content that doesn't need changing. This command is for refinement, not regeneration.
</context>

<investigate_before_editing>
Read the existing plan COMPLETELY before making changes. Understand the full context so your edits don't break dependencies between phases or invalidate existing success criteria.
</investigate_before_editing>

<avoid_overengineering>
Only change what the user requested - no "bonus improvements". If user says "update phase 2", don't also refactor phase 1 "while you're at it".

Bad: "I also improved phases 1 and 3 for consistency"
Good: "Updated phase 2 as requested. Phases 1 and 3 unchanged."
</avoid_overengineering>

<use_parallel_tool_calls>
If research is needed for the changes, spawn @codebase-analyzer (LSP-enabled) and @codebase-pattern-finder (AST-grep enabled) in parallel.
</use_parallel_tool_calls>

<goal>
Update the plan based on user feedback while maintaining quality and consistency.
</goal>

<bead_id>$1</bead_id>

<workflow>

<phase name="resolve_plan">
## Phase 1: Resolve Plan

**If $1 is empty:**
```
Which bead's plan would you like to update?

Tip: /iterate bd-xxx "add a phase for error handling"
```

**If bead ID provided:**
Verify plan exists:
```bash
ls -la .beads/artifacts/$1/plan.md
```
</phase>

<phase name="understand_request">
## Phase 2: Understand Request

**If feedback provided with command:**
- Parse what to add/modify/remove
- Proceed to Phase 3

**If no feedback provided:**
```
I've found the plan. What changes would you like?

Examples:
- "Add a phase for migration handling"
- "Split Phase 2 into backend and frontend"
- "Update success criteria to include performance tests"
```
</phase>

<phase name="read_and_research">
## Phase 3: Read Plan and Research (if needed)

Read the plan completely:
```
.beads/artifacts/$1/plan.md
```

**Only spawn research if changes require new technical understanding.**

If feedback involves unfamiliar code:
- @explore: Find relevant files (specify thoroughness level)
- @codebase-analyzer: Understand implementation details (uses LSP for navigation)

If feedback is structural (add phase, split phase, update criteria):
- Skip research, proceed directly
</phase>

<phase name="confirm_changes">
## Phase 4: Confirm Understanding

```
Based on your feedback, I understand you want to:
- [Change 1]
- [Change 2]

I plan to update by:
1. [Specific modification]
2. [Another modification]

Does this align? (yes/adjust)
```

Do NOT proceed until user confirms.
</phase>

<phase name="edit_plan">
## Phase 5: Edit Plan

Make focused, precise edits:
- Use Edit tool for surgical changes
- Maintain existing structure
- Keep file:line references accurate
- Update success criteria if scope changed
- Update Testing Strategy if new functionality added
</phase>

<phase name="present_changes">
## Phase 6: Present Changes

```
Plan Updated: $1
━━━━━━━━━━━━━━━━

Changes Made:
- [Change 1]
- [Change 2]

Artifact: .beads/artifacts/$1/plan.md

Further adjustments? Or continue with:
  /implement $1
```
</phase>

</workflow>

<constraints>
- Read entire plan before making changes
- Get user confirmation before editing
- Only change what was requested
- Update Testing Strategy if adding functionality
- Keep success criteria measurable
</constraints>
