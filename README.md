```
  __  __                 _
 |  \/  |               | |
 | \  / | __ _  ___  ___| |_ _ __ ___
 | |\/| |/ _` |/ _ \/ __| __| '__/ _ \
 | |  | | (_| |  __/\__ \ |_| | | (_) |
 |_|  |_|\__,_|\___||___/\__|_|  \___/
           OpenCode Maestro
```

A structured, high-context workflow for [OpenCode](https://opencode.ai), ported from [Amp Maestro](https://github.com/lleewwiiss/amp-maestro).

It leverages OpenCode's **Agents**, **Commands**, and **Subtasks** to implement a rigorous **Research → Plan → Implement** loop, powered by **Beads** (Issue Tracking) and **Branchlet** (Worktrees).

## Features

- **Primary Agent**:
  - **Architect** (`openai/gpt-5.1`): The Manager. Orchestrates the workflow and manages context.
- **Subagents**:
  - **Planner** (`openai/gpt-5.1`): "Thinking" subagent for architectural planning.
  - **Coder** (`google/gemini-3-pro-preview`): "Coding" subagent for implementation.
  - **Researcher** (`openai/gpt-5.1`): "Librarian" subagent for context gathering.
- **Slash Commands**:
  - `/research`: Spawns **Researcher** subtask.
  - `/plan`: Spawns **Planner** subtask.
  - `/implement`: Spawns **Coder** subtask.
  - `/bd-create` / `/bd-next`: Manage worktrees via Architect.
- **Context Hygiene**: Uses OpenCode's **subtasks** (Child Sessions) to keep the Architect's context clean.

## Prerequisites

- [OpenCode](https://opencode.ai)
- [Beads (bd)](https://github.com/beads-dev/beads)
- [Branchlet](https://github.com/raghavpillai/branchlet)
- `git`, `rg` (ripgrep)

## Installation

Run this command in the root of your project:

```bash
# Local install (current directory)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lleewwiiss/opencode-agentic-workflow/main/install.sh)"

# Global install (for all projects)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lleewwiiss/opencode-agentic-workflow/main/install.sh)" -- -g
```

## Workflow

1. **Pick Work**: `/bd-create "My new feature"` or `/bd-next`.
2. **Research**: `/research` (Uses GPT-5.1 to analyze context).
3. **Plan**: `/plan` (Uses GPT-5.1 to create a step-by-step plan).
4. **Implement**: `/implement` (Uses Gemini 3.0 to write code).
5. **Ship**: `/land-plane` (Runs tests and merges).

## Structure

This repository provides:

- `.opencode/agent/`: Definitions for `plan` and `build` agents.
- `.opencode/command/`: Custom slash commands that orchestrate the workflow and call the CLI tools.
- `opencode.jsonc`: Recommended base configuration.
