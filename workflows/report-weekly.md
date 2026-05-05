# Weekly Report Workflow

## Trigger

Run this workflow every Friday or on-demand before a stakeholder update.

## Inputs

1. Project profile file
2. Jira Epic and child issues
3. Recent repo activity
4. Current local work context
5. Last weekly report if available

## Steps

1. Read the project profile.
2. Read the Jira Epic summary, status, and linked issues.
3. Identify issues completed this week, still in progress, and blocked.
4. Compare Jira issue status against technical progress visible in code, commits, or local changes.
5. Capture delivery-impacting commercial notes.
6. Produce two drafts:
   - Jira weekly comment draft
   - Notion weekly toggle draft
7. Call out mismatches between Jira and technical reality.

## Output rules

1. Keep the Jira draft brief.
2. Keep the Notion draft readable for future review.
3. Prefer factual statements over optimistic estimates.
4. If progress is unclear, state that directly.
