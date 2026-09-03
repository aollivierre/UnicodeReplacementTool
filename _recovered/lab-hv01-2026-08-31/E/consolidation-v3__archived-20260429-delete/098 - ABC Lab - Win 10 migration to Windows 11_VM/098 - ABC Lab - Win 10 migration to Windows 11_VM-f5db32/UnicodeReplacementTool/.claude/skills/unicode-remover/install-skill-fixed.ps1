# Install Unicode Remover Skill for Claude Code
# This script sets up the unicode-remover skill for use in Claude Code sessions

param(
    [string]$ClaudeSkillsPath = "$env:USERPROFILE\.claude\skills"
)

Write-Host "Installing Unicode Remover Skill for Claude Code" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Verify Python is available
Write-Host "Checking Python..." -NoNewline
$pythonCheck = Get-Command python -ErrorAction SilentlyContinue
if ($pythonCheck) {
    $pythonVersion = python --version 2>&1
    Write-Host " OK ($pythonVersion)" -ForegroundColor Green
} else {
    Write-Host " FAILED" -ForegroundColor Red
    Write-Host "  Python not found in PATH" -ForegroundColor Yellow
    Write-Host "  Install Python 3.x and add to PATH" -ForegroundColor Yellow
    exit 1
}

# Verify unicode_replacer.py exists
Write-Host "Checking unicode_replacer.py..." -NoNewline
$scriptPath = "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py"
if (Test-Path $scriptPath) {
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host " FAILED" -ForegroundColor Red
    Write-Host "  Script not found at: $scriptPath" -ForegroundColor Yellow
    exit 1
}

# Create Claude skills directory if it doesn't exist
Write-Host "Checking skills directory..." -NoNewline
if (!(Test-Path $ClaudeSkillsPath)) {
    New-Item -ItemType Directory -Path $ClaudeSkillsPath -Force | Out-Null
    Write-Host " CREATED" -ForegroundColor Yellow
} else {
    Write-Host " OK" -ForegroundColor Green
}

# Copy skill to Claude skills directory
$targetPath = Join-Path $ClaudeSkillsPath "unicode-remover"
Write-Host "Installing skill..." -NoNewline

if (Test-Path $targetPath) {
    Remove-Item $targetPath -Recurse -Force
}

$sourcePath = Split-Path -Parent $PSCommandPath
Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force

Write-Host " DONE" -ForegroundColor Green
Write-Host ""
Write-Host "Skill installed to: $targetPath" -ForegroundColor Cyan
Write-Host ""

Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage in Claude Code:" -ForegroundColor Cyan
Write-Host "  1. Start Claude Code in ANY project directory" -ForegroundColor White
Write-Host "  2. Ask: 'Use the unicode-remover skill to clean my files'" -ForegroundColor White
Write-Host "  3. Claude will automatically invoke the skill" -ForegroundColor White
Write-Host ""
Write-Host "The skill is now globally available for all Claude Code sessions!" -ForegroundColor Green
