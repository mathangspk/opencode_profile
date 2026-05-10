param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId
)

$ErrorActionPreference = "Stop"

$profileRoot = Split-Path -Parent $PSScriptRoot
$registryPath = Join-Path $profileRoot "projects/registry/projects.json"

$registry = Get-Content -Raw -Path $registryPath | ConvertFrom-Json
$project = @($registry.projects | Where-Object { $_.id -eq $ProjectId })

if ($project.Count -ne 1) {
  throw "Project not found: $ProjectId"
}

$entry = $project[0]
if ($entry.lifecycle_status -eq "deleted") {
  throw "Deleted projects cannot be archived."
}

$entry.lifecycle_status = "archived"
$entry.execution_status = "inactive"

$statePath = Join-Path $profileRoot "$($entry.project_home)/ops/state.json"
if (Test-Path $statePath) {
  $state = Get-Content -Raw -Path $statePath | ConvertFrom-Json
  $state.lifecycle_status = "archived"
  $state.execution_status = "inactive"
  $state | ConvertTo-Json -Depth 8 | Set-Content -Path $statePath
}

$registry | ConvertTo-Json -Depth 8 | Set-Content -Path $registryPath
& (Join-Path $PSScriptRoot "refresh-registry-dashboard.ps1")

Write-Host "Archived project: $ProjectId"
