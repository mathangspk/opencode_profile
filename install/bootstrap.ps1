$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Write-Host "Bootstrapping opencode_profile from $root"

$required = @(
  "core",
  "workflows",
  "integrations",
  "agents",
  "projects",
  "install",
  "workspace",
  "scaffolds"
)

foreach ($item in $required) {
  $path = Join-Path $root $item
  if (-not (Test-Path $path)) {
    throw "Missing required path: $path"
  }
}

Write-Host "Structure check passed."
Write-Host "Next steps:"
Write-Host "1. Run ./install/verify.ps1."
Write-Host "2. Run ./install/init-machine.ps1."
Write-Host "3. Run ./install/start-session.ps1 -Mode full."
