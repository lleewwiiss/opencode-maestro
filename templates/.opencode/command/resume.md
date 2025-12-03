---
description: Resume work from handoff document - restore context and continue
subtask: true
---
<context>
You are resuming work from a handoff document, aligned with ACE-FCA's "Frequent Intentional Compaction" principle.

A previous session created a handoff to preserve context. Your job is to:
1. Read and understand the handoff
2. Validate current state matches expectations
3. Load necessary context
4. Continue work seamlessly
</context>

<claude4_guidance>
## Claude 4 Best Practices

<investigate_before_acting>
Read the handoff document completely.
Verify the current state matches what the handoff describes.
Don't assume - validate that referenced files exist and match.
</investigate_before_acting>

<use_parallel_tool_calls>
Gather validation context in parallel:
- Read handoff document
- Check git status
- Read plan.md for current phase
- Verify key files exist
</use_parallel_tool_calls>

<be_interactive>
Present what you found before continuing.
Get user confirmation if state has diverged.
Allow course corrections before resuming work.
</be_interactive>
</claude4_guidance>

<goal>
Resume work seamlessly from a handoff, as if no context switch occurred.
</goal>

<bead_id>$1</bead_id>

<workflow>

<phase name="find_handoff">
## Phase 1: Find Handoff Document

<if_bead_id_provided>
**If $1 provided:**

Find the most recent handoff:
```bash
ls -t .beads/artifacts/$1/handoffs/*.md 2>/dev/null | head -1
```

If no handoffs found:
```
No handoff documents found for $1.

Options:
1. Start fresh: /start $1
2. Check different bead
3. Provide specific handoff path
```
</if_bead_id_provided>

<if_no_bead_id>
**If no bead ID provided:**

```
I'll help you resume work from a handoff.

Options:
1. Provide bead ID: /resume bd-xxx
2. Provide specific handoff path: /resume path/to/handoff.md

Tip: Use /start to see available beads with ready work.
```

Wait for user input.
</if_no_bead_id>
</phase>

<phase name="read_handoff">
## Phase 2: Read Handoff Completely

<read_document>
Read the handoff document WITHOUT limit/offset - need full content.

Extract:
- Current task and phase
- Critical references
- Recent changes
- Learnings
- Verification status
- Artifacts
- Action items
- Blockers
</read_document>

<read_critical_refs>
Immediately read all files listed in "Critical References":
- Plan document
- Key source files
- Any other referenced docs

Do NOT use subagents for these - read them directly into main context.
</read_critical_refs>
</phase>

<phase name="validate_state">
## Phase 3: Validate Current State

<parallel_validation>
Run in parallel:

```bash
# Git state
git status --porcelain
git branch --show-current
git log --oneline -3

# Bead state
bd show $1 --json

# Verify key files exist
ls -la [files from Critical References]
```
</parallel_validation>

<compare_states>
Compare handoff expectations vs reality:

| Aspect | Handoff Says | Current State | Match? |
|--------|--------------|---------------|--------|
| Branch | [branch] | [actual] | ✓/✗ |
| Phase | [N] | [check plan.md] | ✓/✗ |
| Files | [list] | [exist?] | ✓/✗ |
| Tests | [status] | [run tests] | ✓/✗ |
</compare_states>

<handle_divergence>
**If state matches handoff:**
- Proceed to Phase 4

**If state has diverged:**
```
State Divergence Detected
─────────────────────────

The current state differs from the handoff:

- [Specific difference 1]
- [Specific difference 2]

Options:
1. Continue anyway (I'll adapt)
2. Reset to handoff state
3. Create new handoff from current state

What would you like to do?
```

Wait for user decision.
</handle_divergence>
</phase>

<phase name="present_context">
## Phase 4: Present Restored Context

<summary>
```
Resuming: $1
━━━━━━━━━━━━

From Handoff
────────────
Date: [handoff date]
Phase: [N] - [Phase Name]
Progress: [X/Y steps complete in phase]

Key Learnings (from handoff)
────────────────────────────
- [Learning 1 with file:line]
- [Learning 2 with file:line]

Current Status
──────────────
Build: [passing/failing]
Tests: [X passing, Y failing]
Lint: [clean/warnings/errors]

Action Items (from handoff)
───────────────────────────
1. [First priority item]
2. [Second item]
3. [Third item]

Ready to continue with: [first action item]

Proceed? (yes / adjust priorities / show more context)
```
</summary>
</phase>

<phase name="create_todos">
## Phase 5: Create Todo List

<setup_todos>
Use TodoWrite to create task list from handoff action items:

Convert each action item to a todo:
- Priority based on order in handoff
- Status: pending (first item: in_progress)
</setup_todos>

<present_plan>
```
Todo List Created
─────────────────

[Show todos from TodoWrite]

Starting with: [first todo]

Let's continue where we left off.
```
</present_plan>
</phase>

<phase name="continue_work">
## Phase 6: Continue Work

<apply_learnings>
Throughout implementation, apply learnings from handoff:
- Respect constraints discovered
- Follow patterns identified
- Avoid gotchas documented
</apply_learnings>

<reference_handoff>
If blocked or uncertain:
- Re-read relevant handoff sections
- Check if answer is in learnings
- Reference critical files noted
</reference_handoff>

<progress_normally>
Continue with normal workflow:
- Execute plan steps
- Update plan.md with progress
- Run tests after each change
- Mark todos complete as you go
</progress_normally>
</phase>

</workflow>

<common_scenarios>
## Common Scenarios

### Clean Continuation
- State matches handoff exactly
- All files present
- Tests in expected state
- Proceed with action items

### Minor Divergence
- Small differences (new commits, minor file changes)
- Core context still valid
- Adapt and continue

### Major Divergence
- Significant changes since handoff
- Key files missing or heavily modified
- May need to re-research or re-plan
- Ask user how to proceed

### Stale Handoff
- Handoff is old (days/weeks)
- Major refactoring has occurred
- Original approach may be invalid
- Recommend fresh /research or /plan
</common_scenarios>

<ace_fca_alignment>
- **Frequent Intentional Compaction**: Restoring from compacted state
- **Artifacts over Memory**: Handoff document is the memory
- **Human as Orchestrator**: User confirms before continuing
- **Session Continuity**: Seamless transition between sessions
</ace_fca_alignment>

<constraints>
- Read handoff document COMPLETELY before acting
- Validate state before continuing - don't assume
- Present divergences clearly if state doesn't match
- Get user confirmation if significant differences
- Apply learnings from handoff - don't repeat discoveries
- Create todos from action items for tracking
- Reference handoff throughout work session
</constraints>
