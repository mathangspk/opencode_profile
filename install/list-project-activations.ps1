param()

$ErrorActionPreference = "Stop"

$profileRoot = Split-Path -Parent $PSScriptRoot
$activationDir = Join-Path $profileRoot "projects/registry/activations"

if (-not (Test-Path $activationDir)) {
  Write-Host "No activation directory found."
  exit 0
}

$files = Get-ChildItem -Path $activationDir -Filter *.json -File -ErrorAction SilentlyContinue
$rows = @()
foreach ($file in $files) {
  $content = Get-Content -Raw -Path $file.FullName | ConvertFrom-Json
  foreach ($project in @($content.projects)) {
    $rows += [pscustomobject]@{
      Project = $project.project_id
      MachineId = $content.machine_id
      MachineName = $content.machine_name
      LastSeen = $project.last_seen_at
      Status = $project.status
    }
  }
}

if ($rows.Count -eq 0) {
  Write-Host "No active project-manager registrations found."
  exit 0
}

$rows | Sort-Object Project, MachineId | Format-Table -AutoSize

$multiMachine = @($rows | Group-Object Project | Where-Object { $_.Count -gt 1 })
if ($multiMachine.Count -gt 0) {
  Write-Host ""
  Write-Host "Projects active on multiple machines"
  foreach ($group in $multiMachine) {
    Write-Host "- $($group.Name): $($group.Count) machines"
  }
}
