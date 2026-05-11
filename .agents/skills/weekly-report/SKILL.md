---
name: weekly-report
description: Generate weekly progress report drafts for Jira and Notion. Triggered by "weekly report", "báo cáo tuần", "Friday report", "thứ Sáu", or "report this week".
---

# Weekly Report Skill

## Purpose
Produce draft reports for Jira and Notion without starting from scratch each Friday.

## Context
- Report day: Friday
- Jira: weekly comment on Epic
- Notion: weekly toggle entry

## Steps

### 1. Ask which project (if not stated)
"Which project do you want the report for?"

### 2. Read project context in order
1. `projects/<domain>/<project>/profile.md` — identity, phase, commercial context
2. `projects/<domain>/<project>/reporting/config.json` — Jira key, Notion page, report preferences
3. `projects/<domain>/<project>/ops/state.json` — current execution state
4. `projects/<domain>/<project>/ops/handoff.md` — recent session outcomes (last 2-3 entries)
5. `projects/<domain>/<project>/reporting/history/drafts/` — list recent drafts to avoid duplication

### 3. Produce two drafts

**Jira weekly comment** (bullet format):
```
Week of <YYYY-MM-DD>

Progress:
- <what was completed, evidence-based>

Blockers:
- <active blockers, or "None">

Next week:
- <planned focus>
```

**Notion weekly toggle** (narrative):
```
**Week of <date>** — <one-line summary>

<2-3 sentence narrative: what was done, what was learned, what is next>

Blockers: <inline or "None">
```

### 4. Ask for approval before saving
Show both drafts and ask: "Does this look right? I'll save the draft after you confirm."

### 5. Save draft after approval
Save to: `projects/<domain>/<project>/reporting/history/drafts/<YYYY-MM-DD>.md`

Format:
```markdown
# Weekly report draft — <YYYY-MM-DD>
Status: draft

## Jira comment
<content>

## Notion toggle
<content>
```

### 6. Remind user about publishing
After saving:
```
Draft saved. After you post manually to Jira and Notion, save the published snapshot:
  projects/<domain>/<project>/reporting/history/published/<YYYY-MM-DD>.md
```
