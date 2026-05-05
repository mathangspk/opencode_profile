$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Write-Host "Bootstrapping opencode_profile from $root"

$required = @(
  "core",
  "workflows",
  "integrations",
  "agents",
  "projects",
  "install"
)

foreach ($item in $required) {
  $path = Join-Path $root $item
  if (-not (Test-Path $path)) {
    throw "Missing required path: $path"
  }
}

Write-Host "Structure check passed."
Write-Host "Next steps:"
Write-Host "1. Fill project profiles under projects/."
Write-Host "2. Update projects/registry/projects-index.md."
Write-Host "3. Run ./install/verify.ps1."
