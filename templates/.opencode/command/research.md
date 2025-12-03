---
description: Deep codebase research for a bead - explore, analyze, document findings
subtask: true
---
<context>
You are conducting comprehensive codebase research for a bead. This is a HIGH-LEVERAGE phase - bad research leads to bad plans leads to bad code.

Save findings to research.md incrementally as context approaches limit.
</context>

<claude4_guidance>
<investigate_before_answering>
Never speculate about code you have not opened and read. If the spec references a specific file or component, you MUST read it before drawing conclusions. Be rigorous and persistent in searching code for key facts. Give grounded, hallucination-free findings based on actual code inspection.
</investigate_before_answering>

<use_parallel_tool_calls>
When locating or reading multiple files, execute operations in parallel for efficiency. Spawn multiple @codebase-locator subagents simultaneously for independent searches. Wait for locate results before spawning analyzers that depend on those results.
</use_parallel_tool_calls>

<ground_all_claims>
Every finding in research.md must include a file:line reference. Do not make claims about code behavior without citing the specific location. If you cannot find evidence, state that explicitly rather than guessing.
</ground_all_claims>
</claude4_guidance>

<goal>
Produce a thorough, accurate research.md that gives the planner everything needed to create a solid implementation plan.
</goal>

<bead_id>$1</bead_id>

<workflow>

<phase name="understand_ticket">
## Phase 1: Understand the Ticket

Read these files completely before spawning any subagents:

1. Bead metadata: `bd show $1 --json`
2. Spec (if exists): `.beads/artifacts/$1/spec.md`
3. Any linked tickets or parent beads

Extract: What problem are we solving? What are acceptance criteria? What's out of scope?
</phase>

<phase name="parallel_exploration">
## Phase 2: Parallel Exploration

Spawn multiple subagents in parallel, grouped by type:

**Phase 2a - Locate (parallel):**
- @codebase-locator: Find files related to [component A]
- @codebase-locator: Find files related to [component B]

**WAIT for all locators to complete.**

**Phase 2b - Find Patterns (parallel):**
- @codebase-pattern-finder: Find similar implementations
- @codebase-pattern-finder: Find examples of [pattern] usage

**WAIT for all pattern-finders to complete.**

**Phase 2c - Analyze (parallel):**
- @codebase-analyzer: Analyze how [component A] works
- @codebase-analyzer: Analyze data flow in [component B]

**WAIT for all analyzers to complete.**

Sequencing: locate → patterns → analyze. Each phase builds on previous.
</phase>

<phase name="synthesize">
## Phase 3: Synthesize Findings

After all subagents complete:
1. Compile findings from all sources
2. Prioritize live codebase over historical docs
3. Connect patterns across components
4. Identify architectural decisions and constraints
5. Note any conflicts or uncertainties

Focus on WHAT the planner needs: Where is the code? How does it work? What patterns to follow? What constraints? What risks?
</phase>

<phase name="document">
## Phase 4: Write Research Document

<gather_metadata>
Get metadata for frontmatter:
```bash
agentic metadata
```

Also capture git state:
```bash
git rev-parse HEAD
git branch --show-current
git remote get-url origin
```
</gather_metadata>

Write to `.beads/artifacts/$1/research.md`:

```markdown
---
date: [ISO timestamp with timezone]
git_commit: [from git rev-parse HEAD]
branch: [from git branch --show-current]
repository: [from git remote get-url origin]
bead: $1
tags: [research, relevant-components]
---

## Ticket Synopsis
[What we're researching and why]

## Summary
[3-5 bullet points answering the core question]

## Detailed Findings

### [Component/Area 1]
**Location**: `path/to/file.ts:123-145`
**Purpose**: [What this code does]
**Key Details**:
- [Finding with file:line reference]
- [Connection to other components]
- [Implementation pattern used]

### [Component/Area 2]
[Same structure...]

## Code References
| File | Lines | Description |
|------|-------|-------------|
| `path/to/file.ts` | 123-145 | Main handler |
| `path/to/other.ts` | 45-67 | Data model |

## Architecture Insights
[Patterns, conventions, design decisions discovered]

## Historical Context
[Relevant insights from prior artifacts or related beads with references]

## Risks and Edge Cases
- [Potential issue 1]
- [Edge case to handle]

## Open Questions
[Minimize these - research should resolve uncertainties]
```
</phase>

<phase name="present">
## Phase 5: Present and Handoff

```
Research Complete: $1
━━━━━━━━━━━━━━━━━━━━

Key Findings:
- [Most important finding 1]
- [Most important finding 2]
- [Most important finding 3]

Artifact: .beads/artifacts/$1/research.md

Next Step: Review research.md, then run /plan $1
```
</phase>

</workflow>

<constraints>
- Read mentioned files FULLY before spawning subagents
- Follow sequence: Locate → Patterns → Analyze
- Always include file:line references
- Minimize Open Questions - research should resolve uncertainties
- Do not speculate about code you haven't read
</constraints>
