# Primary Orchestration Workflow

## Goal

Keep the primary agent focused on coordination and final decisions instead of carrying deep technical context.

## Default execution chain

1. `explore-agent`
2. `code-agent`
3. `review-agent`
4. `qa-agent`
5. `report-agent` when needed

## Routing rules

1. Use `explore-agent` when the task or scope is unclear.
2. Use `code-agent` when the target scope is ready for implementation.
3. Use `review-agent` after meaningful changes or when architecture risk matters.
4. Use `qa-agent` after review to validate behavior and gaps.
5. Use `report-agent` on Friday or before stakeholder updates.

## Context rules

1. Pass only scoped context to each specialist.
2. Keep the primary agent's retained context to:
   - task summary
   - current project status
   - latest code handoff
   - latest review findings
   - latest QA result
3. Do not pass full conversation history unless necessary.

## Approval rules

1. Architecture changes proposed by `review-agent` must be reviewed by the owner.
2. The primary agent must classify those items as:
   - `approved for implementation`
   - `deferred`
   - `rejected`
3. Only approved architecture work may be handed to `code-agent`.
