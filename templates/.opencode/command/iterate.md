---
description: Iterate on existing implementation plan based on feedback
subtask: true
---
<context>
You are updating an existing implementation plan based on user feedback, aligned with ACE-FCA principles. Plans are high-leverage artifacts - a bad plan leads to hundreds of bad lines of code.

Be surgical: make precise edits, not wholesale rewrites. Preserve good content that doesn't need changing.
</context>

<claude4_guidance>
## Claude 4 Best Practices

<investigate_before_editing>
Read the existing plan COMPLETELY before making changes.
If feedback requires understanding new code patterns, research first.
Do not speculate about code you have not verified.
</investigate_before_editing>

<use_parallel_tool_calls>
If research is needed, spawn @codebase-analyzer and @codebase-pattern-finder in parallel.
Read multiple files in parallel when gathering context.
Wait for all results before synthesizing changes.
</use_parallel_tool_calls>

<avoid_overengineering>
Only change what the user requested.
Don't "improve" sections that weren't mentioned.
Preserve existing structure unless explicitly changing it.
</avoid_overengineering>

<be_interactive>
Confirm understanding before making changes.
Show what you plan to change before doing it.
Allow course corrections.
</be_interactive>
</claude4_guidance>

<goal>
Update the plan based on user feedback while maintaining quality and consistency.
</goal>

<bead_id>$1</bead_id>

<workflow>

<phase name="resolve_plan">
## Phase 1: Resolve Plan

<if_no_bead_id>
**If $1 is empty (no bead ID provided):**

```
I'll help you iterate on an existing implementation plan.

Which bead's plan would you like to update?

Tip: You can invoke this command with a bead ID:
  /iterate bd-xxx "add a phase for error handling"
```

Wait for user input.
</if_no_bead_id>

<if_bead_id_provided>
**If bead ID provided:**

Verify plan exists:
```bash
ls -la .beads/artifacts/$1/plan.md
```

If not found:
```
No plan found at .beads/artifacts/$1/plan.md

Options:
1. Create a plan first: /plan $1
2. Specify different bead ID
```
</if_bead_id_provided>
</phase>

<phase name="understand_request">
## Phase 2: Understand Request

<check_for_feedback>
**If feedback provided with command:**
- Parse what the user wants to add/modify/remove
- Proceed to Phase 3

**If no feedback provided:**
```
I've found the plan at .beads/artifacts/$1/plan.md

What changes would you like to make?

Examples:
- "Add a phase for migration handling"
- "Split Phase 2 into backend and frontend"
- "Update success criteria to include performance tests"
- "Remove the caching phase - we'll do that later"
- "Add more specific file paths to Phase 1"
```

Wait for user input.
</check_for_feedback>
</phase>

<phase name="read_and_research">
## Phase 3: Read Plan and Research (if needed)

<read_existing_plan>
Read the plan completely:
```
.beads/artifacts/$1/plan.md
```

Understand:
- Current structure and phases
- Success criteria format
- Testing strategy
- Scope boundaries
</read_existing_plan>

<research_if_needed>
**Only spawn research if changes require new technical understanding.**

If the feedback involves unfamiliar code:
- @codebase-locator: Find relevant files
- @codebase-analyzer: Understand implementation details
- @codebase-pattern-finder: Find similar patterns

WAIT for all to complete before proceeding.

If feedback is structural (add phase, split phase, update criteria):
- Skip research
- Proceed directly to Phase 4
</research_if_needed>
</phase>

<phase name="confirm_changes">
## Phase 4: Confirm Understanding

Present understanding before editing:

```
Based on your feedback, I understand you want to:
- [Change 1 with specific detail]
- [Change 2 with specific detail]

I plan to update the plan by:
1. [Specific modification]
2. [Another modification]

Does this align with your intent? (yes/adjust)
```

Do NOT proceed until user confirms.
</phase>

<phase name="edit_plan">
## Phase 5: Edit Plan

<surgical_edits>
Make focused, precise edits:
- Use Edit tool for surgical changes
- Maintain existing structure unless explicitly changing it
- Keep all file:line references accurate
- Update success criteria if scope changed
</surgical_edits>

<maintain_quality>
Ensure edits maintain:
- Specific file paths and line numbers
- Both automated AND manual success criteria
- "What We're NOT Doing" section (update if scope changed)
- Testing Strategy section (update if new functionality added)
- Phase completion checkboxes
</maintain_quality>

<preserve_format>
Follow existing conventions:
- Same markdown structure
- Same success criteria format (Automated vs Manual)
- Same phase structure
- `make` commands for automated verification where possible
</preserve_format>
</phase>

<phase name="present_changes">
## Phase 6: Present Changes

```
Plan Updated: $1
━━━━━━━━━━━━━━━━

Changes Made
────────────
- [Specific change 1]
- [Specific change 2]

The Updated Plan Now
────────────────────
[Key improvement or structural change]

Artifact
────────
.beads/artifacts/$1/plan.md

Would you like any further adjustments?
Or if satisfied, continue with:

  /implement $1
```
</phase>

</workflow>

<design_principles>
When adding new phases or modifying approach, ensure alignment with:

### The Pragmatic Programmer
- **DRY**: Does the change avoid duplication?
- **Orthogonality**: Are new phases properly decoupled?
- **ETC**: Does the change make future modifications easier?

### A Philosophy of Software Design
- **Deep Modules**: Do new phases hide complexity behind simple interfaces?
- **Information Hiding**: Is complexity properly encapsulated?

### Agile Testing (for Testing Strategy changes)
- New functionality → new tests in Testing Strategy
- Follow test pyramid (more unit, fewer E2E)
- Include both Q1-Q4 quadrant coverage
</design_principles>

<ace_fca_alignment>
- **Artifacts over Memory**: Changes persisted to plan.md
- **High-Leverage Review**: User confirms before changes applied
- **No Open Questions**: Resolve uncertainties before editing
- **Surgical Precision**: Change only what's needed
</ace_fca_alignment>

<constraints>
- Read the entire plan before making changes
- Get user confirmation before editing
- Only change what was requested - no "bonus improvements"
- Maintain quality standards in edited sections
- If feedback raises questions, ASK - don't guess
- Update Testing Strategy if adding new functionality
- Keep success criteria measurable and specific
</constraints>
