---
description: Finish work on a bead - review, commit, sync, and push
subtask: true
---
<context>
You are completing a work session on a bead. Your job is to validate the implementation, create atomic commits, sync bead state, and prepare for PR/merge.

This is a high-leverage review point - catch issues before they reach the PR.
</context>

<claude4_guidance>
- Run verification commands (build, test, lint) in parallel
- Read plan.md and verify each phase was actually completed
- Check git diff against planned changes - ensure no unplanned modifications
- Once verification passes, proceed with commits without asking for additional confirmation
</claude4_guidance>

<goal>
Bring work to clean completion: validate against plan, commit atomically, sync beads, push, report next steps.
</goal>

<bead_id>$1</bead_id>

<workflow>

<phase name="detect_bead">
## Phase 1: Identify Bead

If bead ID provided in arguments, use it. Otherwise, detect from branch name:

```bash
git branch --show-current
```

Parse bead ID from branch (e.g., `feature/bd-xxx-slug` → `bd-xxx`).

Determine if child or parent bead:
- **Child bead** (ID contains `.`): Will close this child, check siblings
- **Parent bead**: Check for children with `bd list --parent $BEAD_ID --json`
</phase>

<phase name="review">
## Phase 2: Review Implementation

<mandatory_verification_gate>
**MANDATORY GATE - Run BEFORE any commits:**

```bash
npm run build  # or cargo build, go build, etc.
npm test       # or cargo test, pytest, go test, etc.
npm run lint   # or cargo clippy, ruff, golangci-lint, etc.
```

**BLOCKER**: If ANY of these fail:
- DO NOT proceed to commits
- DO NOT close the bead
- Report failures to user
- Return to /implement to fix issues
</mandatory_verification_gate>

Only after gate passes, gather review context:

1. **Load plan**: Read `.beads/artifacts/$BEAD_ID/plan.md`
2. **Get changes**: `git diff --stat` and `git diff --name-only`
3. **Verify tests written**: Check plan's Testing Strategy is complete

For each phase in the plan, verify:
- [ ] Phase marked complete matches actual changes
- [ ] Files modified align with plan
- [ ] No unplanned changes introduced
- [ ] All planned tests are written and passing

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
- [x] Tests pass (X total, Y new)
- [x] Lint clean (or N warnings)

### Files Changed
| File | Changes | Planned? |
|------|---------|----------|
| `src/file.ts` | Added handler | Yes |
| `src/util.ts` | Refactored | No - see deviations |

### Deviations from Plan
- **Phase 2**: Used different approach for X because [reason]
- **Assessment**: Deviation is justified / needs discussion

### Test Coverage
- [x] All planned tests written
- [x] Happy path covered
- [x] Edge cases covered
- [ ] Error paths covered (partial)

### Manual Testing Required
- [ ] [Items from plan's manual verification section]

### Recommendations
- [Any follow-up items or tech debt noted]
```
</review_artifact>
</phase>

<phase name="commit">
## Phase 3: Create Atomic Commits

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

Proceed? (yes / modify / skip)
```

Execute on approval:
```bash
git add [specific files]
git commit -m "type(scope): description

Refs: $BEAD_ID"
```
</phase>

<phase name="sync">
## Phase 4: Sync Beads

**RULE**: A bead can ONLY be closed if build passes, ALL tests pass, and lint passes.

<child_bead_close>
**If child bead (e.g., bd-xxx.2):**

1. Close THIS child bead:
```bash
bd close $BEAD_ID --reason "Phase complete - tests passing"
```

2. **Update parent plan.md** (critical for continuity):
   - Read parent's `.beads/artifacts/[parent-id]/plan.md`
   - Find the phase corresponding to this child bead
   - Update its status to `[x] Complete` with completion timestamp
   - This keeps parent plan as single source of truth for phase status

3. Check sibling status:
```bash
bd list --parent [parent-id] --json
```

4. Report sibling status and guide to next open sibling or parent close
</child_bead_close>

<parent_bead_close>
**If parent bead:**

1. Check for children: `bd list --parent $BEAD_ID --json`
2. If children exist, verify ALL are closed before closing parent
3. If all children closed OR no children, close parent:
```bash
bd close $BEAD_ID --reason "All phases complete - tests passing"
```
</parent_bead_close>

Sync bead state:
```bash
bd sync
```
</phase>

<phase name="push">
## Phase 5: Push and Report

Push branch:
```bash
git push -u origin HEAD
```

Present summary:

```
Session Complete: $BEAD_ID
━━━━━━━━━━━━━━━━━━━━━━━━━━

Commits: [list with hashes]
Bead Status: closed
Verification: Build ✓ | Tests ✓ | Lint ✓
Branch: Pushed to origin/[branch]

Next Steps:
1. Create PR: gh pr create --title "[type]: [title]" --body "Refs: $BEAD_ID"
2. After merge: delete the feature branch
```

For child beads, also show sibling status and guide to next phase.
</phase>

</workflow>

<constraints>
- Never push without showing what will be pushed
- Never close bead without confirming work is complete
- Always create review.md artifact
- Reference bead ID in all commits
- **HARD BLOCKER**: If tests fail, STOP - do not commit, do not close bead
- **HARD BLOCKER**: If lint fails, STOP - do not commit, do not close bead
- **HIERARCHY RULE**: Parent bead cannot close until ALL children are closed
</constraints>
