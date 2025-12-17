---
description: Create handoff document for session continuity - capture state before context limit
---
<context>
You are creating a handoff document to transfer work to a future session.

This is how we handle context window limits gracefully. Instead of losing context, we compact it into a structured artifact that can bootstrap a fresh session. This implements "Frequent Intentional Compaction" from ACE-FCA.

Create a thorough but CONCISE document - capture essential state without bloat.
</context>

<ground_all_claims>
Capture ALL essential state, but filter out noise. Include specific file:line references, not vague descriptions. Ground all learnings in actual code references so the next session can verify.

Bad: "Working on authentication improvements"
Good: "Implementing JWT refresh in auth/token.ts:45-89, currently stuck on expiry calculation at line 67"
</ground_all_claims>

<use_parallel_tool_calls>
Gather all state information in parallel: git status, bd show, file listings, artifact reads. Collect everything needed for the handoff in one parallel batch.
</use_parallel_tool_calls>

<state_tracking>
Use structured format for state data (JSON for test status, task progress). Use unstructured text for learnings and context. This helps the next session parse state quickly.
</state_tracking>

<goal>
Create a handoff document that allows a fresh session to continue work seamlessly.
</goal>

<principles>
- **DRY for knowledge**: Don't lose learnings. Capture discoveries so the next session doesn't re-discover them.
- **Use the power of text**: Plain text is universal, version-controllable, and survives tool changes.
- **Strategic thinking**: Capture not just what was done, but the reasoning. Context enables better future decisions.
- **Comments describe things not obvious from code**: The handoff captures what ISN'T in the code - context, decisions, gotchas.
- **Frequent Intentional Compaction**: Compress context into artifacts before it's lost to context limits.
- **Artifacts over Memory**: The handoff document becomes memory. Fresh sessions bootstrap from it.
</principles>

<bead_id>$1</bead_id>

<workflow>

<phase name="detect_context">
## Phase 1: Detect Current Context

Run in parallel:
```bash
git branch --show-current
bd show $1 --json
git status --porcelain
git diff --stat
ls -la .beads/artifacts/$1/ 2>/dev/null
```

Read current artifacts to understand progress:
- `.beads/artifacts/$1/plan.md` - Check phase progress
- `.beads/artifacts/$1/spec.md` - Original requirements
</phase>

<phase name="capture_state">
## Phase 2: Capture Session State

Gather repo provenance (critical for resume verification):
```bash
git rev-parse HEAD                    # git_commit
git branch --show-current             # branch
git remote get-url origin 2>/dev/null # repository
```

Capture these categories:

**Tasks & Status:** What were we working on? Which phase? What's complete vs in-progress?
**Recent Changes:** What files were modified? (file:line)
**Learnings:** What did we discover? Root causes? Patterns? Constraints?
**Next Steps:** What should the next session do first?
**Open Issues:** Blockers? Failing tests? Decisions needed?

<child_bead_context>
**If this is a child bead ($1 contains `.`):**

Extract parent ID:
```bash
PARENT_ID=$(echo "$1" | sed 's/\..*//')
```

Include parent context references in the handoff:
- Parent's research: `.beads/artifacts/$PARENT_ID/research.md`
- Parent's plan: `.beads/artifacts/$PARENT_ID/plan.md`
- Which phase number this child represents (extract N from bd-xxx.N)

This ensures `/rehydrate` has full epic context to continue work.
</child_bead_context>
</phase>

<phase name="write_handoff">
## Phase 3: Write Handoff Document

```bash
mkdir -p .beads/artifacts/$1/handoffs
```

Write to `.beads/artifacts/$1/handoffs/<timestamp>_handoff.md`:

```markdown
---
date: [ISO timestamp]
bead: $1
repository: [git remote origin URL]
git_commit: [current HEAD SHA]
branch: [current branch]
plan_phase: [which phase]
status: [in_progress | blocked | ready_for_review]
---

# Handoff: $1

## Current Task
- Phase: [N] - [Name]
- Status: [in_progress | complete | blocked]
- Step: [Which step within the phase]

## Critical References
- `.beads/artifacts/$1/plan.md` - Phase N in progress
- `path/to/key/file.ts` - Main file being modified

## Parent Context (if child bead)
<!-- Include if $1 contains "." -->
- Parent bead: $PARENT_ID
- Parent research: `.beads/artifacts/$PARENT_ID/research.md`
- Parent plan: `.beads/artifacts/$PARENT_ID/plan.md`
- This is Phase [N] of the epic

## Recent Changes
- `src/file.ts:45-67` - [What was changed]

## Learnings
- [Discovery with file:line reference]

## Verification Status
- Build: [passing | failing]
- Tests: [X passing, Y failing]
- Lint: [clean | N warnings]

## Action Items (Next Session)
1. [Most important next step]
2. [Second step]

## Blockers
- [Or "None"]

## To Rehydrate
```bash
/rehydrate $1
```
```
</phase>

<phase name="sync_and_report">
## Phase 4: Sync and Report

```bash
bd sync
```

```
Handoff Created: $1
━━━━━━━━━━━━━━━━━━

Phase: [N] - [Name]
Progress: [X/Y steps]

Artifact: .beads/artifacts/$1/handoffs/<timestamp>_handoff.md

To Rehydrate: /rehydrate $1
```
</phase>

</workflow>

<constraints>
- Capture ALL essential state
- Be CONCISE - filter noise, keep signal
- Use file:line references
- Include verification status
- Order action items by priority
- Always sync after creating handoff
</constraints>
