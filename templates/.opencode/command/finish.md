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

<detect_hierarchy>
Determine if this is a child or parent bead:

**Child bead** (ID contains `.`, e.g., `bd-xxx.2`):
- This is Phase 2 of parent `bd-xxx`
- Will close this child, check siblings
- Parent stays open until all children closed

**Parent bead**:
- Check for children: `bd list --parent $BEAD_ID --json`
- If children exist, verify all are closed before closing parent
- If no children, close normally
</detect_hierarchy>
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

**If verification gate failed:**
```bash
# Keep bead open - do NOT close
bd update $BEAD_ID --status in_progress
# Return to /implement to fix issues
```

**RULE**: A bead can ONLY be closed if:
- Build passes
- ALL tests pass
- Lint passes (if present)
</bead_state_update>

<child_bead_close>
**If child bead (e.g., bd-xxx.2):**

1. Close THIS child bead:
```bash
bd close $BEAD_ID --reason "Phase 2 complete - tests passing"
```

2. Check sibling status:
```bash
bd list --parent [parent-id] --json
```

3. Report sibling status:
```
Child Bead Closed: $BEAD_ID
───────────────────────────

Sibling Status:
  [parent].1 - Phase 1: closed ✓
  [parent].2 - Phase 2: closed ✓  ← just closed
  [parent].3 - Phase 3: open

[If all siblings closed]:
All phases complete! Close parent with:
  /finish [parent-id]

[If siblings remain open]:
Next phase:
  /start [parent].3
  /implement [parent].3
```

4. Update parent's plan.md with child status:
```markdown
## Child Beads
| Phase | Bead ID | Status |
|-------|---------|--------|
| Phase 1 | bd-xxx.1 | closed ✓ |
| Phase 2 | bd-xxx.2 | closed ✓ |
| Phase 3 | bd-xxx.3 | open |
```
</child_bead_close>

<parent_bead_close>
**If parent bead:**

1. Check for children:
```bash
bd list --parent $BEAD_ID --json
```

2. **If children exist**, verify ALL are closed:
```
Parent bead has children:
  $BEAD_ID.1 - [closed/open]
  $BEAD_ID.2 - [closed/open]
  $BEAD_ID.3 - [closed/open]

[If any open]:
⛔ Cannot close parent - children still open:
  - $BEAD_ID.3 is still open

Complete remaining children first:
  /implement $BEAD_ID.3
  /finish $BEAD_ID.3

[If all closed]:
All children complete. Closing parent bead.
```

3. **If all children closed OR no children**, close parent:
```bash
bd close $BEAD_ID --reason "All phases complete - tests passing"
```
</parent_bead_close>

<sync_state>
Sync bead state:
```bash
bd sync
```
</sync_state>

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

**For child bead**, present:

```
Phase Complete: $BEAD_ID
━━━━━━━━━━━━━━━━━━━━━━━━

Commits
───────
[hash] feat($BEAD_ID): [phase description]
[hash] test($BEAD_ID): add tests for [phase]

Bead Status
───────────
$BEAD_ID: closed ✓

Parent: [parent-id]
Siblings:
  [parent].1 - closed ✓
  [parent].2 - closed ✓  ← this one
  [parent].3 - open

Branch  
──────
Pushed to: origin/[branch]

Next Steps
──────────
[If siblings remain]:
1. Continue with next phase:
   /start [parent].3
   /implement [parent].3

[If all siblings done]:
1. Close parent: /finish [parent-id]
2. Create PR: gh pr create --title "[type]: [title]" --body "Refs: [parent-id]"
```

**For parent bead (standalone or all children done)**, present:

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
[If had children]: All child beads closed
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
- **HIERARCHY RULE**: Parent bead cannot close until ALL children are closed
- **HIERARCHY RULE**: When closing child, always report sibling status
- **HIERARCHY RULE**: Guide user to next open sibling after closing child
</constraints>
