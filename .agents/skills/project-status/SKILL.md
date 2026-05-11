---
name: project-status
description: Show a summary of all active projects, their state, focus, and blockers. Triggered by "project status", "trạng thái dự án", "what's active", "show all projects", or "dự án đang chạy".
---

# Project Status Skill

## Purpose
Give a fast, structured overview of all projects without reading every file manually.

## Steps

### 1. Read registry
Read `projects/registry/projects.json`.

### 2. Read active dashboard
Read `projects/registry/active.md` for human summary.

### 3. For each active or paused project, check
- `projects/<domain>/<project>/ops/handoff.md` — last session outcome and next step
- `projects/<domain>/<project>/ops/state.json` if it exists — execution state

### 4. Output status table

```
## Project Status — <date>

| Project | Domain | Phase | Priority | Focus | Next step | Blocker |
|---|---|---|---|---|---|---|
| analysic-data | data | discovery | medium | <current_focus> | <handoff next step> | <blocker or —> |
| explore-CAN... | data | discovery | medium | <current_focus> | <handoff next step> | <blocker or —> |
| esp_loss_power | iot | discovery | medium | <current_focus> | <handoff next step> | <blocker or —> |
| analysis | ops | active | medium | <current_focus> | <handoff next step> | — |

Missing setup:
- <list projects with no machine path or no handoff>

Report due:
- <list projects with no draft this week if it's Friday>
```

### 5. Ask what to do next
"Which project do you want to work on, or do you need a status update on a specific one?"
