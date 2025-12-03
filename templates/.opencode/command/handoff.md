---
description: Create handoff document for session continuity - capture state before context limit
subtask: true
---
<context>
You are creating a handoff document to transfer work to a future session, aligned with ACE-FCA's "Frequent Intentional Compaction" principle.

This is how we handle context window limits gracefully. Instead of losing context, we compact it into a structured artifact that can bootstrap a fresh session.

Create a thorough but CONCISE document - capture essential state without bloat.
</context>

<claude4_guidance>
## Claude 4 Best Practices

<be_thorough_but_concise>
Capture ALL essential state, but filter out noise.
Include specific file:line references, not vague descriptions.
Focus on what the next session NEEDS to know to continue.
</be_thorough_but_concise>

<use_parallel_tool_calls>
Gather context in parallel:
- git status/diff
- Read plan.md progress
- Check bead status
</use_parallel_tool_calls>

<ground_all_claims>
Every learning, change, and reference must be grounded in actual files.
Use file:line syntax for code references.
Don't describe code you haven't verified.
</ground_all_claims>
</claude4_guidance>

<goal>
Create a handoff document that allows a fresh session to continue work seamlessly, as if no context switch occurred.
</goal>

<bead_id>$1</bead_id>

<workflow>

<phase name="detect_context">
## Phase 1: Detect Current Context

<gather_state>
Run in parallel:

```bash
# Current bead (from branch or argument)
git branch --show-current

# Bead details
bd show $1 --json

# Git state
git status --porcelain
git diff --stat

# Artifact state
ls -la .beads/artifacts/$1/ 2>/dev/null
```
</gather_state>

<read_artifacts>
Read current artifacts to understand progress:
- `.beads/artifacts/$1/plan.md` - Check phase progress (look for [x] marks)
- `.beads/artifacts/$1/spec.md` - Original requirements
- `.beads/artifacts/$1/research.md` - Context gathered
</read_artifacts>
</phase>

<phase name="capture_state">
## Phase 2: Capture Session State

<identify_key_info>
Capture these categories:

**Tasks & Status:**
- What were we working on?
- Which phase of the plan?
- What's complete vs in-progress vs planned?

**Recent Changes:**
- What files were modified? (file:line)
- What was the nature of each change?

**Learnings:**
- What did we discover during this session?
- Root causes identified?
- Patterns or gotchas found?
- Important constraints discovered?

**Artifacts:**
- Which artifacts were created/updated?
- File paths for each

**Next Steps:**
- What should the next session do first?
- What was about to happen when we stopped?

**Open Issues:**
- Any blockers or problems?
- Tests failing?
- Decisions needed?
</identify_key_info>
</phase>

<phase name="write_handoff">
## Phase 3: Write Handoff Document

<create_directory>
```bash
mkdir -p .beads/artifacts/$1/handoffs
```
</create_directory>

<generate_filename>
Format: `YYYY-MM-DD_HH-MM-SS_handoff.md`

Get timestamp:
```bash
date +"%Y-%m-%d_%H-%M-%S"
```
</generate_filename>

<write_document>
Write to `.beads/artifacts/$1/handoffs/<timestamp>_handoff.md`:

```markdown
---
date: [ISO timestamp with timezone]
bead: $1
branch: [current branch]
git_commit: [current HEAD]
plan_phase: [which phase we're on]
status: [in_progress | blocked | ready_for_review]
---

# Handoff: $1

## Current Task
[What we were working on - be specific]
- Phase: [N] - [Phase Name]
- Status: [in_progress | complete | blocked]
- Step: [Which step within the phase]

## Critical References
[2-3 most important files/docs that must be read to continue]
- `.beads/artifacts/$1/plan.md` - Implementation plan (Phase N in progress)
- `path/to/key/file.ts` - Main file being modified

## Recent Changes
[Changes made this session - use file:line format]
- `src/auth/handler.ts:45-67` - Added retry logic for timeout handling
- `src/auth/handler.test.ts:23-45` - Tests for retry logic
- `src/types/auth.ts:12` - Added RetryConfig type

## Learnings
[Important discoveries - these prevent the next session from repeating work]
- The auth module uses a custom error type at `src/errors/auth.ts:15`
- Retry logic must respect the circuit breaker at `src/utils/circuit.ts:34`
- Found bug in error handling - created bd-xyz (discovered-from)

## Verification Status
[What's passing/failing]
- Build: [passing | failing]
- Tests: [X passing, Y failing]
- Lint: [clean | N warnings | N errors]

## Artifacts Updated
[What was created/modified this session]
- [x] `.beads/artifacts/$1/plan.md` - Phase 2 marked complete
- [x] `src/auth/handler.ts` - Implementation in progress
- [ ] `src/auth/handler.test.ts` - Tests not yet written

## Action Items (Next Session)
[Ordered list of what to do next]
1. [Most important next step]
2. [Second step]
3. [Third step]

## Blockers / Open Questions
[Anything that needs resolution]
- [Blocker or question, if any]
- [Or "None" if clear path forward]

## Commands to Resume
[Exact commands to get back to work]
```bash
# Resume from this handoff
/resume $1

# Or manually:
cd [worktree path if applicable]
git status
# Continue with Phase N, Step M
```
```
</write_document>
</phase>

<phase name="sync_and_report">
## Phase 4: Sync and Report

<sync_beads>
```bash
bd sync
```
</sync_beads>

<present_summary>
```
Handoff Created: $1
━━━━━━━━━━━━━━━━━━

Session State Captured
──────────────────────
Phase: [N] - [Name]
Progress: [X/Y steps complete]
Changes: [N files modified]

Handoff Document
────────────────
.beads/artifacts/$1/handoffs/<timestamp>_handoff.md

To Resume in New Session
────────────────────────
/resume $1

This will read the latest handoff and continue where you left off.
```
</present_summary>
</phase>

</workflow>

<ace_fca_alignment>
- **Frequent Intentional Compaction**: This IS the compaction mechanism
- **Artifacts over Memory**: State persisted to handoff document
- **Human as Orchestrator**: User decides when to create handoff
- **Session Continuity**: Fresh context can bootstrap from artifact
</ace_fca_alignment>

<constraints>
- Capture ALL essential state - don't lose important context
- Be CONCISE - filter noise, keep signal
- Use file:line references - vague descriptions are useless
- Include verification status - next session needs to know what's broken
- Order action items by priority - most important first
- Always sync after creating handoff
- Ground all learnings in actual code references
</constraints>
