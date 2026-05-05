$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$files = @(
  "README.md",
  "core/review-policy.md",
  "core/report-principles.md",
  "agents/explore-agent.md",
  "agents/code-agent.md",
  "agents/review-agent.md",
  "agents/qa-agent.md",
  "agents/report-agent.md",
  "scaffolds/opencode-project/opencode.json",
  "install/install-project-scaffold.ps1",
  "install/install-project-scaffold.sh",
  "scaffolds/opencode-project/.opencode/agents/orchestrator.md",
  "scaffolds/opencode-project/.opencode/agents/explore-agent.md",
  "scaffolds/opencode-project/.opencode/agents/code-agent.md",
  "scaffolds/opencode-project/.opencode/agents/review-agent.md",
  "scaffolds/opencode-project/.opencode/agents/qa-agent.md",
  "scaffolds/opencode-project/.opencode/agents/report-agent.md",
  "templates/explore-summary-template.md",
  "templates/code-handoff-template.md",
  "templates/review-findings-template.md",
  "templates/qa-report-template.md",
  "workflows/explore-project.md",
  "workflows/implement-task.md",
  "workflows/new-project-checklist.md",
  "workflows/review-code-and-architecture.md",
  "workflows/test-and-validate.md",
  "workflows/primary-orchestration.md",
  "workflows/report-weekly.md",
  "integrations/jira/weekly-comment-template.md",
  "integrations/notion/weekly-toggle-template.md",
  "projects/_templates/project-profile.md",
  "projects/registry/projects-index.md"
)

$missing = @()
foreach ($file in $files) {
  $path = Join-Path $root $file
  if (-not (Test-Path $path)) {
    $missing += $file
  }
}

if ($missing.Count -gt 0) {
  Write-Error ("Missing files:`n - " + ($missing -join "`n - "))
  exit 1
}

Write-Host "Verification passed. Profile is ready for customization."
