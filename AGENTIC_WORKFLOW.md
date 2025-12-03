# Agentic Workflow Protocol

Aligned with:
- [ACE-FCA](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents) - Frequent Intentional Compaction
- [Claude 4 Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices) - Explicit instructions, parallel tools, investigate before acting

**Tools**: Beads (bd CLI) + Branchlet (worktrees) + OpenCode (commands + subagents)

---

## Core Principles (ACE-FCA)

> "A bad line of code is a bad line of code. But a bad line of a **plan** could lead to hundreds of bad lines of code. And a bad line of **research** could land you with thousands of bad lines of code."

1. **Human as Orchestrator** - You drive; agents execute
2. **Frequent Intentional Compaction** - Each phase is fresh context (subtask)
3. **Artifacts over Memory** - Persist to `.beads/artifacts/` (specs, research, plans)
4. **High-Leverage Human Review** - Review research and plans, not just code
5. **Research → Plan → Implement** - Mandatory sequence

---

## The 9-Command Workflow

```
/create                   →  Interview → bead + spec.md (uses templates)
      ↓
/start [bead-id]          →  bd ready → setup workspace → load context
      ↓
/research <bead-id>       →  Explore codebase → research.md
      ↓
   [Review research.md]   ←  HIGH LEVERAGE
      ↓
/plan <bead-id>           →  Create plan + testing strategy → plan.md
      ↓
   [Review plan.md]       ←  HIGH LEVERAGE
      ↓
/iterate <bead-id>        →  Update plan based on feedback (optional)
      ↓
/implement <bead-id>      →  Execute plan + write tests (discovered-from for new issues)
      ↓
   [Tests + Lint MUST pass] ← HARD GATE
      ↓
/finish                   →  Verify gate → commit + sync + (optional: bd compact)

Session Continuity (use anytime):
──────────────────────────────────
/handoff <bead-id>        →  Create handoff document (context approaching limit)
/resume <bead-id>         →  Resume from latest handoff (new session)
```

### Completion Gates (Non-Negotiable)

A bead **CANNOT** be marked complete until:
- [ ] Build passes
- [ ] **ALL** tests pass (existing + new)
- [ ] Lint passes (if present)
- [ ] All tests specified in plan's "Testing Strategy" are written

---

## Testing Requirements

> Tests are not optional. Every feature/fix must have corresponding tests.
> 
> Aligned with **Agile Testing** (Crispin & Gregory)

### Test Pyramid
```
      /\      E2E (few, slow)
     /──\     Integration (some)
    /────\    Unit (many, fast)
```

### Agile Testing Quadrants
- **Q1**: Unit & component tests (automated, support team)
- **Q2**: Functional & story tests (automated, support team)
- **Q3**: Exploratory & usability (manual, critique product)
- **Q4**: Performance & security (automated, critique product)

### In `/plan`
- **MANDATORY**: "Testing Strategy" section with:
  - Tests mapped to quadrants
  - New tests to write (with file paths)
  - Existing tests to update
  - Exploratory testing notes

### In `/implement`
- Tests must pass after EVERY step
- Lint must pass after EVERY step
- Follow FIRST principles (Fast, Independent, Repeatable, Self-validating, Timely)
- Test behavior, not implementation
- New tests from plan must be written

### In `/finish`
- **HARD GATE**: Build + Tests + Lint must ALL pass
- Cannot close bead if any verification fails
- Blocked beads return to `/implement`

```bash
# Verification commands (examples)
npm run build && npm test && npm run lint    # Node.js
cargo build && cargo test && cargo clippy    # Rust
go build ./... && go test ./... && golangci-lint run  # Go
pytest && ruff check                          # Python
```

---

## Code Quality Principles

Agents follow principles from:
- **The Pragmatic Programmer**: DRY, Orthogonality, ETC (Easy To Change)
- **The Art of Readable Code**: Clear names, simplicity, reduce cognitive load
- **A Philosophy of Software Design**: Deep modules, information hiding, pull complexity down

### Language Idioms (Enforced)

| Language | Requirements |
|----------|--------------|
| TypeScript | Strict types, no `any`/`unknown`, proper interfaces |
| Go | Idiomatic Go, accept interfaces/return structs, handle errors |
| Python | Pythonic, type hints, PEP 8, dataclasses |
| Rust | Embrace borrow checker, `Result`/`Option`, clippy clean |

See `/implement` command for full coding standards.

---

## Commands

| Command | Context | Purpose |
|---------|---------|---------|
| `/create` | Subtask | Interview → bead (with templates) + spec.md |
| `/start [bead-id]` | Main | bd ready → find/setup bead, load context |
| `/research <bead-id>` | Subtask | Deep codebase exploration → research.md |
| `/plan <bead-id>` | Subtask | Interactive planning → plan.md |
| `/iterate <bead-id>` | Subtask | Update existing plan based on feedback |
| `/implement <bead-id>` | Subtask | Execute plan, create discovered-from links |
| `/finish [bead-id]` | Subtask | Review + commit + sync + push (+ bd compact) |
| `/handoff <bead-id>` | Subtask | Create handoff document for session continuity |
| `/resume <bead-id>` | Subtask | Resume work from latest handoff |

### Usage

```bash
# Full workflow
/create                   # Interview → bead + spec (uses templates)
/start bd-xxx             # Setup workspace
/research bd-xxx          # Explore codebase
# [review research.md]
/plan bd-xxx              # Create plan
# [review plan.md]
/iterate bd-xxx           # Update plan if needed (optional)
/implement bd-xxx         # Execute plan
/finish                   # Wrap up

# Quick start (find existing bead)
/start                    # Shows bd ready output, pick one
/start bd-xxx --worktree  # Direct start with worktree
/start bd-xxx --branch    # Direct start with feature branch

# Using templates
/create                   # Will offer: epic, feature, bug templates

# Session continuity (Frequent Intentional Compaction)
/handoff bd-xxx           # Context limit approaching? Save state
/resume bd-xxx            # New session? Continue from handoff
```

---

## Human Review Points

| After | Review | Why |
|-------|--------|-----|
| `/create` | `spec.md` | Ensure problem is well-defined |
| `/start` | Loaded context | Understand state before research |
| `/research` | `research.md` | Bad research = bad plan = bad code |
| `/plan` | `plan.md` | Approve approach before implementation |
| `/iterate` | Updated `plan.md` | Verify changes are correct |
| `/resume` | Restored context | Confirm state before continuing |
| `/finish` | Commits + PR | Final validation |

---

## Subagents

Commands spawn specialized subagents for parallel exploration:

| Agent | Purpose |
|-------|---------|
| `codebase-locator` | Fast file/component finding |
| `codebase-analyzer` | Deep code understanding with file:line refs |
| `codebase-pattern-finder` | Find similar implementations |
| `web-search-researcher` | Analyze content from URLs |

### Parallel Execution (Claude 4)

```
Phase 1 - Locate (parallel):
├─ @codebase-locator: Find component A
├─ @codebase-locator: Find component B
└─ @codebase-pattern-finder: Find similar patterns
[WAIT]

Phase 2 - Analyze (parallel):
├─ @codebase-analyzer: Analyze component A
└─ @codebase-analyzer: Analyze component B
[WAIT]

Synthesize findings → artifact
```

---

## Beads Features Utilized

### Ready Work Detection
```bash
bd ready --json --limit 10   # Find unblocked work
bd blocked                   # Show blocked beads
bd stats                     # Project statistics
```

### Templates
```bash
bd create --from-template epic "Q4 Platform"
bd create --from-template feature "Add OAuth"
bd create --from-template bug "Auth fails" -p 0
```

### Hierarchical IDs (Work Breakdown)
```
bd-a1b2      [epic] Auth System
bd-a1b2.1    [task] Design login UI
bd-a1b2.2    [task] Backend validation
bd-a1b2.3    [epic] Password Reset (sub-epic)
bd-a1b2.3.1  [task] Email templates
```

### Dependency Types
- `blocks` - Hard blocker (default)
- `related` - Soft relationship
- `parent-child` - Hierarchical (child depends on parent)
- `discovered-from` - Found during work on another bead (inherits source_repo)

### Memory Decay (Compaction)
```bash
bd compact --analyze --json  # Get candidates (closed 30+ days)
# Agent summarizes content
bd compact --apply --id bd-xxx --summary summary.txt
```

---

## Artifacts

```
.beads/
└── artifacts/
    └── <bead-id>/
        ├── spec.md       # Created by /create
        ├── research.md   # Created by /research
        ├── plan.md       # Created by /plan
        ├── review.md     # Created by /finish
        └── handoffs/     # Session continuity
            └── YYYY-MM-DD_HH-MM-SS_handoff.md  # Created by /handoff
```

### Progress Tracking

Progress tracked in `plan.md`:

```markdown
## Phase 1: Setup ✓ COMPLETE
- [x] Create migration
- [x] Add model

## Phase 2: API (in progress)
- [x] Create handler
- [ ] Add validation
- [ ] Write tests
```

---

## Context Management

| Command | Runs As | Why |
|---------|---------|-----|
| `/create` | Subtask | Focused interview |
| `/start` | Main | User interaction needed |
| `/research` | Subtask | Deep exploration, fresh context |
| `/plan` | Subtask | Focused planning |
| `/iterate` | Subtask | Surgical plan updates |
| `/implement` | Subtask | Clean context for coding |
| `/finish` | Subtask | Independent review |
| `/handoff` | Subtask | Capture state before context limit |
| `/resume` | Subtask | Restore state in fresh context |

Each subtask gets fresh context. Artifacts persist between phases.

### Session Continuity (Frequent Intentional Compaction)

When context window approaches limit:
1. Run `/handoff <bead-id>` to capture current state
2. End session gracefully
3. Start new session with `/resume <bead-id>`
4. Continue work seamlessly from handoff

Handoffs capture:
- Current task and phase progress
- Recent changes (file:line)
- Learnings and discoveries
- Verification status
- Prioritized action items

---

## Claude 4 Best Practices (Applied)

All commands include `<claude4_guidance>` sections implementing:

| Practice | Implementation |
|----------|----------------|
| **Be Explicit** | Detailed instructions with WHY/motivation |
| **Investigate Before Acting** | Read files completely before editing |
| **Parallel Tool Calls** | Subagents and reads run in parallel |
| **Context Awareness** | Save state before compaction |
| **Avoid Overengineering** | Minimum changes, no unplanned features |
| **Default to Action** | Execute after approval, don't re-confirm |
| **Ground All Claims** | file:line references required |

---

## Alignment Summary

| Principle | Implementation |
|-----------|----------------|
| ACE-FCA: Human as Orchestrator | User runs commands, reviews artifacts |
| ACE-FCA: Frequent Compaction | Each phase is subtask + /handoff for session continuity |
| ACE-FCA: Artifacts over Memory | All state in .beads/artifacts/ including handoffs |
| ACE-FCA: High-Leverage Review | Review spec, research, plan |
| ACE-FCA: Session Continuity | /handoff + /resume for cross-session work |
| Claude 4: Explicit Instructions | XML-tagged prompts |
| Claude 4: Parallel Tool Calls | Subagents run parallel |
| Claude 4: Subagent Orchestration | Auto-delegation |
| OpenCode: Subtasks | `subtask: true` |
| Beads: Source of Truth | bd CLI for metadata |
