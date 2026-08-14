param(
    [Parameter(Mandatory = $false)]
    [string]$TargetProject = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [string]$ToolsRoot = "C:\SchoolSafe\AI-TOOLS"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Write-Step([string]$Message) {
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Test-Command([string]$Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Clone-Once([string]$Url, [string]$FolderName) {
    $destination = Join-Path $ToolsRoot $FolderName
    if (Test-Path $destination) {
        Write-Host "REUSE: $destination"
        return
    }

    Write-Host "DOWNLOAD: $Url"
    git clone --depth 1 $Url $destination
}

Write-Step "School Safe V2 - preflight"

if (-not (Test-Path $TargetProject)) {
    throw "Target project not found: $TargetProject"
}

if (-not (Test-Command "git")) {
    throw "Git is required but was not found in PATH."
}

if (-not (Test-Command "node")) {
    throw "Node.js is required but was not found in PATH."
}

if (-not (Test-Command "npm")) {
    throw "npm is required but was not found in PATH."
}

if (-not (Test-Command "codex")) {
    throw "Codex CLI is required. Install @openai/codex first."
}

Write-Host "Project: $TargetProject"
Write-Host "Tools cache: $ToolsRoot"
Write-Host "Node: $(node --version)"
Write-Host "npm: $(npm --version)"
Write-Host "Codex: $(codex --version)"

Write-Step "Create reusable local cache"
New-Item -ItemType Directory -Force -Path $ToolsRoot | Out-Null

Write-Step "Download core repositories once"
Clone-Once "https://github.com/github/spec-kit.git" "spec-kit"
Clone-Once "https://github.com/obra/superpowers.git" "superpowers"
Clone-Once "https://github.com/yamadashy/repomix.git" "repomix"
Clone-Once "https://github.com/Untrivial-ai/agent-orchestrator.git" "agent-orchestrator"

Write-Step "Download security repositories once"
Clone-Once "https://github.com/semgrep/semgrep.git" "semgrep"
Clone-Once "https://github.com/aquasecurity/trivy.git" "trivy"
Clone-Once "https://github.com/betterleaks/betterleaks.git" "betterleaks"
Clone-Once "https://github.com/AikidoSec/safe-chain.git" "safe-chain"

Write-Step "Detect School Safe V2 package manager"
Push-Location $TargetProject
try {
    if (-not (Test-Path "package.json")) {
        Write-Warning "No package.json found. Frontend dependencies were not installed. Codex must inspect the project first."
    }
    else {
        $manager = "npm"
        if (Test-Path "pnpm-lock.yaml") { $manager = "pnpm" }
        elseif (Test-Path "yarn.lock") { $manager = "yarn" }

        Write-Host "Package manager detected: $manager"

        $runtimePackages = @(
            "@tanstack/react-query",
            "zod",
            "react-hook-form"
        )

        $devPackages = @(
            "@biomejs/biome",
            "@playwright/test",
            "vitest",
            "msw",
            "axe-core",
            "@lhci/cli"
        )

        if ($manager -eq "pnpm") {
            if (-not (Test-Command "pnpm")) {
                Write-Warning "pnpm lockfile found but pnpm command is unavailable. Skipping dependency install."
            }
            else {
                pnpm add @tanstack/react-query zod react-hook-form
                pnpm add -D @biomejs/biome @playwright/test vitest msw axe-core @lhci/cli
            }
        }
        elseif ($manager -eq "yarn") {
            if (-not (Test-Command "yarn")) {
                Write-Warning "yarn lockfile found but yarn command is unavailable. Skipping dependency install."
            }
            else {
                yarn add @tanstack/react-query zod react-hook-form
                yarn add -D @biomejs/biome @playwright/test vitest msw axe-core @lhci/cli
            }
        }
        else {
            npm install @tanstack/react-query zod react-hook-form
            npm install --save-dev @biomejs/biome @playwright/test vitest msw axe-core @lhci/cli
        }
    }
}
finally {
    Pop-Location
}

Write-Step "Bootstrap complete"
Write-Host "Core repositories are cached locally."
Write-Host "Compatible npm packages were installed when possible."
Write-Host "Next: open Codex in School Safe V2 and follow codex/MASTER-INSTALL-PROMPT.md from this pack."
Write-Host "Do not merge, push, deploy, or modify production services until final review."
