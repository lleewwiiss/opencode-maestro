---
description: Finish work on a bead - review, commit, sync, and push
subtask: true
---
<context>
You are completing a work session on a bead, aligned with ACE-FCA principles. Your job is to validate the implementation, create atomic commits, sync bead state, and prepare for PR/merge.

This is a high-leverage review point - catch issues before they reach the PR.
</context>

<claude4_guidance>
## Claude 4 Best Practices

<use_parallel_tool_calls>
Run verification commands (build, test, lint) in parallel where the system supports it.
Gather review context in parallel: read plan.md, run git diff, check test results simultaneously.
</use_parallel_tool_calls>

<investigate_before_committing>
Read the plan.md and verify each phase was actually completed.
Check git diff against planned changes - ensure no unplanned modifications.
Do not commit without verifying tests actually pass.
</investigate_before_committing>

<default_to_action>
Once verification passes, proceed with commits without asking for additional confirmation.
The gate is the test/lint pass - if that passes, action is approved.
</default_to_action>
</claude4_guidance>

<goal>
Bring work to clean completion: validate against plan, commit atomically, sync beads, push, report next steps.
</goal>

<bead_id>$1</bead_id>

<workflow>

<phase name="detect_bead">
## Phase 1: Identify Bead

<detection_strategy>
If bead ID provided in arguments, use it.
Otherwise, detect from branch name:

```bash
git branch --show-current
```

Parse bead ID from branch (e.g., `branchlet/bd-xxx-slug` → `bd-xxx`).

Validate bead exists:
```bash
bd show [detected-id] --json
```
</detection_strategy>
</phase>

<phase name="review">
## Phase 2: Review Implementation

<mandatory_verification_gate>
**MANDATORY GATE - Run BEFORE any commits:**

```bash
# 1. Build (MUST PASS)
npm run build  # or cargo build, go build, make build, etc.

# 2. ALL Tests (MUST PASS)
npm test       # or cargo test, pytest, go test ./..., etc.

# 3. Lint (MUST PASS if present)
npm run lint   # or cargo clippy, ruff check, golangci-lint, etc.
```

**BLOCKER**: If ANY of these fail:
- DO NOT proceed to commits
- DO NOT close the bead
- Report failures to user
- Return to /implement to fix issues

```
⛔ FINISH BLOCKED
─────────────────
Tests: FAILED (3 failures)
Lint: PASSED

Cannot complete bead until tests pass.
Run /implement $BEAD_ID to fix failing tests.
```
</mandatory_verification_gate>

<parallel_review>
Only after gate passes, gather review context:

1. **Load plan**: Read `.beads/artifacts/$BEAD_ID/plan.md`
2. **Get changes**: `git diff --stat` and `git diff --name-only`
3. **Verify tests written**: Check plan's "Testing Strategy" is complete
</parallel_review>

<validation_checklist>
For each phase in the plan:

- [ ] Phase marked complete matches actual changes
- [ ] Files modified align with plan
- [ ] Success criteria (automated) pass
- [ ] No unplanned changes introduced
- [ ] All planned tests are written and passing

Document deviations - they're not always bad, but must be noted.
</validation_checklist>

<review_artifact>
Write findings to `.beads/artifacts/$BEAD_ID/review.md`:

```markdown
---
date: [ISO timestamp]
bead: $BEAD_ID
reviewer: ai-automated
---

## Implementation Review

### Status by Phase
| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1 | Complete | Matches plan |
| Phase 2 | Complete | Minor deviation (see below) |

### Automated Verification
- [x] Build passes
- [x] Tests pass  
- [ ] Lint: 2 warnings (non-blocking)

### Deviations from Plan
- **Phase 2**: Used different approach for X because [reason]
- **Assessment**: Deviation is justified / needs discussion

### Manual Testing Required
- [ ] [Items from plan's manual verification section]

### Recommendations
- [Any follow-up items]
```
</review_artifact>
</phase>

<phase name="commit">
## Phase 3: Create Atomic Commits

<commit_strategy>
Analyze changes and group into logical commits:

```bash
git diff --name-only
git status -sb
```

Propose commits following conventional format:

```
Proposed commits:

1. feat($BEAD_ID): [description of feature]
   Files: [list]

2. test($BEAD_ID): add tests for [feature]
   Files: [list]

3. docs(beads): update artifacts
   Files: .beads/artifacts/$BEAD_ID/*

Proceed? (yes / modify / skip)
```

Execute on approval:
```bash
git add [specific files]
git commit -m "type(scope): description

Refs: $BEAD_ID"
```

Show result:
```bash
git log --oneline -n 3
```
</commit_strategy>
</phase>

<phase name="sync">
## Phase 4: Sync Beads

<bead_state_update>
Update bead status based on completion:

**Only if verification gate passed:**
```bash
# Close bead (only if tests + lint passed!)
bd close $BEAD_ID --reason "Implementation complete - tests passing"
```

**If verification gate failed:**
```bash
# Keep bead open - do NOT close
bd update $BEAD_ID --status in_progress
# Return to /implement to fix issues
```

Sync bead state:
```bash
bd sync
```

**RULE**: A bead can ONLY be closed if:
- Build passes
- ALL tests pass
- Lint passes (if present)
</bead_state_update>

<memory_decay>
**Memory Decay (Optional)**

For long-running projects, check for compaction candidates:
```bash
bd compact --analyze --json
```

This returns issues closed 30+ days ago that can be compacted.
Agent-driven compaction workflow:
1. `bd compact --analyze --json` → get candidates with full content
2. Summarize the content (using any LLM)
3. `bd compact --apply --id <bead-id> --summary summary.txt` → persist

This is "agentic memory decay" - preserves essential context while reducing noise.
</memory_decay>
</phase>

<phase name="push">
## Phase 5: Push and Report

<push_and_report>
Push branch:
```bash
git push -u origin HEAD
```

Present completion summary:

```
Session Complete: $BEAD_ID
━━━━━━━━━━━━━━━━━━━━━━━━━━

Commits
───────
[hash] type(scope): description
[hash] type(scope): description

Bead Status
───────────
Status: closed
Artifacts: review.md updated

Branch  
──────
Pushed to: origin/[branch]

Next Steps
──────────
1. Create PR: gh pr create --title "[type]: [title]" --body "Refs: $BEAD_ID"
2. Request review
3. After merge: branchlet delete $BEAD_ID

Follow-up Beads (if any)
────────────────────────
- [Any discovered work → new beads]
```
</push_and_report>
</phase>

</workflow>

<ace_fca_alignment>
- **Artifacts over Memory**: Review documented in review.md
- **High-Leverage Review**: Deviations highlighted before commit
- **Frequent Compaction**: Runs as subtask, clean context
- **Human as Orchestrator**: User approves commits before execution
</ace_fca_alignment>

<constraints>
- Never push without showing what will be pushed
- Never close bead without confirming work is complete
- Always create review.md artifact  
- Reference bead ID in all commits
- **HARD BLOCKER**: If tests fail, STOP - do not commit, do not close bead
- **HARD BLOCKER**: If lint fails, STOP - do not commit, do not close bead
- If significant deviations found, ask user before proceeding
- A bead CANNOT be closed until: build passes, ALL tests pass, lint passes
- No exceptions to the test/lint gate - broken code never gets committed
</constraints>
