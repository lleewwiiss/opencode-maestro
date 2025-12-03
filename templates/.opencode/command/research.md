---
description: Deep codebase research for a bead - explore, analyze, document findings
subtask: true
---
<context>
You are conducting comprehensive codebase research for a bead, aligned with ACE-FCA principles. This is a HIGH-LEVERAGE phase - bad research leads to bad plans leads to bad code.

Your context window will be automatically compacted as it approaches its limit. Therefore:
- Do not stop research early due to context concerns
- Save findings to research.md incrementally so you can continue after compaction
- Be persistent and thorough, even as context limit approaches
</context>

<claude4_guidance>
## Claude 4 Best Practices

<investigate_before_answering>
Never speculate about code you have not opened and read.
If the spec references a specific file or component, you MUST read it before drawing conclusions.
Be rigorous and persistent in searching code for key facts.
Give grounded, hallucination-free findings based on actual code inspection.
</investigate_before_answering>

<use_parallel_tool_calls>
When locating or reading multiple files, execute operations in parallel for efficiency.
For example: spawn multiple @codebase-locator subagents simultaneously for independent searches.
However, wait for locate results before spawning analyzers that depend on those results.
</use_parallel_tool_calls>

<ground_all_claims>
Every finding in research.md must include a file:line reference.
Do not make claims about code behavior without citing the specific location.
If you cannot find evidence for something, state that explicitly rather than guessing.
</ground_all_claims>
</claude4_guidance>

<goal>
Produce a thorough, accurate research.md that gives the planner everything needed to create a solid implementation plan.
</goal>

<bead_id>$1</bead_id>

<workflow>

<phase name="understand_ticket">
## Phase 1: Understand the Ticket

<read_all_context>
Read these files completely before spawning any subagents:

1. Bead metadata: `bd show $1 --json`
2. Spec (if exists): `.beads/artifacts/$1/spec.md`
3. Any linked tickets or parent beads

Extract:
- What problem are we solving?
- What are the acceptance criteria?
- What constraints exist?
- What's explicitly out of scope?
</read_all_context>
</phase>

<phase name="parallel_exploration">
## Phase 2: Parallel Exploration

<use_parallel_tool_calls>
Spawn multiple subagents in parallel for efficiency. Group by agent type within each phase:

**Phase 2a - Locate (parallel):**
- @codebase-locator: Find files related to [component A]
- @codebase-locator: Find files related to [component B]

**WAIT for all locators to complete.**

**Phase 2b - Find Patterns (parallel):**
- @codebase-pattern-finder: Find similar implementations to [feature]
- @codebase-pattern-finder: Find examples of [pattern] usage

**WAIT for all pattern-finders to complete.**

**Phase 2c - Analyze (parallel):**
- @codebase-analyzer: Analyze how [component A] works
- @codebase-analyzer: Analyze data flow in [component B]

**WAIT for all analyzers to complete.**
</use_parallel_tool_calls>

<sequencing_rules>
- Run agents of SAME TYPE in parallel within each phase
- Never mix agent types in parallel execution
- Each phase builds on previous: locate → patterns → analyze
- Each agent knows its job - just tell it WHAT to find, not HOW
</sequencing_rules>
</phase>

<phase name="synthesize">
## Phase 3: Synthesize Findings

<synthesis_approach>
After all subagents complete:

1. Compile findings from all sources
2. Prioritize live codebase over .beads/ historical docs
3. Connect patterns across components
4. Identify architectural decisions and constraints
5. Note any conflicts or uncertainties

Focus on WHAT the planner needs to know:
- Where is the relevant code? (file:line references)
- How does it currently work?
- What patterns should we follow?
- What constraints must we respect?
- What risks or edge cases exist?
</synthesis_approach>
</phase>

<phase name="document">
## Phase 4: Write Research Document

<gather_metadata>
Get metadata for frontmatter:
```bash
agentic metadata
```
</gather_metadata>

<document_structure>
Write to `.beads/artifacts/$1/research.md`:

```markdown
---
date: [ISO timestamp with timezone]
git_commit: [from metadata]
branch: [from metadata]
repository: [from metadata]
bead: $1
tags: [research, relevant-components]
---

## Ticket Synopsis
[What we're researching and why]

## Summary
[High-level findings - 3-5 bullet points answering the core question]

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
[Relevant insights from .beads/kb/ with references]

## Risks and Edge Cases
- [Potential issue 1]
- [Edge case to handle]

## Open Questions
[Any areas needing clarification - minimize these]
```
</document_structure>
</phase>

<phase name="present">
## Phase 5: Present and Handoff

<handoff>
Present concise summary to user:

```
Research Complete: $1
━━━━━━━━━━━━━━━━━━━━

Key Findings
────────────
- [Most important finding 1]
- [Most important finding 2]
- [Most important finding 3]

Artifact
────────
.beads/artifacts/$1/research.md

Next Step
─────────
Review research.md, then run:

  /plan $1
```
</handoff>
</phase>

</workflow>

<ace_fca_alignment>
- **Artifacts over Memory**: All findings persisted to research.md
- **Frequent Compaction**: Runs as subtask with fresh context
- **Parallel Efficiency**: Subagents explore in parallel by type
- **High-Leverage Review**: User reviews research before planning
</ace_fca_alignment>

<constraints>
- Read mentioned files FULLY before spawning subagents
- Follow the three-phase sequence: Locate → Patterns → Analyze
- Use parallel subagents OF THE SAME TYPE within each phase
- Always include file:line references for findings
- Minimize Open Questions - research should resolve uncertainties
- Never write research.md with placeholder values
- Do not speculate about code you haven't read
</constraints>
