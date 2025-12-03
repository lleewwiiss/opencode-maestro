---
description: Start work on a bead - find/create bead, setup workspace, load context, guide to research
---
<context>
You are starting a focused work session. Your job is to get the developer working on the right bead with full context.

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

**If $1 is empty:**

Find ready beads:
```bash
bd ready --json --limit 10
```

If no ready beads, fall back to open beads:
```bash
bd list --status open --json
```

Present options:
```
Ready Work (no blockers):
─────────────────────────
1. bd-a1b2 "Fix login timeout" (P1, bug)
2. bd-c3d4 "Add user dashboard" (P2, feature)

Pick a number, enter a bead ID, or type "new" to create one.
```

**If $1 has a bead ID:**

Validate it exists:
```bash
bd show $1 --json
```
</phase>

<phase name="isolation">
## Phase 2: Setup Isolation

Check $ARGUMENTS for flags:
- `--worktree` → Use git worktree
- `--branch` → Use feature branch
- Neither → Ask user to choose

Check for uncommitted changes:
```bash
git status --porcelain
```

If dirty, ask user to stash, commit, or continue.

**For worktree:**
```bash
git worktree add ../$BEAD_ID -b $BEAD_ID
```

**For branch:**
```bash
git checkout -b $BEAD_ID
```
</phase>

<phase name="load_context">
## Phase 3: Load Context

Check for existing artifacts:
```bash
ls -la .beads/artifacts/$BEAD_ID/ 2>/dev/null
```

Read any that exist: spec.md, research.md, plan.md

If spec mentions specific components, use subagents in parallel:
- @codebase-locator: Find relevant files
- @codebase-pattern-finder: Find similar implementations

Present briefing:
```
Bead: $BEAD_ID
━━━━━━━━━━━━━━

Title: [from bd show]
Type/Priority: [from bd show]

Artifacts:
  spec.md:     [exists/missing]
  research.md: [exists/missing]
  plan.md:     [exists/missing]

Spec Summary: [Key points]
```
</phase>

<phase name="next_action">
## Phase 4: Guide Next Action

Based on artifact state:

**NO spec.md:** Run /create to create one properly
**NO research.md:** Run /research $BEAD_ID
**research.md EXISTS, NO plan.md:** Run /plan $BEAD_ID
**plan.md EXISTS:** Run /implement $BEAD_ID
</phase>

</workflow>

<constraints>
- If no bead ID, help user find or create one
- Never proceed with dirty git without acknowledgment
- Always validate bead exists
- Guide to correct next command based on artifact state
</constraints>
