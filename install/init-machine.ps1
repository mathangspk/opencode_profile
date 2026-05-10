param(
  [string]$MachineId,
  [string]$MachineName,
  [string]$Owner = $env:USERNAME
)

$ErrorActionPreference = "Stop"

$profileRoot = Split-Path -Parent $PSScriptRoot
$machineFile = Join-Path $profileRoot ".opencode-machine.json"

$resolvedMachineName = if ([string]::IsNullOrWhiteSpace($MachineName)) { $env:COMPUTERNAME } else { $MachineName }
if ([string]::IsNullOrWhiteSpace($resolvedMachineName)) {
  $resolvedMachineName = [System.Net.Dns]::GetHostName()
}

$resolvedMachineName = $resolvedMachineName.ToUpper()
$resolvedMachineId = if ([string]::IsNullOrWhiteSpace($MachineId)) { "WIN-$resolvedMachineName" } else { $MachineId.ToUpper() }

$payload = [pscustomobject]@{
  machine_id = $resolvedMachineId
  machine_name = $resolvedMachineName
  platform = "windows"
  owner = $Owner
  created_at = (Get-Date).ToString("o")
}

$payload | ConvertTo-Json -Depth 4 | Set-Content -Path $machineFile
Write-Host "Initialized machine identity at $machineFile"
Write-Host "Machine id: $resolvedMachineId"
