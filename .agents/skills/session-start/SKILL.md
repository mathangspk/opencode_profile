---
name: session-start
description: Start a new work session. Read workspace state, active projects, and session focus. Triggered by "start session", "bắt đầu session", "today's focus", or "hôm nay làm gì".
---

# Session Start Skill

## Purpose
Orient quickly at the start of a session without re-explaining the workspace.

## Steps

### 1. Read workspace state
- Read `projects/registry/active.md` — list of active and paused projects
- Read `projects/registry/now-working.md` — current declared session focus
- Read `projects/registry/machine-sync.md` — last known sync state

### 2. Read handoffs for active projects
For each active project, check if `projects/<domain>/<project>/ops/handoff.md` exists.
If it does, read it and note the "Exact next step" field.

### 3. Produce session briefing

Format:
```
## Session briefing — <date>

Active projects:
- <project-id> [<domain>] — <current_focus> | Next: <handoff next step or "no handoff found">

Current focus (declared): <now-working.md content>

Recommended focus today: <suggest based on priority and handoff state>

Ready to proceed. Which project do you want to work on?
```

### 4. Wait for user direction
Do not start any project work until the user confirms the focus.
