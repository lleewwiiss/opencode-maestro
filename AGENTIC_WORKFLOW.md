# Agentic Workflow Protocol

Aligned with:
- [ACE-FCA](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents) - Frequent Intentional Compaction
- [Claude 4 Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices) - Explicit instructions, parallel tools, investigate before acting
- [Block's Dialectical Autocoding](https://block.xyz/documents/adversarial-cooperation-in-code-synthesis.pdf) - Coach-Player adversarial cooperation

**Tools**: Beads (bd CLI) + Git Worktrees + OpenCode + oh-my-opencode (commands + subagents)

---

## Core Principles

### ACE-FCA Principles

> "A bad line of code is a bad line of code. But a bad line of a **plan** could lead to hundreds of bad lines of code. And a bad line of **research** could land you with thousands of bad lines of code."

1. **Human as Orchestrator** - You drive; agents execute
2. **Frequent Intentional Compaction** - Each phase is fresh context (subtask)
3. **Artifacts over Memory** - Persist to `.beads/artifacts/` (specs, research, plans)
4. **High-Leverage Human Review** - Review research and plans, not just code
5. **Research → Plan → Implement** - Mandatory sequence

### Dialectical Autocoding (Block Research)

> "Discard the implementing agent's self-report of success and have the coach perform an independent evaluation."

The workflow implements a **Coach-Player** adversarial cooperation pattern:

| Role | Focus | Responsibility |
|------|-------|----------------|
| **Player** | Implementation | Write code, execute commands, respond to feedback |
| **Coach** | Validation | Verify against requirements, provide specific feedback |

**Key Insight**: Without independent coach review, implementing agents claim success while producing non-functional code. The coach anchors ALL evaluation to the original spec.md requirements.

**Turn Limits**: Maximum 10 implementation turns per phase. If coach doesn't approve within 10 turns, escalate to human.

---

## The 11-Command Workflow

```
/create                   →  Interview → bead + spec.md (uses templates)
      ↓
/start [bead-id]          →  bd ready → setup workspace → load context (async pre-warm)
      ↓
/scout <target>           →  Quick async exploration (fire-and-forget, optional)
      ↓
/research <bead-id>       →  INTERACTIVE: Explore → present findings → iterate → research.md
      │                       (back-and-forth conversation IS the review)
      ↓
/plan <bead-id>           →  INTERACTIVE: Generate → walk through phases → iterate → plan.md
      │                       (child beads created ONLY after approval)
      ↓
/iterate <bead-id>        →  Update plan based on feedback (optional)
      ↓
/implement <bead-id>      →  Execute plan with coach checkpoints (max 10 turns/phase)
      │                       ↓
      │                   /coach <bead-id>  →  Adversarial validation against spec.md
      │                       ↓
      │                   [Coach APPROVED?] → Continue / Address feedback
      ↓
   [Tests + Lint + Coach MUST pass] ← HARD GATE
      ↓
/finish <bead-id>         →  Coach review → commit + close

Session Continuity (use anytime):
──────────────────────────────────
/handoff                  →  Create handoff document (context approaching limit)
/rehydrate                →  Resume from latest handoff (new session)
```

### Completion Gates (Non-Negotiable)

A bead **CANNOT** be marked complete until:
- [ ] Build passes
- [ ] **ALL** tests pass (existing + new)
- [ ] Lint passes (if present)
- [ ] All tests specified in plan's "Testing Strategy" are written
- [ ] **For parent beads**: All child beads must be closed first

---

## Interactive Refinement (Always-On)

Both `/research` and `/plan` are **always interactive**. This is not optional - it's how high-leverage review happens.

### Why Interactive?

From ACE-FCA:
> "You have to engage with your task or it WILL NOT WORK."

The back-and-forth conversation IS the review. Passive artifact review leads to rubber-stamping.

### `/research` Interactive Flow

```
1. GENERATE (subagent, fresh context)
   └→ Agent explores codebase
   └→ Writes research.md
   
2. PRESENT & DISCUSS (main context)
   └→ Agent presents key findings conversationally
   └→ "Does this match your understanding?"
   └→ Flags uncertainties: "I'm not 100% sure about X"
   └→ Chesterton's Fence: "I believe Y exists because Z. Confirm?"
   
3. ITERATE
   └→ Human: "dig deeper on X" → new subagent explores X
   └→ Human: "that's wrong" → new subagent with correction
   └→ Human: "restart" → fresh subagent, new direction
   └→ Agent may push back: "I'd push back - the code shows..."
   
4. FINALIZE
   └→ Human approves
   └→ Summary of confirmed findings
   └→ Ready for /plan
```

### `/plan` Interactive Flow

```
1. GENERATE (subagent, fresh context)
   └→ Agent reads research.md
   └→ Generates plan.md
   
2. PRESENT APPROACH
   └→ Agent presents options with tradeoffs
   └→ Risk assessment (agent judgment)
   └→ Human confirms approach
   
3. WALK THROUGH PHASES
   └→ Agent determines engagement depth per phase:
      • High-risk (auth, data): detailed walkthrough
      • Low-risk (tests, UI): summary, offer details if wanted
   └→ For each phase needing review:
      • Present changes with file:line refs
      • Chesterton's Fence checks
      • "Any concerns?"
   
4. ITERATE
   └→ Human feedback → subagent revises + cascades
   └→ Agent may push back with evidence
   └→ Human overrides noted in plan.md
   
5. FINALIZE & CREATE BEADS
   └→ Human approves final plan
   └→ Child beads created with RICH descriptions
   └→ Ready for /implement
```

### Agent Behaviors

| Behavior | Purpose |
|----------|---------|
| **Variable engagement depth** | Agent decides what needs detailed review vs summary |
| **Push back with evidence** | Agent challenges incorrect feedback |
| **Flag uncertainties** | "I believe X" ≠ "I verified X" |
| **Chesterton's Fence** | Explain WHY existing code works before proposing changes |
| **Note overrides** | If human overrides agent recommendation, document it |

### Child Bead Descriptions

Child beads are created with rich descriptions that enable standalone execution:

```markdown
## Context
[What this phase accomplishes in the larger feature]

## Key Changes
- `file1.ts` - [what changes]
- `file2.ts` - [what changes]

## Patterns to Follow
- See `similar_file:line` for [pattern]

## Success Criteria
- [ ] [Specific criterion]
- [ ] Tests pass

## References
- Full plan: `.beads/artifacts/bd-xxx/plan.md`
```

This allows an agent to work from the bead description itself, with plan.md as backup.

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
| `/scout <target>` | Main | Quick async exploration (fire-and-forget) |
| `/research <bead-id>` | Subtask | **Interactive:** explore → present → iterate → research.md |
| `/plan <bead-id>` | Subtask | **Interactive:** generate → walk through → iterate → plan.md + child beads |
| `/iterate <bead-id>` | Subtask | Update existing plan based on feedback |
| `/implement <bead-id>` | Subtask | Execute plan with coach checkpoints |
| `/coach <bead-id>` | Subtask | Adversarial validation against spec.md |
| `/finish [bead-id]` | Subtask | Coach review → commit + close bead |
| `/handoff` | Subtask | Create handoff document for session continuity |
| `/rehydrate` | Subtask | Resume work from latest handoff |

### Atomic Workflow (Single Task)

For simple tasks without subtasks:

```bash
/create                   # Interview -> bead + spec.md
/start bd-xxx             # Setup workspace
/research bd-xxx          # INTERACTIVE: explore -> discuss -> iterate -> research.md
/plan bd-xxx              # INTERACTIVE: generate -> walk through -> iterate -> plan.md
/iterate bd-xxx           # Update plan if needed (optional)
/implement bd-xxx         # Execute all phases
/finish bd-xxx            # Commit -> PR
```

**Note:** `/research` and `/plan` are interactive sessions with back-and-forth dialogue. Artifacts are written during the conversation, not passively reviewed after.

### Epic Workflow (Large Features)

For features with multiple phases. **Research and planning happen ONCE at the epic level.**

```bash
/create                   # Creates bd-xxx (epic) + spec.md
/start bd-xxx             # Setup workspace
/research bd-xxx          # INTERACTIVE: Research ONCE for entire epic
                          # (back-and-forth until you approve -> research.md)
/plan bd-xxx              # INTERACTIVE: Plan ONCE, walk through all phases
                          # (child beads bd-xxx.1, .2, .3 created AFTER approval)

# Now implement/finish each phase (no research/plan per subtask)
/implement bd-xxx.1       # Execute Phase 1 (uses rich bead description + plan.md)
/finish bd-xxx.1          # Commit Phase 1

/implement bd-xxx.2       # Execute Phase 2
/finish bd-xxx.2          # Commit Phase 2

/implement bd-xxx.3       # Execute Phase 3
/finish bd-xxx.3          # Commit Phase 3

/finish bd-xxx            # Close parent -> PR (all children must be closed)
```

**Note:** 
- `/research` and `/plan` on child beads (e.g., `bd-xxx.1`) will be blocked with guidance to use the parent bead ID.
- Child beads have rich descriptions from `/plan` that enable standalone execution.

### Quick Start & Session Continuity

```bash
# Quick start (find existing bead)
/start                    # Shows bd ready output, pick one
/start bd-xxx --worktree  # Direct start with worktree
/start bd-xxx --branch    # Direct start with feature branch

# Using templates
/create                   # Will offer: epic, feature, bug templates

# Session continuity (Frequent Intentional Compaction)
/handoff                  # Context limit approaching? Save state
/rehydrate                # New session? Continue from handoff
```

---

## Human Review Points

| After | Review | Why |
|-------|--------|-----|
| `/create` | `spec.md` | Ensure problem is well-defined |
| `/start` | Loaded context | Understand state before research |
| `/research` | **Interactive dialogue** | Bad research = bad plan = bad code. Conversation IS review. |
| `/plan` | **Interactive dialogue** | Approve approach AND phases. Child beads created after approval. |
| `/iterate` | Updated `plan.md` | Verify changes are correct |
| `/rehydrate` | Restored context | Confirm state before continuing |
| `/finish` | Commits + PR | Final validation |

**Note:** `/research` and `/plan` are always interactive. You cannot passively review artifacts - you must engage in dialogue with the agent until satisfied.

---

## Subagents

Commands spawn specialized subagents for parallel exploration.

**Primary Agents (oh-my-opencode):**
| Agent | Model | Purpose |
|-------|-------|---------|
| `OmO` | Claude Opus 4.5 | Main orchestrator - plans, delegates, executes complex tasks |
| `OmO-Plan` | (inherits from plan) | Plan agent variant for structured planning |

**Local Codebase Agents:**
| Agent | Model | Purpose |
|-------|-------|---------|
| `explore` | Grok Code | Fast codebase exploration, contextual grep (blazing fast, free) |
| `codebase-analyzer` | Claude Opus 4.5 | Deep code understanding with file:line refs (LSP-enabled) |
| `codebase-pattern-finder` | Claude Opus 4.5 | Find similar implementations (AST-grep enabled) |

**External Research Agents (oh-my-opencode):**
| Agent | Model | Purpose |
|-------|-------|---------|
| `librarian` | Claude Sonnet 4.5 | Official docs (Context7), GitHub search (grep_app), web search (Exa) |
| `oracle` | GPT-5.2 | Architecture review, debugging, design tradeoffs |

**Specialized Agents (oh-my-opencode):**
| Agent | Model | Purpose |
|-------|-------|---------|
| `frontend-ui-ux-engineer` | Gemini 2.5 Pro | UI development - designer-turned-developer |
| `document-writer` | Gemini 2.5 Pro | Technical writing (README, API docs, guides) |
| `multimodal-looker` | Gemini 2.5 Flash | Image/PDF analysis - extracts info from visual content |

### Parallel Execution

Agents run in background for maximum throughput:

```
Phase 1 - Locate (parallel background tasks):
├─ background_task(agent="explore", prompt="Find component A")
├─ background_task(agent="explore", prompt="Find component B")
└─ background_task(agent="codebase-pattern-finder", prompt="Find similar patterns")
[Continue working, collect results when needed]

Phase 2 - Analyze (parallel background tasks):
├─ background_task(agent="codebase-analyzer", prompt="Analyze component A")
└─ background_task(agent="codebase-analyzer", prompt="Analyze component B")
[Continue working, collect results when needed]

Synthesize findings → artifact
```

**Background Agent Workflow:**
- Launch multiple agents concurrently with `background_task`
- System notifies when each completes
- Collect results with `background_output(task_id="...")`
- Cancel all before final answer: `background_cancel(all=true)`

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

Child beads enable atomic, trackable work per phase:

```
bd-a1b2      [epic] Auth System        ← parent bead
bd-a1b2.1    [task] Phase 1: Schema    ← child bead (created by /plan)
bd-a1b2.2    [task] Phase 2: API       ← child bead
bd-a1b2.3    [task] Phase 3: Frontend  ← child bead
```

**Workflow with child beads:**
```bash
/create                    # Creates bd-a1b2 (epic)
/plan bd-a1b2              # Creates plan.md + offers child beads
                           # Creates bd-a1b2.1, bd-a1b2.2, bd-a1b2.3

/implement bd-a1b2.1       # Work on Phase 1 ONLY
/finish bd-a1b2.1          # Commit Phase 1, close child

/implement bd-a1b2.2       # Work on Phase 2 ONLY
/finish bd-a1b2.2          # Commit Phase 2, close child

/implement bd-a1b2.3       # Work on Phase 3 ONLY
/finish bd-a1b2.3          # Commit Phase 3, close child

/finish bd-a1b2            # Close parent (all children must be closed)
```

**Benefits:**
- Each phase independently trackable (`bd list` shows progress)
- Atomic commits per phase
- Can `/handoff` and `/rehydrate` per phase
- `bd ready` shows which phases are unblocked

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

## Child Beads (if created)
| Phase | Bead ID | Status |
|-------|---------|--------|
| Phase 1: Setup | bd-xxx.1 | closed ✓ |
| Phase 2: API | bd-xxx.2 | open |
| Phase 3: Frontend | bd-xxx.3 | open |
```

### Artifact Policy

Artifacts in `.beads/artifacts/<bead-id>/` are **working files**, not permanent documentation.

| Artifact | Purpose | After PR Merge |
|----------|---------|----------------|
| `spec.md` | Define the problem | Bead metadata suffices |
| `research.md` | Guide planning | Delete |
| `plan.md` | Guide implementation | Delete |
| `review.md` | Pre-PR validation | Delete |
| `handoffs/` | Session continuity | Delete |

**Rationale:**
- Artifacts exist to guide implementation, not as permanent documentation
- PR description captures the "why" for posterity
- Git history has the "what" (the actual changes)
- Keeping stale artifacts creates confusion

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
| `/rehydrate` | Subtask | Restore state in fresh context |

Each subtask gets fresh context. Artifacts persist between phases.

### Session Continuity (Frequent Intentional Compaction)

When context window approaches limit:
1. Run `/handoff` to capture current state
2. End session gracefully
3. Start new session with `/rehydrate`
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
| ACE-FCA: Human as Orchestrator | User runs commands, engages in interactive dialogue |
| ACE-FCA: Frequent Compaction | Each phase is subtask + /handoff for session continuity |
| ACE-FCA: Artifacts over Memory | All state in .beads/artifacts/ including handoffs |
| ACE-FCA: High-Leverage Review | Interactive dialogue in /research and /plan (not passive review) |
| ACE-FCA: "Engage with your task" | Always-interactive commands prevent rubber-stamping |
| ACE-FCA: Session Continuity | /handoff + /rehydrate for cross-session work |
| Claude 4: Explicit Instructions | XML-tagged prompts |
| Claude 4: Parallel Tool Calls | Subagents run parallel |
| Claude 4: Subagent Orchestration | Auto-delegation, fresh context per revision |
| OpenCode: Subtasks | `subtask: true` |
| Beads: Source of Truth | bd CLI for metadata |
| Beads: Atomic Work Breakdown | Child beads (bd-xxx.1) with rich descriptions |
| Beads: Hierarchical Completion | Parent can't close until all children closed |
| oh-my-opencode: Multi-Model | OmO orchestrates specialized agents (Oracle, Librarian, etc.) |
| oh-my-opencode: Background Tasks | Parallel agent execution with notification on completion |
