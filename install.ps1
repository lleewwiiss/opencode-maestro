# OpenCode Maestro Installer for Windows PowerShell
# Usage: iwr https://raw.githubusercontent.com/DorelRoata/opencode-maestro/main/install.ps1 | iex

param(
    [switch]$Global,
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\install.ps1 [-Global] [-Help]"
    Write-Host "  -Global  Install to ~\.config\opencode instead of .\.opencode"
    Write-Host "  -Help    Show this help message"
    exit 0
}

# Configuration
$GitHubUser = "DorelRoata"
$GitHubRepo = "opencodeagents"
$Branch = "main"
$BaseUrl = "https://raw.githubusercontent.com/$GitHubUser/$GitHubRepo/$Branch/templates/.opencode"

# Determine target directory
if ($Global) {
    $TargetDir = "$env:USERPROFILE\.config\opencode"
    $InstallType = "Global"
} else {
    $TargetDir = ".opencode"
    $InstallType = "Local"
}

Write-Host "Installing OpenCode Agentic Workflow..." -ForegroundColor Cyan
Write-Host "Location: $InstallType ($TargetDir)" -ForegroundColor Gray

# Create directories
Write-Host "Setting up directories..." -ForegroundColor Gray
New-Item -ItemType Directory -Force -Path "$TargetDir\agent" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\command" | Out-Null

# Download function
function Install-File {
    param($Source, $Dest)
    try {
        Invoke-WebRequest -Uri $Source -OutFile $Dest -UseBasicParsing -ErrorAction Stop
        Write-Host "  + $Dest" -ForegroundColor Green
    } catch {
        Write-Host "  x Failed: $Dest" -ForegroundColor Red
    }
}

# Install Agents
Write-Host "Downloading agents..." -ForegroundColor Gray
$Agents = @(
    "codebase-analyzer",
    "codebase-locator",
    "codebase-pattern-finder",
    "code-reviewer",
    "commit-message-writer",
    "test-writer",
    "web-search-researcher"
)
foreach ($Agent in $Agents) {
    Install-File "$BaseUrl/agent/$Agent.md" "$TargetDir\agent\$Agent.md"
}

# Install Commands
Write-Host "Downloading commands..." -ForegroundColor Gray
$Commands = @(
    "create",
    "start",
    "research",
    "plan",
    "iterate",
    "implement",
    "finish",
    "handoff",
    "resume"
)
foreach ($Cmd in $Commands) {
    Install-File "$BaseUrl/command/$Cmd.md" "$TargetDir\command\$Cmd.md"
}

# Install Workflow Doc (local only)
if (-not $Global) {
    Write-Host "Downloading workflow protocol..." -ForegroundColor Gray
    $WorkflowUrl = "https://raw.githubusercontent.com/$GitHubUser/$GitHubRepo/$Branch/AGENTIC_WORKFLOW.md"
    Install-File $WorkflowUrl "AGENTIC_WORKFLOW.md"
}

Write-Host ""
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "Run 'opencode' and type '/create' to get started." -ForegroundColor Cyan
