param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId
)

$ErrorActionPreference = "Stop"

$profileRoot = Split-Path -Parent $PSScriptRoot
$machineFile = Join-Path $profileRoot ".opencode-machine.json"
$registryPath = Join-Path $profileRoot "projects/registry/projects.json"
$activationDir = Join-Path $profileRoot "projects/registry/activations"

if (-not (Test-Path $machineFile)) {
  throw "Missing machine identity file. Run install/init-machine.ps1 first."
}

$machine = Get-Content -Raw -Path $machineFile | ConvertFrom-Json
$registry = Get-Content -Raw -Path $registryPath | ConvertFrom-Json
$project = @($registry.projects | Where-Object { $_.id -eq $ProjectId })
if ($project.Count -ne 1) {
  throw "Project not found: $ProjectId"
}

if (-not (Test-Path $activationDir)) {
  New-Item -ItemType Directory -Path $activationDir | Out-Null
}

$activationPath = Join-Path $activationDir ("{0}.json" -f $machine.machine_id)
$now = (Get-Date).ToString("o")

if (Test-Path $activationPath) {
  $activation = Get-Content -Raw -Path $activationPath | ConvertFrom-Json
} else {
  $activation = [pscustomobject]@{
    machine_id = $machine.machine_id
    machine_name = $machine.machine_name
    platform = $machine.platform
    updated_at = $now
    projects = @()
  }
}

$existing = @($activation.projects | Where-Object { $_.project_id -eq $ProjectId })
if ($existing.Count -eq 1) {
  $existing[0].last_seen_at = $now
  $existing[0].status = "active"
} else {
  $activation.projects += [pscustomobject]@{
    project_id = $ProjectId
    activated_at = $now
    last_seen_at = $now
    status = "active"
  }
}

$activation.updated_at = $now
$activation | ConvertTo-Json -Depth 8 | Set-Content -Path $activationPath
& (Join-Path $PSScriptRoot "refresh-activations-dashboard.ps1")

Write-Host "Activated project manager for $ProjectId on $($machine.machine_id)"
