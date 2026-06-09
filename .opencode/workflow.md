# Team Workflow

## A. Default flow — Review Gate
For non-trivial work, dirty worktrees, or multi-session tasks:
1. Audit
2. Fix Plan
3. Approval Gate
4. Delivery
5. Test
6. Final Review
7. User Testing
8. Commit and Push

## B. Lightweight flow — BMAD
For trivial or well-scoped tasks:
1. Brief (goal, acceptance criteria, out of scope)
2. Mapping (relevant files, runtime state, failure points)
3. Architecture (smallest correct approach)
4. Delivery (make change, verify, keep scope narrow)
5. Review (regressions, operational risk, missing verification)

## Delegation policy
- Primary agent owns: planning, sequencing, approvals, implementation decisions, verification decisions, commit/push, handoff updates.
- Subagents only act on explicit instructions from primary agent.
- Subagents do not self-initiate, expand scope, or continue into follow-up phases.
- Subagents must return control to primary agent after finishing assigned contract.
- Primary agent remains source of truth for overall context and final decisions.
- For non-trivial implementation, delegate code writing to `code-agent`.
- For trivial fully-local work, delegate to `code-agent` directly.

## Specialist agent role mapping
- `explore-agent` → repo mapping, cross-file discovery, endpoint tracing, schema tracing, VPS inspection
- `code-agent` → implement approved fixes (edit: allow, bash: ask)
- `review-agent` → read-only review, audit, final review (edit: deny)
- `tdd-agent` → unit test writing, TDD workflow (edit: allow)
- `qa-agent` → validation, regression assessment (edit: deny)
- `report-agent` → weekly reporting, stakeholder summaries (edit: deny)

## Model routing
All agents use `opencode/deepseek-v4-flash-free`. No lane splitting.

## Verification rules
Do not treat change as complete until relevant checks pass:
- Firmware changes: run appropriate build command
- Runtime checks: inspect serial or logs
- Network changes: verify expected Wi-Fi, MQTT, or HTTP behavior
- VPS deploys: verify compose/container state and health endpoint
- Device upload: verify with appropriate serial tool

## Commit and push policy
- Commit only after milestone is verified.
- Keep commits scoped to one technical outcome.
- Push after each successful milestone.
- Do not force-push.
- Do not rewrite history unless user explicitly asks.
- Update `docs/handoff.md` after each verified milestone with: what was confirmed, what changed, remaining issues, exact next step.

## Workspace convention
All projects follow a standard workspace layout. `workspace_root` is stored in `.opencode-machine.json`.

```
{workspace_root}/
  opencode_profile/          # team workspace
  data/                      # data domain projects
    <project>/
  iot/                       # iot domain projects
    <project>/
  web/                       # web domain projects
    <project>/
```

- From any project at `{workspace_root}/<domain>/<project>/`, the team workflow is at `../../opencode_profile/.opencode/workflow.md`.
- From `opencode_profile/`, reference the workflow at `.opencode/workflow.md`.
## Clean Code Principles
All agents must follow the Clean Code principles for AI Agent development documented at `core/clean-code-agents.md`. Key rules:
- Meaningful names for all variables, functions, and tools
- Functions/tools must do one thing only
- Minimize function arguments (0-2 preferred)
- No side effects in functions
- Use DTOs for LLM responses
- Handle errors with Exceptions, not return codes
- Never return or pass null
- Follow SRP (Single Responsibility Principle)
- Follow DRY (No Duplication)
- Follow Boy Scout Rule (leave code cleaner)
- Unit tests must be independent, fast, and mock LLM API calls

- Resolve `workspace_root` from `.opencode-machine.json` in the opencode_profile root, or from the convention above.
