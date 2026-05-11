---
activation: always
---
At the end of any conversation where project-level state was changed (code decisions,
architecture choices, blocker resolution, focus change), produce a handoff update.

Write it to: `projects/<domain>/<project>/ops/handoff.md`

Format:
```
## Session handoff — <YYYY-MM-DD>
Machine: <machine-id from .opencode-machine.json>

### Completed
- <verified outcomes only — do not list in-progress items>

### Current state
- Branch: <branch name>
- Last verified: <what was confirmed working>
- Known issues: <list or "none">

### Exact next step
<One specific, immediately actionable step — no ambiguity>

### Context for next session
<Minimum context for Antigravity to continue without re-explanation>
```

After writing, remind the user to: `git add -A && git commit -m "session handoff: <project>" && git push`
