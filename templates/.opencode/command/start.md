---
description: Start work on a bead - find/create bead, setup workspace, load context, guide to research
---
<context>
You are starting a focused work session, aligned with ACE-FCA (Advanced Context Engineering for Coding Agents). Your job is to get the developer working on the right bead with full context.

If no bead ID is provided, help find or create one.
</context>

<goal>
Get the developer from "I want to work" to "ready for research" with minimal friction.
</goal>

<bead_id>$1</bead_id>
<flags>$ARGUMENTS</flags>

<workflow>

<phase name="resolve_bead">
## Phase 1: Resolve Bead

<if_no_bead_id>
**If $1 is empty (no bead ID provided):**

Find ready beads (unblocked work):
```bash
bd ready --json --limit 10
```

If no ready beads, fall back to open beads:
```bash
bd list --status open --json
```

Also show project stats for context:
```bash
bd stats
```

Present options:
```
Ready Work (no blockers):
─────────────────────────
1. bd-a1b2 "Fix login timeout" (P1, bug)
2. bd-c3d4 "Add user dashboard" (P2, feature)
3. bd-e5f6 "Refactor auth module" (P3, task)

Blocked: 2 beads waiting on dependencies
Stats: 5 open, 12 closed, 2 blocked

Pick a number, enter a bead ID, or type "new" to create one.
```

- If user picks a number → use that bead ID
- If user types "new" → run `/create` flow inline
- If user enters ID directly → use that ID
</if_no_bead_id>

<if_bead_id_provided>
**If $1 has a bead ID:**

Validate it exists:
```bash
bd show $1 --json
```

If not found:
```
Bead '$1' not found.

Options:
1. Pick from existing: [show bd list]
2. Create new: type "new"
```
</if_bead_id_provided>
</phase>

<phase name="isolation">
## Phase 2: Setup Isolation

<check_flags>
Check $ARGUMENTS for flags:
- `--worktree` → Use branchlet (isolated filesystem)
- `--branch` → Use feature branch (same filesystem)
- Neither → Ask user to choose
</check_flags>

<dirty_check>
Check for uncommitted changes:
```bash
git status --porcelain
```

If dirty, ask:
```
Working tree has uncommitted changes.
1. Stash changes (git stash)
2. Commit first
3. Continue anyway (risky)
```
</dirty_check>

<setup>
**For worktree:**
```bash
branchlet create $BEAD_ID
cd $(branchlet path $BEAD_ID)
```

**For branch:**
```bash
git checkout -b $BEAD_ID
```

Report:
```bash
pwd
git branch --show-current
git status -sb
```
</setup>
</phase>

<phase name="load_context">
## Phase 3: Load Context

<gather_artifacts>
Check for existing artifacts:
```bash
ls -la .beads/artifacts/$BEAD_ID/ 2>/dev/null
```

Read any that exist:
- `spec.md` - The specification (should always exist from /create)
- `research.md` - Previous research findings
- `plan.md` - Implementation plan
</gather_artifacts>

<use_subagents>
If spec mentions specific components/files, use subagents in parallel:
- @codebase-locator: Find relevant files
- @codebase-pattern-finder: Find similar implementations
</use_subagents>

<present_briefing>
Present structured summary:

```
Bead: $BEAD_ID
━━━━━━━━━━━━━━

Title: [from bd show]
Type: [from bd show]  
Priority: [from bd show]
Status: [from bd show]

Artifacts:
  spec.md:     [exists/missing]
  research.md: [exists/missing]
  plan.md:     [exists/missing]

Spec Summary:
  [Key points from spec.md]

Dependencies:
  [Any blocking or related beads]
```
</present_briefing>
</phase>

<phase name="next_action">
## Phase 4: Guide Next Action

<decision_tree>
Based on artifact state:

**If NO spec.md:**
```
Missing Specification
━━━━━━━━━━━━━━━━━━━━━
This bead has no spec. Run /create to create one properly,
or create .beads/artifacts/$BEAD_ID/spec.md manually.
```

**If NO research.md:**
```
Ready for Research
━━━━━━━━━━━━━━━━━━
Workspace is set up. Next step:

  /research $BEAD_ID

This explores the codebase and produces research.md.
After completion, review research.md then run /plan.
```

**If research.md EXISTS but NO plan.md:**
```
Ready for Planning
━━━━━━━━━━━━━━━━━━
Research exists. Review it, then:

  /plan $BEAD_ID

This creates the implementation plan.
```

**If plan.md EXISTS:**
```
Ready for Implementation
━━━━━━━━━━━━━━━━━━━━━━━━
Plan exists. Review it, then:

  /implement $BEAD_ID

Or re-run /plan if updates needed.
```
</decision_tree>
</phase>

</workflow>

<ace_fca_alignment>
- **Human as Orchestrator**: User picks bead, chooses isolation, reviews before proceeding
- **Frequent Intentional Compaction**: Each phase (/research, /plan, /implement) is subtask
- **Artifacts over Memory**: All state in .beads/artifacts/
- **High-Leverage Review**: Explicit review points between phases
</ace_fca_alignment>

<constraints>
- If no bead ID, help user find or create one
- Never proceed with dirty git without acknowledgment
- Always validate bead exists
- Guide to correct next command based on artifact state
- Spec should exist (created by /create)
</constraints>
