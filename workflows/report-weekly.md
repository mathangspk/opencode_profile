# Weekly Report Workflow

## Trigger

Run this workflow every Friday or on-demand before a stakeholder update.

## Inputs

1. Project profile file
2. Project reporting config and override files
3. Jira Epic and child issues
4. Recent repo activity
5. Current local work context
6. Last draft and published report if available

## Steps

1. Read the project profile.
2. Read `reporting/config.json`, `reporting/workflow.md`, `reporting/jira.md`, and `reporting/notion.md`.
3. Read the Jira Epic summary, status, and linked issues.
4. Identify issues completed this week, still in progress, and blocked.
5. Compare Jira issue status against technical progress visible in code, commits, or local changes.
6. Capture delivery-impacting commercial notes.
7. Produce two drafts:
   - Jira weekly comment draft
   - Notion weekly toggle draft
8. Produce one internal snapshot for `reporting/history/drafts/YYYY-MM-DD.md`.
9. Call out mismatches between Jira and technical reality.

## Output rules

1. Keep the Jira draft brief.
2. Keep the Notion draft readable for future review.
3. Prefer factual statements over optimistic estimates.
4. If progress is unclear, state that directly.
