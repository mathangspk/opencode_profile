# 5-Minute New Project Checklist

Use this checklist every time you start a new project.

## 1. Prepare the project root

1. Clone or create the repo.
2. Open the project root in your terminal.
3. Start OpenCode and run `/init`.

## 2. Install your OpenCode scaffold

1. Install the scaffold with one of these commands:

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\install\install-project-scaffold.ps1 -ProjectPath "C:\path\to\project"
```

macOS/Linux:

```bash
./install/install-project-scaffold.sh /path/to/project
```

2. Or copy `scaffolds/opencode-project/opencode.json` and `scaffolds/opencode-project/.opencode/` manually.
3. Confirm the project now contains:

```text
project-root/
  AGENTS.md
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

## 3. Create the project profile

1. Create the project home with `install/new-project-home.ps1`.
2. Fill in the minimum fields:
    - project name
    - repo URL
    - local path
    - Jira Epic key
    - Notion page link
    - QA mode
    - critical flows
    - approval sensitivity

## 4. Register the project

1. Confirm the script updated `projects/registry/projects.json`.
2. Confirm the dashboards under `projects/registry/*.md` were refreshed.

## 5. Run the first orchestration pass

Ask `orchestrator` to start with project discovery.

Suggested prompt:

```text
Use explore-agent to map this project.
I need:
1. entry points
2. important directories
3. critical flows
4. likely risk areas
5. recommended next step
```

## 6. Sanity check before real work

1. Confirm `orchestrator` is the default primary agent.
2. Confirm all agents use `opencode/deepseek-v4-flash-free`.
3. Confirm `orchestrator` cannot edit files directly.
4. Confirm the selected QA mode matches the project domain.
5. Confirm the Jira Epic and Notion page are correct.

## Done condition

The project is ready when:

1. OpenCode scaffold is in place.
2. Project home is filled in.
3. Registry entries are updated.
4. `.opencode/agents/orchestrator.md` includes the team project ref and domain.
5. `explore-agent` has produced the initial project map.
