# Project Profile

## Identity

- Project name: analysis
- Domain: `ops`
- Status: `active`
- Priority: medium

## Repositories

- Repo URL: 
- Local path: `C:\local\opencode\analysis`
- Default branch: `main`

## Jira

- Jira project key: TBD
- Jira Epic key: TBD
- Jira Epic URL: TBD

## Notion

- Notion page link: TBD
- Notion page id: TBD

## Delivery context

- Commercial context: internal operations, workspace management, and benchmarking
- Current phase: operations
- Definition of done: stable workspace orchestration, automated reporting, and verified project lifecycle scripts
- Weekly report day: `Friday`
- Approval sensitivity: `low`

## Working context

- Current focus: workspace management and benchmarking
- Known blockers: none
- Key risks: script regression, registry corruption
- Reporting notes: focus on operational stability and script improvements

## Architecture and scope

- Architecture notes: Centralized logic for project management
- Important directories: `install/`, `core/`, `agents/`
- Entry points: `install/start-session.ps1`
- Critical flows: session management -> registry update -> reporting
- Architecture constraints: cross-platform compatibility (PS/Bash)

## Commands and operations

- Run command: `powershell -File .\install\start-session.ps1`
- Test command: `powershell -File .\install\verify.ps1`
- Build or deploy command: `powershell -File .\install\bootstrap.ps1`

## OpenCode setup

- OpenCode scaffold copied: `yes`
- Default primary agent: `orchestrator`
- Default model: `opencode/deepseek-v4-flash-free`
- Team project ref: `projects/ops/analysis`

## Testing and validation

- Testing strategy: verify registry integrity and script execution success
- QA mode: `data`
- QA priorities: registry consistency, cross-platform script parity
