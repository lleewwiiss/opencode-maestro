# Agent Guidelines (OpenCode)

## Project Overview
<!-- User: Describe your project so OpenCode agents can anchor responses. -->

## Preferred Libraries
<!-- List canonical libraries/frameworks to prevent hallucinated tech stacks. -->
- **State Management**: `[e.g. Zustand, Redux]`
- **Styling**: `[e.g. Tailwind, CSS Modules]`
- **Data Fetching**: `[e.g. TanStack Query, SWR]`
- **Testing**: `[e.g. Vitest, Jest, Playwright]`

## Build, Lint, Test Commands
<!-- If blank, agents must inspect package.json/Makefile. -->
- **Build**: `[Inspect package.json/Makefile]`
- **Test**: `[Inspect package.json/Makefile]`
- **Lint**: `[Inspect package.json/Makefile]`
- **Format**: `[Inspect package.json/Makefile]`

**IMPORTANT**
- Always run linting + type-check commands before claiming work complete.
- Do **not** use `// @ts-ignore` (or equivalents) unless explicitly authorized.

## Issue Tracking
**SOURCE OF TRUTH**: `bd` (Beads) *only*
- `bd ready --json` — find unblocked work
- `bd create "Task" -t bug|feature|task -p 0-4 --json` — new issues
- `bd update bd-42 --status in_progress --json` — claim work
- `bd close bd-42 --reason "Completed" --json` — finish work
- Commit `.beads/issues.jsonl` with any code change

**Types**: `bug`, `feature`, `task`, `epic`, `chore`  
**Priorities**: `0` (critical) → `4` (backlog)

## Agentic Workflow
- Follow [AGENTIC_WORKFLOW.md](./AGENTIC_WORKFLOW.md): Ideation → Research → Plan → Implement → Review → Land.
- Commands live under `.opencode/command/` (per <https://opencode.ai/docs/commands/>); Agents live under `.opencode/agent/` (per <https://opencode.ai/docs/agents/>).
- Commands run from repo root and can embed file references with `@path` plus shell snippets via `! command`.
- Set `subtask: true` for any command that should launch its own OpenCode child session (keeps Architect context clean).

### Slash Command Quick Reference
1. `/bd-create` → file the work
2. `/bd-next` → pick work
3. `/branchlet-from-bead` → isolate git state
4. `/context` → load artifacts
5. `/kb-build` → refresh knowledge base
6. `/research` → Researcher subagent
7. `/plan` → Planner (Oracle) subagent
8. `/implement` → Coder subagent
9. `/review` → validate plan vs. code
10. `/land-plane` → sync bd + git

### Rules
- **No TODO files**: track work only in Beads.
- **Slash-command lifecycle**: start a new OpenCode tab/thread per command to prevent context bleed.
- **Always run `bd sync` during `/land-plane`** so issue state matches git history.

## Code Style
- Mirror existing naming, lint rules, and directory conventions.
- Prefer explicit types (`never any/unknown` unless unavoidable).
- Comments describe **why** complex logic exists, not what each line does.
- Never commit secrets/keys.

### Anti-Slop
- **No Unrequested UI**: Don’t add tooltips/placeholders without a spec.
- **No Defensive Clutter**: Avoid blanket `try/catch`, `|| {}`, or default fallbacks that hide errors.
- **No Library Hallucinations**: Check `package.json` (or equivalent) before importing anything.
- **Preserve Fidelity**: When refactoring, keep strings/behavior identical unless the bead demands change.

## Testing & Verification
- Infer build/test commands early; record them in `.beads/artifacts/<bead-id>/plan.md`.
- Run targeted tests after every behavior change; run full suites before `/land-plane`.
- Prefer automated verification (unit/integration/e2e) over manual QA notes.
