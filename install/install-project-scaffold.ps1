param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectPath,
  [switch]$Force
)

$ErrorActionPreference = "Stop"

$profileRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $profileRoot "scaffolds/opencode-project"

if (-not (Test-Path $ProjectPath)) {
  throw "Project path does not exist: $ProjectPath"
}

$projectRoot = (Resolve-Path $ProjectPath).Path
$targets = @(
  @{ Source = Join-Path $sourceRoot "opencode.json"; Destination = Join-Path $projectRoot "opencode.json" },
  @{ Source = Join-Path $sourceRoot ".opencode"; Destination = Join-Path $projectRoot ".opencode" }
)

foreach ($target in $targets) {
  if ((Test-Path $target.Destination) -and -not $Force) {
    throw "Target already exists: $($target.Destination). Re-run with -Force to overwrite."
  }
}

foreach ($target in $targets) {
  if (Test-Path $target.Destination) {
    Remove-Item -Recurse -Force $target.Destination
  }

  Copy-Item -Recurse -Force $target.Source $target.Destination
}

Write-Host "Installed OpenCode project scaffold into $projectRoot"
Write-Host "Next steps:"
Write-Host "1. Run opencode and verify 'orchestrator' is the default agent."
Write-Host "2. Fill your project profile in opencode_profile/projects/."
Write-Host "3. Run the new-project checklist."
