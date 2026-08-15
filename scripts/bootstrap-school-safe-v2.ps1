param(
    [Parameter(Mandatory = $false)]
    [string]$TargetProject = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [string]$ToolsRoot = "C:\SchoolSafe\AI-TOOLS",

    [Parameter(Mandatory = $false)]
    [switch]$InstallMultiAgent,

    [Parameter(Mandatory = $false)]
    [switch]$InstallSpecialists,

    [Parameter(Mandatory = $false)]
    [switch]$InstallSecurity,

    [Parameter(Mandatory = $false)]
    [switch]$InstallProjectDependencies,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$PackRoot = Split-Path -Parent $PSScriptRoot
$ApprovedToolsPath = Join-Path $PackRoot "config\approved-tools.json"

function Write-Step([string]$Message) {
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Test-Command([string]$Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Write-Plan([string]$Message) {
    if ($DryRun) { Write-Host "DRY-RUN: $Message" -ForegroundColor Yellow }
    else { Write-Host $Message }
}

function Get-ApprovedTools {
    if (-not (Test-Path $ApprovedToolsPath)) {
        throw "Approved tools file not found: $ApprovedToolsPath"
    }
    return (Get-Content $ApprovedToolsPath -Raw | ConvertFrom-Json)
}

function Get-SelectedTools($Catalog) {
    $selected = @($Catalog.tools | Where-Object { $_.activation -eq "default" })
    if ($InstallMultiAgent) {
        $selected += @($Catalog.tools | Where-Object { $_.activation -eq "on-multi-agent-work" })
    }
    if ($InstallSpecialists) {
        $selected += @($Catalog.tools | Where-Object { $_.tier -eq "specialist" })
    }
    if ($InstallSecurity) {
        $selected += @($Catalog.tools | Where-Object { $_.tier -eq "security" })
    }
    return @($selected | Sort-Object name -Unique)
}

function Ensure-PinnedTool($Tool) {
    $destination = Join-Path $ToolsRoot $Tool.name

    if ($Tool.refType -ne "commit") {
        Write-Warning "SKIP $($Tool.name): policy requires an explicitly reviewed stable release before installation."
        return
    }

    if ($Tool.approvedRef -notmatch "^[0-9a-f]{40}$") {
        throw "Invalid approved commit for $($Tool.name): $($Tool.approvedRef)"
    }

    if ($DryRun) {
        Write-Plan "Would ensure $($Tool.name) at $($Tool.approvedRef) in $destination"
        return
    }

    if (Test-Path $destination) {
        if (-not (Test-Path (Join-Path $destination ".git"))) {
            Write-Warning "SKIP $($Tool.name): destination exists but is not a git repository: $destination"
            return
        }

        $current = $null
        try { $current = (git -C $destination rev-parse HEAD 2>$null).Trim() } catch { $current = $null }
        if ($current -eq $Tool.approvedRef) {
            Write-Host "REUSE: $($Tool.name) already pinned at $current"
            return
        }
        if ($current) {
            Write-Warning "REVIEW NEEDED: $($Tool.name) exists at $current, approved ref is $($Tool.approvedRef). No silent update performed."
            return
        }

        Write-Host "RESUME: incomplete repository for $($Tool.name)"
    }
    else {
        New-Item -ItemType Directory -Force -Path $destination | Out-Null
        git -C $destination init | Out-Null
        git -C $destination remote add origin $Tool.repository
    }

    $hasOrigin = git -C $destination remote 2>$null | Where-Object { $_ -eq "origin" }
    if (-not $hasOrigin) { git -C $destination remote add origin $Tool.repository }

    Write-Host "FETCH PINNED: $($Tool.name) @ $($Tool.approvedRef)"
    git -C $destination fetch --depth 1 origin $Tool.approvedRef
    if ($LASTEXITCODE -ne 0) { throw "Failed to fetch approved ref for $($Tool.name). Partial cache preserved for retry." }
    git -C $destination checkout --detach FETCH_HEAD
    if ($LASTEXITCODE -ne 0) { throw "Failed to checkout approved ref for $($Tool.name)." }

    $verified = (git -C $destination rev-parse HEAD).Trim()
    if ($verified -ne $Tool.approvedRef) { throw "Pin verification failed for $($Tool.name): $verified" }
    Write-Host "PINNED: $($Tool.name) @ $verified"
}

Write-Step "SchoolSafe Brain V1 - safe preflight"

if (-not (Test-Path $TargetProject)) {
    throw "Target project not found: $TargetProject"
}

$catalog = Get-ApprovedTools
if ($catalog.policy.humanApprovalRequiredForProduction -ne $true) {
    throw "Brain policy invalid: production approval must remain human-controlled."
}
if ($catalog.policy.silentUpdatesAllowed -ne $false) {
    throw "Brain policy invalid: silent tool updates must remain disabled."
}

Write-Host "Project: $TargetProject"
Write-Host "Tools cache: $ToolsRoot"
Write-Host "Mode: $(if ($DryRun) { 'DRY-RUN' } else { 'APPLY' })"
Write-Host "Project dependency mutation: $(if ($InstallProjectDependencies) { 'EXPLICITLY ENABLED' } else { 'DISABLED' })"

if (-not $DryRun -and -not (Test-Command "git")) {
    throw "Git is required to cache approved repositories."
}

Write-Step "Approved engineering tools"
$selectedTools = Get-SelectedTools $catalog
foreach ($tool in $selectedTools) {
    Ensure-PinnedTool $tool
}

if (-not $InstallProjectDependencies) {
    Write-Step "Application dependencies"
    Write-Host "SKIPPED by design. Brain bootstrap does not modify SchoolSafe application dependencies by default."
}
else {
    Write-Step "Application dependency installation - explicit mode"
    if (-not (Test-Path (Join-Path $TargetProject "package.json"))) {
        throw "package.json not found in target project."
    }
    if (-not (Test-Command "node") -or -not (Test-Command "npm")) {
        throw "Node.js and npm are required for explicit project dependency installation."
    }

    Write-Warning "This mode modifies the target project's package files. Use only on an isolated approved branch/worktree."
    if ($DryRun) {
        Write-Plan "Would install advisory runtime/dev dependencies only after compatibility review."
    }
    else {
        Push-Location $TargetProject
        try {
            $manager = "npm"
            if (Test-Path "pnpm-lock.yaml") { $manager = "pnpm" }
            elseif (Test-Path "yarn.lock") { $manager = "yarn" }

            if ($manager -eq "pnpm" -and (Test-Command "pnpm")) {
                pnpm add @tanstack/react-query zod react-hook-form
                pnpm add -D @biomejs/biome @playwright/test vitest msw axe-core @lhci/cli
            }
            elseif ($manager -eq "yarn" -and (Test-Command "yarn")) {
                yarn add @tanstack/react-query zod react-hook-form
                yarn add -D @biomejs/biome @playwright/test vitest msw axe-core @lhci/cli
            }
            elseif ($manager -eq "npm") {
                npm install @tanstack/react-query zod react-hook-form
                npm install --save-dev @biomejs/biome @playwright/test vitest msw axe-core @lhci/cli
            }
            else {
                throw "Detected package manager '$manager' is unavailable."
            }
        }
        finally {
            Pop-Location
        }
    }
}

Write-Step "Brain validation"
$validator = Join-Path $PSScriptRoot "validate-brain.ps1"
if ($DryRun) {
    Write-Plan "Would run $validator"
}
else {
    & $validator
}

Write-Step "Bootstrap complete"
Write-Host "Default mode modifies only the external tools cache, never SchoolSafe production."
Write-Host "Use -InstallMultiAgent for Orca, -InstallSpecialists for bounded specialist agents, and -InstallSecurity only after reviewing stable releases."
Write-Host "Read 00-CONTEXT.md and CONTROL-TOWER.md before any development task."
