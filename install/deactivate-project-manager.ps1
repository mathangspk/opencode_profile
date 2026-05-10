param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId
)

$ErrorActionPreference = "Stop"

$profileRoot = Split-Path -Parent $PSScriptRoot
$machineFile = Join-Path $profileRoot ".opencode-machine.json"
$activationDir = Join-Path $profileRoot "projects/registry/activations"

if (-not (Test-Path $machineFile)) {
  throw "Missing machine identity file. Run install/init-machine.ps1 first."
}

$machine = Get-Content -Raw -Path $machineFile | ConvertFrom-Json
$activationPath = Join-Path $activationDir ("{0}.json" -f $machine.machine_id)

if (-not (Test-Path $activationPath)) {
  Write-Host "No activation file exists for $($machine.machine_id)."
  exit 0
}

$activation = Get-Content -Raw -Path $activationPath | ConvertFrom-Json
$activation.projects = @($activation.projects | Where-Object { $_.project_id -ne $ProjectId })

if ($activation.projects.Count -eq 0) {
  Remove-Item -Force $activationPath
  Write-Host "Removed last activation for $($machine.machine_id)."
} else {
  $activation.updated_at = (Get-Date).ToString("o")
  $activation | ConvertTo-Json -Depth 8 | Set-Content -Path $activationPath
}

& (Join-Path $PSScriptRoot "refresh-activations-dashboard.ps1")
Write-Host "Deactivated project manager for $ProjectId on $($machine.machine_id)"
