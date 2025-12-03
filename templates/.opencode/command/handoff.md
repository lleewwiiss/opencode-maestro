---
description: Create handoff document for session continuity - capture state before context limit
subtask: true
---
<context>
You are creating a handoff document to transfer work to a future session.

This is how we handle context window limits gracefully. Instead of losing context, we compact it into a structured artifact that can bootstrap a fresh session.

Create a thorough but CONCISE document - capture essential state without bloat.
</context>

<claude4_guidance>
- Capture ALL essential state, but filter out noise
- Include specific file:line references, not vague descriptions
- Ground all learnings in actual code references
</claude4_guidance>

<goal>
Create a handoff document that allows a fresh session to continue work seamlessly.
</goal>

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

## To Resume
```bash
/resume $1
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

To Resume: /resume $1
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
