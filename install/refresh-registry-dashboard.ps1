param()

$ErrorActionPreference = "Stop"

$profileRoot = Split-Path -Parent $PSScriptRoot
$registryDir = Join-Path $profileRoot "projects/registry"
$registryPath = Join-Path $registryDir "projects.json"

if (-not (Test-Path $registryPath)) {
  throw "Missing registry file: $registryPath"
}

$registry = Get-Content -Raw -Path $registryPath | ConvertFrom-Json
$projects = @($registry.projects)

function Format-Value {
  param([string]$Value, [string]$Default = "TBD")

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $Default
  }

  return $Value
}

$indexLines = @(
  "# Projects Index",
  "",
  "Generated from `projects/registry/projects.json`.",
  "",
  "| Project | Domain | Lifecycle | Execution | Phase | Report Day | Jira Epic | Approval | Project Home | Repo | Local Path | Last Handoff |",
  "|---|---|---|---|---|---|---|---|---|---|---|---|"
)

foreach ($project in $projects | Sort-Object domain, name) {
  $execution = Format-Value $project.execution_status ""
  $phase = Format-Value $project.phase ""
  $reportDay = Format-Value $project.report_day ""
  $jiraEpic = Format-Value $project.jira_epic_key
  $approval = Format-Value $project.approval_sensitivity ""
  $repoUrl = Format-Value $project.repo_url ""
  $lastHandoff = Format-Value $project.last_handoff ""
  $indexLines += "| $($project.name) | $($project.domain) | $($project.lifecycle_status) | $execution | $phase | $reportDay | $jiraEpic | $approval | ``$($project.project_home)`` | $repoUrl | ``$($project.local_path)`` | $lastHandoff |"
}

Set-Content -Path (Join-Path $registryDir "projects-index.md") -Value ($indexLines -join [Environment]::NewLine)

$activeLines = @(
  "# Active Projects",
  "",
  "Generated from `projects/registry/projects.json`.",
  "",
  "## Active and paused workset",
  ""
)

$activeProjects = @($projects | Where-Object { $_.lifecycle_status -in @("active", "paused") })
if ($activeProjects.Count -eq 0) {
  $activeLines += "No active or paused projects."
} else {
  $i = 1
  foreach ($project in $activeProjects | Sort-Object domain, name) {
    $jiraEpic = Format-Value $project.jira_epic_key
    $notionPage = Format-Value $project.notion_page_link
    $phase = Format-Value $project.phase ""
    $approval = Format-Value $project.approval_sensitivity ""
    $qaMode = Format-Value $project.qa_mode ""
    $focus = Format-Value $project.current_focus ""
    $activeLines += "$i. $($project.name)"
    $activeLines += "   - Lifecycle: ``$($project.lifecycle_status)``"
    $activeLines += "   - Jira Epic: ``$jiraEpic``"
    $activeLines += "   - Notion page: ``$notionPage``"
    $activeLines += "   - Phase: ``$phase``"
    $activeLines += "   - Approval sensitivity: ``$approval``"
    $activeLines += "   - QA mode: ``$qaMode``"
    $activeLines += "   - Current focus: $focus"
    $i++
  }
}

Set-Content -Path (Join-Path $registryDir "active.md") -Value ($activeLines -join [Environment]::NewLine)

$archivedLines = @(
  "# Archived Projects",
  "",
  "Generated from `projects/registry/projects.json`.",
  ""
)

$archivedProjects = @($projects | Where-Object { $_.lifecycle_status -eq "archived" })
if ($archivedProjects.Count -eq 0) {
  $archivedLines += "No archived projects."
} else {
  foreach ($project in $archivedProjects | Sort-Object domain, name) {
    $lastPublished = Format-Value $project.last_report_published ""
    $archivedLines += "- $($project.name)"
    $archivedLines += "  - Project home: ``$($project.project_home)``"
    $archivedLines += "  - Last published: ``$lastPublished``"
  }
}

Set-Content -Path (Join-Path $registryDir "archived.md") -Value ($archivedLines -join [Environment]::NewLine)

$reportDueLines = @(
  "# Report Due",
  "",
  "Generated from `projects/registry/projects.json`.",
  "",
  "## Weekly cadence",
  ""
)

$reportProjects = @($projects | Where-Object { $_.lifecycle_status -eq "active" })
if ($reportProjects.Count -eq 0) {
  $reportDueLines += "No active projects."
} else {
  foreach ($project in $reportProjects | Sort-Object report_day, name) {
    $reportDay = Format-Value $project.report_day "Friday"
    $reportDueLines += "- ${reportDay}: $($project.name)"
  }
}

Set-Content -Path (Join-Path $registryDir "report-due.md") -Value ($reportDueLines -join [Environment]::NewLine)
