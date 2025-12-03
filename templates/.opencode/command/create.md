---
description: Create a new bead with spec - interview, classify, create bead + spec.md
subtask: true
---
<context>
You are creating a new bead with a formal specification, aligned with ACE-FCA principles. Specs are high-leverage artifacts - "specs will become the real code."

Your job is to interview the user, understand the problem deeply, create the bead, and produce a spec.md that research can build on.
</context>

<claude4_guidance>
## Claude 4 Best Practices

<use_parallel_tool_calls>
When searching existing beads for dependencies, run bd commands in parallel where possible.
For example: `bd list --json` and `bd list --type epic --status open --json` can run simultaneously.
</use_parallel_tool_calls>

<be_explicit>
Generate specific, action-oriented titles - not vague descriptions.
Ask clarifying questions until you have concrete acceptance criteria.
A good spec has no ambiguity about what "done" looks like.
</be_explicit>

<default_to_action>
After user confirms the bead proposal, create it immediately.
Don't ask for additional confirmation - the approval was the green light.
</default_to_action>
</claude4_guidance>

<goal>
Create a well-structured bead AND spec.md that provides everything needed for the research phase.
</goal>

<workflow>

<phase name="interview">
## Phase 1: Problem Interview

Ask focused questions to understand the work:

**Opening**: "What problem are we solving? Or what feature are we building?"

**Follow-up questions** (ask 2-3 rounds):
- Is this a bug, feature, or technical debt?
- What's the expected behavior vs current behavior?
- Which parts of the system are involved?
- What are the acceptance criteria?
- What's explicitly OUT of scope?
- Are there any constraints or requirements?

**Goal**: Understand the PROBLEM, not just the name. Keep asking until you have clarity on:
- What success looks like
- What's in scope vs out of scope
- Key constraints
</phase>

<phase name="classify">
## Phase 2: Classify & Structure

Based on the interview:

**Type**: `bug`, `feature`, `task`, `epic`, or `chore`
**Priority**: `0` (critical) to `4` (low) based on urgency/impact
**Title**: Generate concise, action-oriented title (don't ask user)

**Template Selection**:
- `epic` - Large features requiring breakdown (will have child beads)
- `feature` - New functionality
- `bug` - Defect fix

Example: "Implement retry logic for API client timeouts"
</phase>

<phase name="dependencies">
## Phase 3: Find Dependencies & Parent

Search existing beads:
```bash
bd list --json
bd list --type epic --status open --json  # Find parent epics
```

Identify relationships:
- Parent epic? → `--parent bd-xxx` (child gets hierarchical ID like `bd-xxx.1`)
- Blocks another bead? → `--deps blocks:bd-xxx`
- Discovered while working on? → `--deps discovered-from:bd-xxx`
- Related to? → `--deps related:bd-xxx`

**Hierarchical IDs** (for work breakdown):
```
bd-a1b2      [epic] Auth System
bd-a1b2.1    [task] Design login UI  
bd-a1b2.2    [task] Backend validation
bd-a1b2.3    [epic] Password Reset (sub-epic)
bd-a1b2.3.1  [task] Email templates
```

Explain proposed lineage to user.
</phase>

<phase name="create_bead">
## Phase 4: Create Bead

Propose the bead:
```
I propose creating:

Title: [generated title]
Type: [type]
Priority: [0-4]
Template: [epic|feature|bug if applicable]
Parent: [parent bead if child task]
Dependencies: [list or none]

Approve? (yes/modify)
```

On approval, execute using templates where appropriate:

**For epics:**
```bash
bd create --from-template epic "<title>" --priority <n> --description "<brief>"
```

**For features:**
```bash
bd create --from-template feature "<title>" --priority <n> --description "<brief>" [--parent <id>]
```

**For bugs:**
```bash
bd create --from-template bug "<title>" --priority <n> --description "<brief>"
```

**For tasks (children of epics):**
```bash
bd create "<title>" --type task --priority <n> --description "<brief>" --parent <epic-id>
```
Note: Child tasks get hierarchical IDs automatically (e.g., `bd-a1b2.1`, `bd-a1b2.2`)

Capture the returned bead ID.
</phase>

<phase name="create_spec">
## Phase 5: Create Spec

Create the artifacts directory and spec.md:

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
status: specced
---

# <Title>

## Problem Statement
[Clear description of the problem we're solving]

## Context
[Background, why this matters, business impact]

## Requirements

### Functional Requirements
- [Specific requirement 1]
- [Specific requirement 2]

### Non-Functional Requirements
- [Performance, security, scalability needs]

## Scope

### In Scope
- [What we ARE doing]

### Out of Scope
- [What we are NOT doing - prevents scope creep]

## Success Criteria
- [How we know this is done]
- [Measurable outcomes]

## Constraints
- [Technical constraints]
- [Dependencies on other work]

## Open Questions
- [Any unresolved questions for research to answer]
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

Artifacts Created:
  .beads/artifacts/<bead-id>/spec.md

Next Step:
  /start <bead-id>

This will setup your workspace and begin research.
```
</phase>

</workflow>

<constraints>
- Always interview before creating - understand the problem
- Generate title yourself - don't ask user
- Confirm with user before creating bead
- Always create spec.md after bead creation
- Keep spec focused - research will expand on it
</constraints>
