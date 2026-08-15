$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$workflowPath = Join-Path $root '.github/workflows/brain-validation.yml'

if (-not (Test-Path $workflowPath)) {
  throw 'Missing Brain validation workflow.'
}

$workflow = Get-Content $workflowPath -Raw
$forbidden = @(
  'deploy-pages',
  'supabase db push',
  'kubectl apply'
)

foreach ($pattern in $forbidden) {
  if ($workflow -match [regex]::Escape($pattern)) {
    throw "Brain validation workflow contains forbidden production action: $pattern"
  }
}

if ($workflow -match 'ssh\s+[^\r\n]+@') {
  throw 'Brain validation workflow must not execute remote SSH commands.'
}

Write-Host 'BRAIN WORKFLOW SAFETY: PASS'
