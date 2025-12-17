---
description: Create a new bead with spec - interview, classify, create bead + spec.md
---
<context>
You are creating a new bead with a formal specification. Specs are high-leverage artifacts - "specs will become the real code."

Your job is to interview the user, understand the problem deeply, create the bead, and produce a spec.md. A well-written spec prevents hundreds of lines of bad code by catching misunderstandings early.
</context>

<interview_technique>
Generate specific, action-oriented titles - not vague descriptions. Ask clarifying questions until you have concrete acceptance criteria. Focus on:
- What problem are we solving? (not what feature are we building)
- What does "done" look like? (acceptance criteria)
- What is explicitly OUT of scope? (prevents scope creep)

Bad title: "Improve authentication"
Good title: "Add JWT refresh token rotation with 7-day expiry"
</interview_technique>

<default_to_action>
After user confirms bead details, create immediately - don't re-ask. Proceed directly to creating spec.md without additional confirmation rounds.
</default_to_action>

<avoid_overengineering>
Specs should capture actual requirements, not hypothetical future needs. If the user says "just a simple X", don't add complexity they didn't ask for.
</avoid_overengineering>

<goal>
Create a well-structured bead AND spec.md that provides everything needed for the research phase.
</goal>

<workflow>

<phase name="interview">
## Phase 1: Problem Interview

Ask focused questions:

**Opening**: "What problem are we solving? Or what feature are we building?"

**Follow-up questions** (2-3 rounds):
- Is this a bug, feature, or technical debt?
- What's the expected vs current behavior?
- What are the acceptance criteria?
- What's explicitly OUT of scope?

Goal: Understand the PROBLEM. Keep asking until you have clarity on success criteria, scope, and constraints.
</phase>

<phase name="classify">
## Phase 2: Classify & Structure

Based on the interview:

**Type**: `bug`, `feature`, `task`, `epic`, or `chore`
**Priority**: `0` (critical) to `4` (low)
**Title**: Generate concise, action-oriented title (don't ask user)
**Template**: epic, feature, or bug
</phase>

<phase name="dependencies">
## Phase 3: Find Dependencies & Parent

Search existing beads:
```bash
bd list --json
bd list --type epic --status open --json
```

Identify relationships:
- Parent epic? → `--parent bd-xxx`
- Blocks another? → `--deps blocks:bd-xxx`
- Discovered while working on? → `--deps discovered-from:bd-xxx`
</phase>

<phase name="create_bead">
## Phase 4: Create Bead

Propose:
```
I propose creating:

Title: [generated title]
Type: [type]
Priority: [0-4]
Parent: [if applicable]

Approve? (yes/modify)
```

On approval:
```bash
bd create --from-template [template] "<title>" --priority <n> --description "<brief>" [--parent <id>]
```

Capture the returned bead ID.
</phase>

<phase name="create_spec">
## Phase 5: Create Spec

```bash
mkdir -p .beads/artifacts/<bead-id>
```

Write `.beads/artifacts/<bead-id>/spec.md`:

```markdown
---
bead: <bead-id>
title: <title>
type: <type>
priority: <priority>
created: <ISO timestamp>
---

# <Title>

## Problem Statement
[Clear description]

## Requirements
### Functional Requirements
- [Requirement 1]

### Non-Functional Requirements
- [Performance, security needs]

## Scope
### In Scope
- [What we ARE doing]

### Out of Scope
- [What we are NOT doing]

## Success Criteria
- [How we know this is done]

## Open Questions
- [Unresolved questions for research]
```
</phase>

<phase name="next_steps">
## Phase 6: Report & Next Steps

```
Bead Created: <bead-id>
━━━━━━━━━━━━━━━━━━━━━━

Title: <title>
Type: <type>
Priority: <priority>

Artifact: .beads/artifacts/<bead-id>/spec.md

Next Step: /start <bead-id>
```
</phase>

</workflow>

<constraints>
- Always interview before creating - understand the problem
- Generate title yourself - don't ask user
- Confirm with user before creating bead
- Always create spec.md after bead creation
- **ARTIFACTS ARE LOCAL-ONLY**: `.beads/artifacts/` should be in `.gitignore`, never committed
</constraints>
