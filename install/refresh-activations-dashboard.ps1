param()

$ErrorActionPreference = "Stop"

$profileRoot = Split-Path -Parent $PSScriptRoot
$activationDir = Join-Path $profileRoot "projects/registry/activations"
$dashboardPath = Join-Path $profileRoot "projects/registry/activations.md"

if (-not (Test-Path $activationDir)) {
  New-Item -ItemType Directory -Path $activationDir | Out-Null
}

$files = Get-ChildItem -Path $activationDir -Filter *.json -File -ErrorAction SilentlyContinue
$records = @()
foreach ($file in $files) {
  $content = Get-Content -Raw -Path $file.FullName | ConvertFrom-Json
  foreach ($project in @($content.projects)) {
    $records += [pscustomobject]@{
      MachineId = $content.machine_id
      MachineName = $content.machine_name
      ProjectId = $project.project_id
      Status = $project.status
      ActivatedAt = $project.activated_at
      LastSeenAt = $project.last_seen_at
    }
  }
}

$lines = @(
  "# Project Activations",
  "",
  "Generated from `projects/registry/activations/*.json`.",
  ""
)

if ($records.Count -eq 0) {
  $lines += "No active machine registrations yet."
} else {
  $lines += "## By project"
  $lines += ""
  foreach ($group in $records | Group-Object ProjectId | Sort-Object Name) {
    $lines += "- $($group.Name)"
    $lines += "  - active on $($group.Count) machine(s)"
    foreach ($record in $group.Group | Sort-Object MachineId) {
      $lines += "  - $($record.MachineId)"
    }
  }

  $lines += ""
  $lines += "## By machine"
  $lines += ""
  foreach ($group in $records | Group-Object MachineId | Sort-Object Name) {
    $machineName = ($group.Group | Select-Object -First 1).MachineName
    $lines += "- $($group.Name)"
    $lines += "  - machine name: $machineName"
    foreach ($record in $group.Group | Sort-Object ProjectId) {
      $lines += "  - $($record.ProjectId)"
    }
  }
}

Set-Content -Path $dashboardPath -Value ($lines -join [Environment]::NewLine)
