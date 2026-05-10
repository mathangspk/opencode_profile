param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId,
  [Parameter(Mandatory = $true)]
  [ValidateSet("data", "web", "iot")]
  [string]$Domain,
  [string]$LocalPath = "",
  [string]$RepoUrl = "",
  [string]$JiraEpicKey = "",
  [string]$NotionPageLink = "",
  [ValidateSet("planned", "active", "paused")]
  [string]$LifecycleStatus = "planned",
  [string]$Phase = "discovery",
  [ValidateSet("low", "medium", "high")]
  [string]$ApprovalSensitivity = "medium"
)

$ErrorActionPreference = "Stop"

$profileRoot = Split-Path -Parent $PSScriptRoot
$templateRoot = Join-Path $profileRoot "projects/_templates/project-home"
$projectRoot = Join-Path $profileRoot "projects/$Domain/$ProjectId"
$registryPath = Join-Path $profileRoot "projects/registry/projects.json"
$machineFile = Join-Path $profileRoot ".opencode-machine.json"

if (Test-Path $projectRoot) {
  throw "Project home already exists: $projectRoot"
}

if (-not (Test-Path $templateRoot)) {
  throw "Missing template root: $templateRoot"
}

Copy-Item -Recurse -Force $templateRoot $projectRoot

$profilePath = Join-Path $projectRoot "profile.md"
$profileText = Get-Content -Raw -Path $profilePath
$profileText = $profileText.Replace('- Project name:', "- Project name: $ProjectId")
$profileText = $profileText.Replace('- Domain: `data` | `web` | `iot`', "- Domain: ``$Domain``")
$profileText = $profileText.Replace('- Status: `planned` | `active` | `paused` | `done` | `archived`', "- Status: ``$LifecycleStatus``")
$profileText = $profileText.Replace('- Repo URL:', "- Repo URL: $RepoUrl")
$profileText = $profileText.Replace('- Local path:', "- Local path: ``$LocalPath``")
$profileText = $profileText.Replace('- Current phase:', "- Current phase: $Phase")
$profileText = $profileText.Replace('- Approval sensitivity: `low` | `medium` | `high`', "- Approval sensitivity: ``$ApprovalSensitivity``")
$profileText = $profileText.Replace('- Team project ref:', "- Team project ref: ``projects/$Domain/$ProjectId``")
$profileText = $profileText.Replace('- QA mode: `data` | `web` | `iot`', "- QA mode: ``$Domain``")
Set-Content -Path $profilePath -Value $profileText

$configPath = Join-Path $projectRoot "reporting/config.json"
$config = Get-Content -Raw -Path $configPath | ConvertFrom-Json
$config.project.name = $ProjectId
$config.project.domain = $Domain
$config.sources.local_path = $LocalPath
$config.sources.repo_url = $RepoUrl
$config.sources.jira_epic_key = $JiraEpicKey
$config.sources.notion_page_link = $NotionPageLink
$config | ConvertTo-Json -Depth 8 | Set-Content -Path $configPath

$statePath = Join-Path $projectRoot "ops/state.json"
$state = Get-Content -Raw -Path $statePath | ConvertFrom-Json
$state.lifecycle_status = $LifecycleStatus
$state.execution_status = if ($LifecycleStatus -eq "active") { "in-progress" } else { "not-started" }
$state.current_focus = ""
$state | ConvertTo-Json -Depth 8 | Set-Content -Path $statePath

$registry = Get-Content -Raw -Path $registryPath | ConvertFrom-Json
if (@($registry.projects | Where-Object { $_.id -eq $ProjectId }).Count -gt 0) {
  throw "Project id already exists in registry: $ProjectId"
}

$entry = [pscustomobject]@{
  id = $ProjectId
  name = $ProjectId
  domain = $Domain
  lifecycle_status = $LifecycleStatus
  execution_status = $state.execution_status
  priority = "medium"
  phase = $Phase
  report_day = "Friday"
  approval_sensitivity = $ApprovalSensitivity
  qa_mode = $Domain
  project_home = "projects/$Domain/$ProjectId"
  repo_url = $RepoUrl
  repo_required = $true
  machine_paths = [pscustomobject]@{}
  local_path = $LocalPath
  default_branch = "main"
  jira_epic_key = $JiraEpicKey
  jira_epic_url = ""
  notion_page_link = $NotionPageLink
  notion_page_id = ""
  current_focus = ""
  last_team_sync = ""
  last_repo_sync = ""
  last_handoff = ""
  last_report_draft = ""
  last_report_published = ""
  delete_reason = ""
}

if ((Test-Path $machineFile) -and -not [string]::IsNullOrWhiteSpace($LocalPath)) {
  $machine = Get-Content -Raw -Path $machineFile | ConvertFrom-Json
  $entry.machine_paths | Add-Member -NotePropertyName $machine.machine_id -NotePropertyValue $LocalPath
}

$registry.projects += $entry
$registry | ConvertTo-Json -Depth 8 | Set-Content -Path $registryPath

& (Join-Path $PSScriptRoot "refresh-registry-dashboard.ps1")

Write-Host "Created project home: $projectRoot"
