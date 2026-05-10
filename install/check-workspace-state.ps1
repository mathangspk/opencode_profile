param(
  [ValidateSet("quick", "full")]
  [string]$Mode = "quick"
)

$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "start-session.ps1") -Mode $Mode -SkipWorkspaceSync
