---
name: session-end
description: End a work session. Write handoff note and remind user to commit. Triggered by "end session", "kết thúc session", "handoff", "commit and push", or "done for today".
---

# Session End Skill

## Purpose
Capture session outcome and prepare context for the next session on any machine.

## Steps

### 1. Identify which project was worked on
If unclear, ask the user: "Which project did we work on this session?"

### 2. Write handoff to `projects/<domain>/<project>/ops/handoff.md`

Append a new section at the top of the file (newest first):

```markdown
## Session handoff — <YYYY-MM-DD>
Machine: <read machine_id from .opencode-machine.json>

### Completed
- <list only verified, done outcomes — not in-progress work>

### Current state
- Branch: <branch name, or "no git repo yet">
- Last verified: <what was tested or confirmed>
- Known issues: <list, or "none">

### Exact next step
<Single, specific, immediately actionable step — no ambiguity>

### Context for next session
<Minimum context Antigravity needs to continue without re-explanation>
```

### 3. Remind the user
After writing, output exactly:

```
Handoff written. Run to sync across machines:

  git add -A
  git commit -m "session handoff: <project-id> <YYYY-MM-DD>"
  git push

Open on another machine: git pull, then start a new session.
```

### 4. Do not start new work
After writing the handoff, stop and wait for the user.
