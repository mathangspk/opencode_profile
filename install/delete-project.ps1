param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId,
  [Parameter(Mandatory = $true)]
  [ValidateSet("error", "duplicate", "sandbox")]
  [string]$Reason,
  [switch]$Force
)

$ErrorActionPreference = "Stop"

if (-not $Force) {
  throw "Delete requires -Force because it removes the project home and registry entry."
}

$profileRoot = Split-Path -Parent $PSScriptRoot
$registryPath = Join-Path $profileRoot "projects/registry/projects.json"

$registry = Get-Content -Raw -Path $registryPath | ConvertFrom-Json
$entry = @($registry.projects | Where-Object { $_.id -eq $ProjectId })

if ($entry.Count -ne 1) {
  throw "Project not found: $ProjectId"
}

$project = $entry[0]
if ($project.lifecycle_status -eq "active") {
  throw "Refusing to delete an active project. Archive it first or change its lifecycle status."
}

$projectHome = Join-Path $profileRoot $project.project_home
if (Test-Path $projectHome) {
  Remove-Item -Recurse -Force $projectHome
}

$registry.projects = @($registry.projects | Where-Object { $_.id -ne $ProjectId })
$registry | ConvertTo-Json -Depth 8 | Set-Content -Path $registryPath
& (Join-Path $PSScriptRoot "refresh-registry-dashboard.ps1")

Write-Host "Deleted project: $ProjectId"
Write-Host "Reason: $Reason"
