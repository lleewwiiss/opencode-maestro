# OpenCode Agentic Workflow Protocol

This protocol mirrors the Amp Maestro loop but is tailored to OpenCode’s agent + command system. It relies on **Beads** for work tracking, **Branchlet** for isolated worktrees, and OpenCode’s **`.opencode/agent` + `.opencode/command`** scaffolding.

```mermaid
graph TD
    %% Dark friendly palette
    classDef default fill:#1f2933,stroke:#d1d5db,stroke-width:1px,color:#f8fafc;
    classDef decision fill:#7c3aed,color:#fff;
    classDef terminal fill:#0ea5e9,color:#fff;

    Start([Identify Work]):::terminal --> Ideate[/ /bd-create /]
    Ideate --> Backlog[Beads Backlog]

    Backlog --> Pick[/ /bd-next /]
    Pick --> Worktree[/ /branchlet-from-bead /]
    Worktree --> Context[/ /context / + Artifact Sync/]
    Context --> KB[/ /kb-build / (optional)]
    KB --> Research[/ /research / (Researcher Subagent)]
    Context --> Research
    Research --> Plan[/ /plan / (Planner Subagent)]
    Plan --> Complexity{Atomic?}:::decision
    Complexity -- No --> Split[/ /split /]
    Split --> Blocked[Parent Bead Blocked]
    Complexity -- Yes --> Implement[/ /implement / (Coder Subagent)]
    Implement --> Verify{Tests pass?}:::decision
    Verify -- No --> Implement
    Verify -- Yes --> Review[/ /review /]
    Review --> Land[/ /land-plane /]
    Land --> Cleanup[bd sync + git push]
```

## 1. Ideation & Triage
- Use `/bd-create` to interview, classify, and file work. Always enumerate `type`, `priority`, and lineage (`blocks`, `discovered-from`).  
- Result: A Bead ID plus seed artifacts under `.beads/artifacts/<slug>/`.

## 2. Setup & Context
1. Pick work via `/bd-next` (prioritize `bd ready --json` output).  
2. Spawn an isolated worktree with `/branchlet-from-bead <id>` (keeps git clean for concurrent agents).  
3. Run `/context <id>` to hydrate the Architect tab with the latest `research.md`, `plan.md`, `spec.md`, and session notes.  
4. Optional: `/kb-build` refreshes `.beads/kb/` so subagents can cite architecture references instead of rediscovering details.

## 3. Research & Spec
- `/spec <id>` (optional) formalizes acceptance criteria before deep work.  
- `/research <id>` launches the Researcher subagent (see [OpenCode Agents doc](https://opencode.ai/docs/agents/)): it runs as a **subtask** automatically, gathers context via `ls/rg/cat`, and persists facts to `.beads/artifacts/<id>/research.md`.  
- Always link the artifact back into the Bead description (`Context` block) and cite file paths/line numbers.

## 4. Planning
- `/plan <id>` invokes the Planner subagent (Oracle). It reads `research.md`, `spec.md`, and the bead metadata, then generates `.beads/artifacts/<id>/plan.md` with Context, Goals, Risks, Implementation Plan, and Test Plan sections.  
- Classify the plan: **Atomic** (<5 files / <5 steps) → continue; **Composite** → `/split` into child beads and block the parent.  
- Document inferred build/test commands in the plan if they were not previously captured.

## 5. Implementation
- `/implement <id>` spawns the Coder subagent (Gemini). Per [OpenCode command docs](https://opencode.ai/docs/commands/), commands run from repo root and inherit any `@file` references you embed in the template—use them liberally to keep prompts grounded.  
- Follow the plan step-by-step:
  - Operate one checklist item at a time, updating `plan.md` as steps complete.  
  - Run targeted tests after every behavior change (Use `npm test`, `go test ./...`, etc., whatever the plan recorded).  
  - Update artifacts if reality drifts (e.g., new constraints uncovered).  
- If changes cut across modules or new scope emerges, pause and either revise the plan or file a new bead (`bd create ... --deps discovered-from:<id>`).

## 6. Review & Merge
- `/review <id>` compares code vs. plan/spec and records findings (ideal for another subagent).  
- `/land-plane`:
  - Summarizes completed work, outstanding items, and recommended follow-ups.  
  - Runs `bd sync`, proposes commits (`type: subject` + `Refs <id>`), and requests approval before pushing.  
- Finish with `git push` + PR creation, then delete the worktree via `branchlet delete`.

## 7. Parallelism & Splits
- Treat large beads as managers:
  - Parent bead: owns master `research.md` + `plan.md`, never writes code.  
  - Child beads: single-scope tasks (UI component, migration, etc.) that unblock each other via `blocks` graph.  
  - `/split` documents dependencies explicitly so `/bd-next` surfaces the right order.  
- Multiple OpenCode tabs can target separate child beads simultaneously; just ensure each uses `/context` to reload artifacts before acting.

## 8. Context Hygiene (OpenCode Specific)
- **Primary vs. Subagent tabs**: Keep the Architect tab clean; every `/research`, `/plan`, `/implement`, `/review`, `/land-plane`, `/architect`, etc., should run with `subtask: true` so OpenCode automatically launches a **Child Session** (per the Agents doc).  
- **Prompt hygiene**: custom commands in `.opencode/command/*.md` can include `@path` references, shell snippets (`! command`), and metadata (`description`, `agent`, `subtask`). Use these to preload context rather than retyping instructions.  
- **Compaction**: Close Child Sessions once artifacts are updated; rely on files, not chat history, as the source of truth.

## Summary of Tools & Artifacts
| Purpose | Command | Agent | Artifact |
| --- | --- | --- | --- |
| Create bead | `/bd-create` | Architect | `.beads/artifacts/<id>/index.md` |
| Pick work | `/bd-next` | Architect | `.beads/issues.jsonl` |
| Worktree | `/branchlet-from-bead` | Architect | `<repo>/branchlet/<id>` |
| Knowledge base | `/kb-build` | Architect | `.beads/kb/*.md` |
| Research | `/research` | Researcher subagent | `.beads/artifacts/<id>/research.md` |
| Spec | `/spec` | Architect/Planner | `.beads/artifacts/<id>/spec.md` |
| Plan | `/plan` | Planner subagent | `.beads/artifacts/<id>/plan.md` |
| Implementation | `/implement` | Coder subagent | code + updated plan |
| Review | `/review` | Planner/Coder | `.beads/artifacts/<id>/review.md` |
| Land | `/land-plane` | Architect | git commits, `bd sync` |

**Key Practices**
- Always cite files/lines when writing `research.md` or `review.md`.  
- Never bypass `bd` for tracking; avoid ad-hoc TODO lists.  
- Update artifacts the moment a subagent learns something new; future sessions rely entirely on those files.  
- Before ending a session: run `/land-plane`, confirm `bd sync`, and ensure git is clean.  
- When in doubt about OpenCode capabilities (commands vs. agents vs. subtasks), refer back to the official docs:  
  - Commands: <https://opencode.ai/docs/commands/> (templates, descriptions, `@file` rules).  
  - Agents: <https://opencode.ai/docs/agents/> (primary vs. subagent modes, tool access, `subtask` semantics).
