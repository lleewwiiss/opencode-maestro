---
description: Start work on a bead - find/create bead, setup workspace, load context, guide to research
---
<context>
You are starting a focused work session. Your job is to get the developer working on the right bead with full context.

If no bead ID is provided, help find or create one. This command orchestrates workspace setup and context loading before diving into research or implementation.
</context>

<goal>
Get the developer from "I want to work" to "ready for research" with minimal friction.
</goal>

<use_parallel_tool_calls>
Run independent operations in parallel: check git status, run bd commands, and read artifacts simultaneously. Fire background exploration agents immediately without waiting for results.
</use_parallel_tool_calls>

<default_to_action>
Once bead is identified and workspace is ready, proceed directly to loading context. Don't ask for confirmation at each step - flow through phases smoothly.
</default_to_action>

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

**Ensure artifacts are gitignored** (local-only, never committed):
```bash
grep -q ".beads/artifacts" .gitignore 2>/dev/null || echo ".beads/artifacts/" >> .gitignore
```

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
## Phase 3: Load Context (Async Pre-warm)

Check for existing artifacts:
```bash
ls -la .beads/artifacts/$BEAD_ID/ 2>/dev/null
```

Read any that exist: spec.md, research.md, plan.md

**Fire background agents immediately (don't wait):**
If spec mentions specific components:
```
background_task(agent="explore", prompt="Find files related to [component from spec] in this codebase. Return file paths and brief descriptions.")
background_task(agent="explore", prompt="Find files related to [other component] in this codebase.")
```

If spec mentions unfamiliar libraries:
```
background_task(agent="librarian", prompt="Look up [library] documentation and common usage patterns.")
```

**Continue immediately to briefing** - don't wait for background agents.

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

[Background agents running - results will be available for next phase]
```
</phase>

<phase name="next_action">
## Phase 4: Guide Next Action

**Collect background results** (if any were fired in Phase 3):
```
background_output(task_id="...") // for each task
```

Include any useful findings in your guidance.

Based on artifact state:

**NO spec.md:** Run /create to create one properly
**NO research.md:** Run /research $BEAD_ID (background exploration results will seed the research)
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
