param(
  [ValidateSet("quick", "full")]
  [string]$Mode = "quick",
  [switch]$SkipWorkspaceSync
)

$ErrorActionPreference = "Stop"

$profileRoot = Split-Path -Parent $PSScriptRoot
$machineFile = Join-Path $profileRoot ".opencode-machine.json"
$registryPath = Join-Path $profileRoot "projects/registry/projects.json"
$syncSnapshotPath = Join-Path $profileRoot "projects/registry/machine-sync.md"

function Require-Command {
  param([string]$Name)

  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Required command is missing: $Name"
  }
}

function Get-MachineContext {
  param([string]$Path)

  if (-not (Test-Path $Path)) {
    throw "Missing machine identity file: $Path. Run install/init-machine.ps1 first."
  }

  return Get-Content -Raw -Path $Path | ConvertFrom-Json
}

function Resolve-MachinePath {
  param($Project, [string]$MachineId)

  if ($null -ne $Project.machine_paths) {
    $property = $Project.machine_paths.PSObject.Properties[$MachineId]
    if ($null -ne $property -and -not [string]::IsNullOrWhiteSpace($property.Value)) {
      return [pscustomobject]@{
        path = [string]$property.Value
        source = "machine_paths"
      }
    }
  }

  if (-not [string]::IsNullOrWhiteSpace($Project.local_path)) {
    return [pscustomobject]@{
      path = [string]$Project.local_path
      source = "local_path"
    }
  }

  return [pscustomobject]@{
    path = ""
    source = "missing"
  }
}

function Get-BranchName {
  param([string]$Path)

  $branch = git -C $Path rev-parse --abbrev-ref HEAD 2>$null
  if ($LASTEXITCODE -ne 0) {
    return "unknown"
  }

  return ($branch | Select-Object -First 1)
}

function Get-UpstreamName {
  param([string]$Path)

  $upstream = git -C $Path rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>$null
  if ($LASTEXITCODE -ne 0) {
    return ""
  }

  return ($upstream | Select-Object -First 1)
}

function Invoke-GitSilent {
  param(
    [string]$Path,
    [string[]]$Arguments
  )

  $stdoutPath = [System.IO.Path]::GetTempFileName()
  $stderrPath = [System.IO.Path]::GetTempFileName()

  try {
    $process = Start-Process -FilePath git -ArgumentList (@('-C', $Path) + $Arguments) -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
    return $process.ExitCode
  } finally {
    Remove-Item -Force $stdoutPath, $stderrPath -ErrorAction SilentlyContinue
  }
}

function Get-GitState {
  param(
    [string]$Path,
    [switch]$RefreshRemote
  )

  if (-not (Test-Path $Path)) {
    return [pscustomobject]@{
      branch = ""
      dirty = "missing"
      sync = "missing"
      status = "path-not-found"
      action = "Create or fix the local path before working on this project."
    }
  }

  if (-not (Test-Path (Join-Path $Path ".git"))) {
    return [pscustomobject]@{
      branch = ""
      dirty = "not-a-repo"
      sync = "not-a-repo"
      status = "not-a-repo"
      action = "Clone or initialize the project repo before treating it as managed."
    }
  }

  if ($RefreshRemote) {
    Invoke-GitSilent -Path $Path -Arguments @('fetch', '--all', '--prune') | Out-Null
  }

  $branch = Get-BranchName -Path $Path
  $statusLines = @(git -C $Path status --porcelain --branch 2>$null)
  $dirty = if ($statusLines.Count -gt 1) { "dirty" } else { "clean" }
  $upstream = Get-UpstreamName -Path $Path

  if ([string]::IsNullOrWhiteSpace($upstream)) {
    return [pscustomobject]@{
      branch = $branch
      dirty = $dirty
      sync = "no-remote-tracking"
      status = "no-remote-tracking"
      action = "Add a tracked remote branch so freshness can be verified."
    }
  }

  $counts = git -C $Path rev-list --left-right --count HEAD..."@{u}" 2>$null
  $sync = "unknown"
  $status = if ($dirty -eq "dirty") { "dirty" } else { "ready" }
  $action = if ($dirty -eq "dirty") { "Review local changes before starting new work." } else { "No action required." }

  if ($LASTEXITCODE -eq 0 -and $counts) {
    $parts = ($counts | Select-Object -First 1).Trim() -split "\s+"
    if ($parts.Count -eq 2) {
      $behind = [int]$parts[0]
      $ahead = [int]$parts[1]

      if ($ahead -eq 0 -and $behind -eq 0) {
        $sync = "up-to-date"
      } elseif ($ahead -gt 0 -and $behind -eq 0) {
        $sync = "ahead $ahead"
        $status = "ahead"
        $action = "Push or reconcile local commits when appropriate."
      } elseif ($ahead -eq 0 -and $behind -gt 0) {
        $sync = "behind $behind"
        $status = "behind"
        $action = "Pull the latest changes before starting work."
      } else {
        $sync = "diverged +$ahead/-$behind"
        $status = "diverged"
        $action = "Resolve branch divergence before starting work."
      }
    }
  }

  if ($status -eq "dirty" -and $sync -like "behind*") {
    $status = "dirty-and-behind"
    $action = "Review local changes, then pull the latest remote changes."
  }

  return [pscustomobject]@{
    branch = $branch
    dirty = $dirty
    sync = $sync
    status = $status
    action = $action
  }
}

function Sync-WorkspaceRepo {
  param([string]$Path)

  Invoke-GitSilent -Path $Path -Arguments @('fetch', '--all', '--prune') | Out-Null

  $state = Get-GitState -Path $Path
  if ($state.dirty -eq "clean" -and $state.sync -like "behind*") {
    Invoke-GitSilent -Path $Path -Arguments @('pull', '--ff-only') | Out-Null
    $state = Get-GitState -Path $Path
  }

  return $state
}

Require-Command -Name git

$machine = Get-MachineContext -Path $machineFile
if (-not (Test-Path $registryPath)) {
  throw "Missing registry file: $registryPath"
}

$registry = Get-Content -Raw -Path $registryPath | ConvertFrom-Json
$projects = if ($Mode -eq "full") { @($registry.projects) } else { @($registry.projects | Where-Object { $_.lifecycle_status -in @("active", "paused") }) }

$workspaceState = if ($SkipWorkspaceSync) { Get-GitState -Path $profileRoot -RefreshRemote } else { Sync-WorkspaceRepo -Path $profileRoot }

$rows = foreach ($project in $projects | Sort-Object domain, name) {
  $resolved = Resolve-MachinePath -Project $project -MachineId $machine.machine_id
  if ([string]::IsNullOrWhiteSpace($resolved.path)) {
    [pscustomobject]@{
      Project = $project.name
      Lifecycle = $project.lifecycle_status
      Path = ""
      PathSource = $resolved.source
      Branch = ""
      Dirty = "missing"
      Sync = "missing-machine-path"
      Status = "missing-machine-path"
      Action = "Add this machine path to projects.json before managing the repo on this machine."
    }
    continue
  }

  $gitState = Get-GitState -Path $resolved.path -RefreshRemote
  [pscustomobject]@{
    Project = $project.name
    Lifecycle = $project.lifecycle_status
    Path = $resolved.path
    PathSource = $resolved.source
    Branch = $gitState.branch
    Dirty = $gitState.dirty
    Sync = $gitState.sync
    Status = $gitState.status
    Action = $gitState.action
  }
}

$problemStatuses = @("missing-machine-path", "path-not-found", "not-a-repo", "no-remote-tracking", "behind", "dirty-and-behind", "diverged")
$problems = @($rows | Where-Object { $_.Status -in $problemStatuses })

Write-Host "Team workspace session start"
Write-Host "- Machine id: $($machine.machine_id)"
Write-Host "- Platform: $($machine.platform)"
Write-Host "- Scan mode: $Mode"
Write-Host "- Workspace branch: $($workspaceState.branch)"
Write-Host "- Workspace dirty: $($workspaceState.dirty)"
Write-Host "- Workspace sync: $($workspaceState.sync)"
Write-Host ""
Write-Host "Project freshness"
if ($rows.Count -eq 0) {
  Write-Host "No projects matched the selected mode."
} else {
  $rows | Select-Object Project, Lifecycle, Status, Branch, Dirty, Sync, PathSource | Format-Table -AutoSize
}

if ($problems.Count -gt 0) {
  Write-Host ""
  Write-Host "Attention required"
  foreach ($problem in $problems) {
    Write-Host "- $($problem.Project): $($problem.Action)"
  }
}

$lines = @(
  "# Machine Sync",
  "",
  "Generated by `install/start-session.ps1`.",
  "",
  "- Generated at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
  "- Machine id: ``$($machine.machine_id)``",
  "- Platform: ``$($machine.platform)``",
  "- Scan mode: ``$Mode``",
  "- Team workspace branch: ``$($workspaceState.branch)``",
  "- Team workspace dirty: ``$($workspaceState.dirty)``",
  "- Team workspace sync: ``$($workspaceState.sync)``",
  "",
  "| Project | Lifecycle | Status | Branch | Dirty | Sync | Path Source | Path | Action |",
  "|---|---|---|---|---|---|---|---|---|"
)

foreach ($row in $rows) {
  $lines += "| $($row.Project) | $($row.Lifecycle) | $($row.Status) | $($row.Branch) | $($row.Dirty) | $($row.Sync) | $($row.PathSource) | ``$($row.Path)`` | $($row.Action) |"
}

Set-Content -Path $syncSnapshotPath -Value ($lines -join [Environment]::NewLine)
