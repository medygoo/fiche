$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$requiredConfig = Join-Path $root 'config/brain-required-files.json'
$toolsConfig = Join-Path $root 'config/approved-tools.json'
$agentsConfig = Join-Path $root 'agents/agent-catalog.json'

if (-not (Test-Path $requiredConfig)) { throw 'Missing config/brain-required-files.json' }
$required = Get-Content $requiredConfig -Raw | ConvertFrom-Json
foreach ($relative in $required.requiredFiles) {
  $path = Join-Path $root $relative
  if (-not (Test-Path $path)) { throw "Missing required Brain file: $relative" }
}

$tools = Get-Content $toolsConfig -Raw | ConvertFrom-Json
$agents = Get-Content $agentsConfig -Raw | ConvertFrom-Json
if ($tools.policy.humanApprovalRequiredForProduction -ne $true) { throw 'Production human approval must remain enabled.' }
if ($tools.policy.silentUpdatesAllowed -ne $false) { throw 'Silent tool updates must remain disabled.' }
if ($tools.policy.vendorIntoApplication -ne $false) { throw 'External repositories must not be vendored into the application.' }

$core = @($tools.tools | Where-Object { $_.tier -eq 'core' })
if ($core.Count -lt 4) { throw 'At least four approved core engineering tools are required.' }
foreach ($tool in $core) {
  if ([string]::IsNullOrWhiteSpace($tool.approvedRef)) { throw "Core tool missing approvedRef: $($tool.name)" }
  if ($tool.refType -ne 'commit') { throw "Core tool must be pinned to an exact commit: $($tool.name)" }
  if ($tool.approvedRef -notmatch '^[0-9a-f]{40}$') { throw "Invalid core commit ref: $($tool.name)" }
}

if (@($agents.agents).Count -lt 10) { throw 'Agent catalog is incomplete.' }
$lawPath = Join-Path $root 'governance/SCHOOLSAFE-LAWS.md'
$laws = Get-Content $lawPath -Raw
foreach ($heading in @('Loi 0','Loi 1','Loi 2','Loi 3','Loi 4','Loi 5','Loi 6')) {
  if ($laws -notmatch [regex]::Escape($heading)) { throw "Missing governance law: $heading" }
}

Write-Host 'SCHOOLSAFE BRAIN VALIDATION: PASS'
Write-Host "Required files: $($required.requiredFiles.Count)"
Write-Host "Agents: $(@($agents.agents).Count)"
Write-Host "Core tools pinned: $($core.Count)"
