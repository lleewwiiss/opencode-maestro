---
description: Finish work on a bead - coach review, commit, sync, and push
---
<context>
You are completing a work session on a bead. Your job is to:
1. Run adversarial coach review against original requirements
2. Validate the implementation passes all verification gates
3. Create atomic commits and sync bead state

This command implements the "coach" role from dialectical autocoding - independent validation that doesn't trust the implementing agent's self-report of success.
</context>

<investigate_before_finishing>
Read ALL relevant artifacts before any assessment. You MUST:
1. Read spec.md to understand original requirements
2. Read plan.md to verify each phase was completed
3. Check git diff against planned changes
4. Run verification commands (build, test, lint)

Do not trust claims of completion. Verify independently.
</investigate_before_finishing>

<use_parallel_tool_calls>
Run verification commands (build, test, lint) in parallel. Read multiple artifacts in parallel. Once verification passes, proceed with commits without asking for additional confirmation.
</use_parallel_tool_calls>

<default_to_action>
After coach approval, proceed directly with commits. Do not re-ask for confirmation on already-approved work.
</default_to_action>

<goal>
Bring work to clean completion: validate against plan, commit atomically, sync beads, push, report next steps.
</goal>

<principles>
- **Fix Broken Windows**: Don't leave bad code, poor designs, or tech debt unflagged. Note issues even if not fixing now.
- **Good Enough Software**: Know when to stop. Perfect is the enemy of deployed. Ship when requirements are met.
- **Code should be obvious**: During review, if code requires explanation, it may need rewriting not just commenting.
- **Consistency**: Similar things should be done in similar ways. Flag inconsistencies with existing patterns.
- **Surface-level improvements matter**: Naming, formatting, and organization significantly impact maintainability.
- **High-leverage review point**: Catch issues before they reach PR. Deviations aren't bad but must be noted.
- **Artifacts over Memory**: Document findings in review.md. The artifact persists; context doesn't.
</principles>

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

<phase name="coach_review">
## Phase 2: Adversarial Coach Review

This phase implements independent validation from Block's dialectical autocoding research. The key insight: "Discard the implementing agent's self-report of success and have the coach perform an independent evaluation."

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

<requirements_compliance_check>
**After verification passes, validate against ORIGINAL requirements:**

1. **Read spec.md completely** - This is your evaluation anchor
2. **For EACH requirement in spec.md**, verify independently:
   - Functional requirements: implemented with file:line evidence
   - Non-functional requirements: met with evidence
   - Success criteria: verified (how?)
   - Out of scope items: correctly omitted

```
**REQUIREMENTS COMPLIANCE:**
- [ ] Requirement 1: [PASS/FAIL] - [evidence with file:line]
- [ ] Requirement 2: [PASS/FAIL] - [evidence with file:line]
...
```

**BLOCKER**: If any requirement from spec.md is NOT met:
- DO NOT proceed to commits
- Report gaps with specific remediation steps
- Return to /implement to address gaps
</requirements_compliance_check>

Only after BOTH gates pass, gather review context:

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
reviewer: ai-coach (adversarial)
verdict: [APPROVED / NOT_APPROVED]
---

## Coach Review

### Requirements Compliance (from spec.md)
| Requirement | Status | Evidence |
|-------------|--------|----------|
| [Req 1] | ✅ PASS | `file.ts:45` |
| [Req 2] | ✅ PASS | `handler.ts:23` |

### Automated Verification
- [x] Build passes
- [x] Tests pass (X total, Y new)
- [x] Lint clean (or N warnings)

### Status by Phase
| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1 | Complete | Matches plan |
| Phase 2 | Complete | Minor deviation (see below) |

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

### Coach Verdict
🎯 **APPROVED** - All requirements from spec.md verified. Implementation meets the requirements contract.

(or)

⚠️ **NOT APPROVED** - [X] gaps identified. Return to /implement.
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
- Never close bead without COACH APPROVAL (requirements compliance verified)
- Always create review.md artifact with coach verdict
- Reference bead ID in all commits
- **HARD BLOCKER**: If tests fail, STOP - do not commit, do not close bead
- **HARD BLOCKER**: If lint fails, STOP - do not commit, do not close bead
- **HARD BLOCKER**: If ANY requirement from spec.md is not met, STOP - return to /implement
- **HIERARCHY RULE**: Parent bead cannot close until ALL children are closed
- **ADVERSARIAL PRINCIPLE**: Do not trust self-reports of completion. Verify independently against spec.md.
</constraints>
