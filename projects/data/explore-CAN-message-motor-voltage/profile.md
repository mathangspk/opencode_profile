# Project Profile

## Identity

- Project name: explore-CAN-message-motor-voltage
- Domain: `data`
- Status: `active`
- Priority: medium

## Repositories

- Repo URL: 
- Local path: `C:\local\find_motor_voltage`
- Default branch: `main`

## Jira

- Jira project key: TBD
- Jira Epic key: TBD
- Jira Epic URL: TBD

## Notion

- Notion page link: TBD
- Notion page id: TBD

## Delivery context

- Commercial context: investigate CAN voltage-related signals for engineering analysis
- Current phase: discovery
- Definition of done: identify relevant CAN messages, document voltage signal interpretation, and define a repeatable validation path
- Weekly report day: `Friday`
- Approval sensitivity: `medium`

## Working context

- Current focus: map CAN messages related to motor voltage and identify the source data path
- Known blockers: Jira Epic and Notion page are not created yet
- Key risks: signal naming ambiguity, missing raw capture context, and incomplete validation evidence
- Reporting notes: keep updates evidence-based and flag uncertain signal interpretation explicitly

## Architecture and scope

- Architecture notes:
- Important directories: `data/`
- Entry points:
- Critical flows: raw data inspection -> candidate CAN message mapping -> voltage interpretation validation
- Known fragile areas:
- Architecture constraints:
- Refactor approval notes:

## Commands and operations

- Run command: inspect data files under `data/`
- Test command: define after the first exploration pass
- Build or deploy command: not applicable yet

## OpenCode setup

- OpenCode scaffold copied: `yes`
- Default primary agent: `orchestrator`
- Default model: `openai/gpt-5.4`
- Agent overrides:
- Team project ref: `projects/data/explore-CAN-message-motor-voltage`

## Testing and validation

- Testing strategy: compare candidate voltage signals against raw data assumptions and expected engineering behavior
- Acceptance checks: confirm message mapping, units, and validation evidence before reporting conclusions
- QA mode: `data`
- QA priorities: data interpretation correctness, missing context, and false confidence in signal mapping

## Agent notes

- Review priorities: data lineage, transformation assumptions, and unsupported claims about voltage signals
- Areas to avoid unless required:
- Expected output style: concise, evidence-based, and explicit about uncertainty

