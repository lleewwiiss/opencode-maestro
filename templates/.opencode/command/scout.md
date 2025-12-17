---
description: Quick async exploration - fire background agents and continue working
---
<context>
You are launching quick, non-blocking exploration. This is the "fire and forget" pattern from oMo (oh-my-opencode).

Unlike /research (which is interactive and thorough), /scout fires background agents and returns immediately. Use this when you want to explore while continuing other work. This enables parallel work streams - you keep implementing while scouts gather context.

Results are collected later with background_output or automatically surfaced when agents complete.
</context>

<goal>
Launch parallel background exploration agents and return immediately. User continues working while scouts search.
</goal>

<use_parallel_tool_calls>
Fire ALL scouts in a single parallel batch. Do not wait for any agent before launching others. The entire point is maximum parallelism - launch everything simultaneously.
</use_parallel_tool_calls>

<return_immediately>
After launching agents, return control to user immediately. Do NOT wait for results. Do NOT block. The user wants to continue working while scouts search in background.

Bad: Launch agent, wait for result, return
Good: Launch 5 agents in parallel, return immediately with task IDs
</return_immediately>

<arguments>
$1 - Search target (component name, pattern, question)
$ARGUMENTS - Additional search targets (space-separated)
</arguments>

<workflow>

<phase name="parse_targets">
## Phase 1: Parse Search Targets

Extract search targets from arguments:
- $1 is the primary target
- $ARGUMENTS may contain additional targets

If no arguments provided:
```
Usage: /scout <target> [additional targets...]

Examples:
  /scout authentication          # Find auth-related code
  /scout "user model" "api routes"  # Multiple targets
  /scout "how does caching work"    # Question-style
```
</phase>

<phase name="launch_scouts">
## Phase 2: Launch Background Agents

**Fire all scouts in parallel (don't wait):**

For each search target, determine the best agent:

**Internal codebase exploration** (default):
```
background_task(
  agent="explore", 
  prompt="Find files and code related to: [target]. Return file paths with brief descriptions of what each contains. Specify relevance to the search target."
)
```

**If target mentions external library/framework:**
```
background_task(
  agent="librarian",
  prompt="Look up [library/framework] documentation. Find: official docs, common patterns, gotchas. Return actionable summary."
)
```

**If target is a pattern/implementation question:**
```
background_task(
  agent="codebase-pattern-finder",
  prompt="Find similar implementations or patterns for: [target]. Return code examples with file:line references."
)
```

Capture all task_ids.
</phase>

<phase name="return_immediately">
## Phase 3: Return Immediately

Do NOT wait for results. Report what was launched:

```
Scouts Deployed
===============

Targets:
- [target 1] -> @explore (task: abc123)
- [target 2] -> @librarian (task: def456)

Results will appear when agents complete.
To collect manually: background_output(task_id="...")

Continue working - scouts are searching in background.
```
</phase>

</workflow>

<usage_patterns>
## When to Use /scout vs /research

| Use /scout | Use /research |
|------------|---------------|
| Quick lookups while working | Deep understanding before planning |
| Exploring unfamiliar areas | Producing research.md artifact |
| Multiple parallel searches | Human review is critical |
| Don't need to block | High-stakes decisions |

## Collecting Results

Results appear automatically when agents complete. Or collect manually:
```
background_output(task_id="abc123")
```

To collect all pending:
```
background_output(task_id="abc123")
background_output(task_id="def456")
// ... for each task
```
</usage_patterns>

<constraints>
- NEVER wait for results - return immediately after launching
- Fire multiple agents in parallel when multiple targets provided
- Choose appropriate agent type based on target (explore vs librarian vs pattern-finder)
- Keep prompts focused - scouts should return quickly
</constraints>
