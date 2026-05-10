#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

missing=""
for file in \
  README.md \
  core/review-policy.md \
  core/report-principles.md \
  agents/explore-agent.md \
  agents/code-agent.md \
  agents/review-agent.md \
  agents/qa-agent.md \
  agents/report-agent.md \
  scaffolds/opencode-project/opencode.json \
  install/install-project-scaffold.ps1 \
  install/install-project-scaffold.sh \
  scaffolds/opencode-project/.opencode/agents/orchestrator.md \
  scaffolds/opencode-project/.opencode/agents/explore-agent.md \
  scaffolds/opencode-project/.opencode/agents/code-agent.md \
  scaffolds/opencode-project/.opencode/agents/review-agent.md \
  scaffolds/opencode-project/.opencode/agents/qa-agent.md \
  scaffolds/opencode-project/.opencode/agents/report-agent.md \
  templates/explore-summary-template.md \
  templates/code-handoff-template.md \
  templates/review-findings-template.md \
  templates/qa-report-template.md \
  workflows/explore-project.md \
  workflows/implement-task.md \
  workflows/new-project-checklist.md \
  workflows/review-code-and-architecture.md \
  workflows/test-and-validate.md \
  workflows/primary-orchestration.md \
  workflows/new-project-home-checklist.md \
  workflows/report-prepare.md \
  workflows/report-publish.md \
  workflows/report-sync-check.md \
  workflows/report-weekly.md \
  integrations/jira/weekly-comment-template.md \
  integrations/notion/weekly-toggle-template.md \
  projects/_templates/project-profile.md \
  projects/_templates/project-home/profile.md \
  projects/_templates/project-home/reporting/config.json \
  projects/registry/projects-index.md \
  projects/registry/projects.json \
  projects/registry/activations.md \
  workspace/sessions/start-session.md \
  workspace/sessions/first-run.md \
  workspace/sessions/end-session.md \
  workspace/state/lifecycle-policy.md \
  workspace/state/machine-activation-policy.md \
  install/check-workspace-state.ps1 \
  install/start-session.ps1 \
  install/start-session.sh \
  install/init-machine.ps1 \
  install/init-machine.sh \
  install/new-project-home.ps1 \
  install/new-project-home.sh \
  install/archive-project.ps1 \
  install/delete-project.ps1 \
  install/refresh-registry-dashboard.ps1 \
  install/refresh-registry-dashboard.sh \
  install/activate-project-manager.ps1 \
  install/activate-project-manager.sh \
  install/deactivate-project-manager.ps1 \
  install/deactivate-project-manager.sh \
  install/list-project-activations.ps1 \
  install/list-project-activations.sh \
  install/refresh-activations-dashboard.ps1 \
  install/refresh-activations-dashboard.sh
do
  if [ ! -e "$ROOT/$file" ]; then
    missing="$missing\n - $file"
  fi
done

if [ -n "$missing" ]; then
  printf 'Missing files:%b\n' "$missing" >&2
  exit 1
fi

printf 'Verification passed. Profile is ready for customization.\n'
