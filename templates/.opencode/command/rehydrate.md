---
description: Rehydrate work from handoff document - restore context and continue
---
<context>
You are rehydrating work from a handoff document.

A previous session created a handoff to preserve context. Your job is to:
1. Read and understand the handoff
2. Validate current state matches expectations
3. Load necessary context
4. Continue work seamlessly

The goal is seamless continuation - the user shouldn't notice the context switch occurred.
</context>

<investigate_before_acting>
Read the handoff document completely before taking any action. Verify current state matches what handoff describes. Don't assume - validate that referenced files exist and haven't changed.

This prevents working from stale context that leads to incorrect changes.
</investigate_before_acting>

<use_parallel_tool_calls>
Validate state in parallel: run git status, git rev-parse HEAD, bd show, and file existence checks simultaneously. Compare all results against handoff expectations in one batch.
</use_parallel_tool_calls>

<state_verification>
If state has diverged (new commits, changed files, different branch), surface this immediately. Don't silently proceed with stale context - ask user how to handle the divergence.

Divergence scenarios:
- Commit changed: Show `git log [handoff_commit]..HEAD` to reveal intervening changes
- Files missing: List missing references, ask to confirm before proceeding
- Branch different: Ask whether to switch or proceed on current branch
</state_verification>

<goal>
Rehydrate work seamlessly from a handoff, as if no context switch occurred.
</goal>

<principles>
- **Fail Fast**: Validate state immediately. If something's wrong, surface it before wasting effort.
- **Don't Program by Coincidence**: Understand the current state, don't assume. Verify before acting.
- **Define errors out of existence**: If state has drifted, handle it gracefully rather than failing mysteriously later.
- **Artifacts over Memory**: The handoff document IS the memory. Trust it, but verify against current state.
- **Session continuity**: The goal is seamless continuation. User shouldn't notice the context switch.
</principles>

<bead_id>$1</bead_id>

<workflow>

<phase name="find_handoff">
## Phase 1: Find Handoff Document

**If $1 provided:**

Find most recent handoff:
```bash
ls -t .beads/artifacts/$1/handoffs/*.md 2>/dev/null | head -1
```

If no handoffs found, suggest /start $1 instead.

**If no bead ID:**

Ask user to provide bead ID or specific handoff path.
</phase>

<phase name="read_handoff">
## Phase 2: Read Handoff Completely

Read the handoff document fully. Extract:
- Current task and phase
- Critical references
- Recent changes
- Learnings
- Verification status
- Action items
- Blockers

Immediately read all files listed in "Critical References" - do NOT use subagents for these.
</phase>

<phase name="validate_state">
## Phase 3: Validate Current State

Run in parallel:
```bash
git status --porcelain
git branch --show-current
git rev-parse HEAD
bd show $1 --json
```

Compare handoff expectations vs reality:

| Aspect | Handoff Says | Current State | Match? |
|--------|--------------|---------------|--------|
| Branch | [branch] | [actual] | ✓/✗ |
| Commit | [git_commit] | [HEAD SHA] | ✓/✗ |
| Phase | [N] | [check plan.md] | ✓/✗ |

**Verify critical references exist:**
For each file listed in handoff's "Critical References" section, confirm it exists:
```bash
ls -la [path/to/key/file.ts]  # for each referenced file
```

**If commit diverged:** Warn user that codebase changed since handoff. Show `git log --oneline [handoff_commit]..HEAD` to reveal intervening changes. Ask whether to proceed or abort.

**If files missing/moved:** List missing references. Context may be stale—ask user to confirm before proceeding.

**If state matches:** Optionally re-run verification (build/test/lint) to confirm environment still healthy before continuing.

**If state diverged:** Present differences and ask user how to proceed
</phase>

<phase name="present_context">
## Phase 4: Present Restored Context

```
Rehydrating: $1
━━━━━━━━━━━━

From Handoff: [date]
Phase: [N] - [Name]
Progress: [X/Y steps]

Key Learnings:
- [Learning 1]
- [Learning 2]

Current Status:
Build: [status] | Tests: [status] | Lint: [status]

Action Items:
1. [First priority]
2. [Second]

Ready to continue with: [first action item]

Proceed? (yes / adjust / show more context)
```
</phase>

<phase name="continue_work">
## Phase 5: Continue Work

Use TodoWrite to create task list from handoff action items.

Apply learnings from handoff throughout implementation:
- Respect constraints discovered
- Follow patterns identified
- Avoid gotchas documented

Continue with normal workflow: execute plan steps, update plan.md, run tests after each change.
</phase>

</workflow>

<constraints>
- Read handoff document COMPLETELY before acting
- Validate state before continuing
- Present divergences clearly if state doesn't match
- Apply learnings from handoff - don't repeat discoveries
- Create todos from action items for tracking
</constraints>
