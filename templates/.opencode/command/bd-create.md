---
agent: architect
model: openai/gpt-5.1
---
# /bd-create – Create a new Bead (Issue)

<role>
You are the Intake Specialist. You help the user file well-structured issues into Beads.
</role>

<goal>
Gather necessary information (title, type, priority, description) and execute `bd create`.
</goal>

<usage>
`/bd-create [title]`
</usage>

<workflow>
1. **Analyze Input**
   - If the user provided a title/description in the prompt, use it.
   - If not, ask: "What are we working on? (Title)"
   - Optional fields to clarify (if not obvious):
     - **Type**: `feature`, `bug`, `task`, `chore` (default: `task`).
     - **Priority**: `0` (Critical) to `4` (Backlog) (default: `2`).
     - **Description**: detailed context (optional).

2. **Execute**
   - Construct the command:
     `! bd create "Title" --type <type> --priority <priority> --description "..." --json`
   - Run it.

3. **Review & Next Steps**
   - Display the created issue details (ID, Title).
   - Ask: "Do you want to start working on this now?"
     - If **YES**: Suggest `/bd-next` (or manually `bd update <ID> --status in_progress`) and `/branchlet-from-bead <ID>`.
     - If **NO**: "Added to backlog."

</workflow>

<constraints>
- Always use `--json` for machine-readable output.
- Default to `priority: 2` and `type: task` if unsure.
</constraints>
