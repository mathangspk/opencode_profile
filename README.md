# opencode_profile

Portable profile for managing and reviewing projects across data, web, and IoT work.

## Operating model

- `1 project = 1 Jira Epic`
- `Weekly report day = Friday`
- `Jira` is the execution and short-doc system
- `Notion` is the project summary and narrative system
- `orchestrator` is the primary orchestration-only agent
- `report-agent` generates drafts only; you review before posting

## Agent architecture

1. `orchestrator`
   - Orchestration only
   - Chooses specialist agents
   - Keeps only short-form context and final decisions

2. `explore-agent`
   - Read-only project discovery
   - Maps structure, entry points, boundaries, and relevant scope

3. `code-agent`
   - Implementation only
   - Makes the smallest correct changes for the scoped task

4. `review-agent`
   - Code and architecture review
   - Can propose architecture changes
   - Architecture changes require owner approval before implementation

5. `qa-agent`
   - Report-only validation
   - Separate modes from day one:
     - `data`
     - `web`
     - `iot`

6. `report-agent`
   - Weekly reporting drafts for Jira and Notion

## Repository structure

```text
opencode_profile/
  core/
  workflows/
  integrations/
  agents/
  templates/
  projects/
  install/
```

## Recommended workflow

1. Create a Jira Epic for each project.
2. Create one Notion page for each project.
3. Copy `projects/_templates/project-profile.md` for each project.
4. Update `projects/registry/projects-index.md` and `projects/registry/active.md`.
5. Copy the OpenCode scaffold into each project root.
6. Run the execution flow through specialist agents.
7. Run the weekly report flow every Friday.

For a fast startup flow, use `workflows/new-project-checklist.md`.

## Execution flow

1. `orchestrator -> explore-agent`
   - Use when the project is unfamiliar or the task scope is unclear.

2. `orchestrator -> code-agent`
   - Use after the task scope and target files are clear.

3. `orchestrator -> review-agent`
   - Use after meaningful code changes.
   - Review findings may include architecture improvement proposals.

4. `orchestrator -> qa-agent`
   - Use after review to validate behavior and regression risk.
   - Pick the project mode: `data`, `web`, or `iot`.

5. `orchestrator -> report-agent`
   - Use on Friday or before stakeholder updates.

## Per-project OpenCode scaffold

Copy these files into each project when it is initialized:

```text
project-root/
  opencode.json
  .opencode/
    agents/
      orchestrator.md
      explore-agent.md
      code-agent.md
      review-agent.md
      qa-agent.md
      report-agent.md
```

Use the scaffold under `scaffolds/opencode-project/` in this repo.

Install it with a script instead of copying by hand:

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\install\install-project-scaffold.ps1 -ProjectPath "C:\path\to\project"
```

macOS/Linux:

```bash
./install/install-project-scaffold.sh /path/to/project
```

### Scaffold rules

1. `orchestrator` is the default primary agent.
2. All agents are bound to `openai/gpt-5.4`.
3. `orchestrator` can call specialist agents through `task` permission.
4. `orchestrator` is denied direct file edits.
5. Specialist permissions enforce role separation.

## Approval gate

1. `review-agent` may propose architecture changes.
2. The proposal must be classified as either:
   - `required fix`
   - `recommended improvement`
3. The owner must approve architecture changes before `code-agent` implements them.
4. `qa-agent` never fixes code directly.

## Weekly reporting flow

1. Open the project profile.
2. Read the linked Jira Epic and child issues.
3. Read recent repo activity and local project state.
4. Use `agents/report-agent.md` with `workflows/report-weekly.md`.
5. Produce:
   - one Jira weekly comment draft
   - one Notion weekly toggle draft
6. Review the drafts, then post manually.

## Bootstrapping on a new machine

Windows:

```powershell
./install/bootstrap.ps1
./install/verify.ps1
```

macOS/Linux:

```bash
./install/bootstrap.sh
./install/verify.sh
```

## First setup checklist

1. Fill in your project entries under `projects/`.
2. Add your Jira Epic keys and Notion page links.
3. Fill in architecture notes, critical flows, and testing strategy.
4. Copy `scaffolds/opencode-project/` into the project root.
5. Adapt templates only if you have a concrete need.
6. Test the specialist workflow on one real project before scaling.
