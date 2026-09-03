# Install Unicode Remover Skill for Claude Code
# This script sets up the unicode-remover skill for use in Claude Code sessions

param(
    [string]$ClaudeSkillsPath = "$env:USERPROFILE\.claude\skills"
)

Write-Host "Installing Unicode Remover Skill for Claude Code" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Verify Python is available
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✓ Python detected: $pythonVersion" -ForegroundColor Green
}
catch {
    Write-Host "✗ Python not found in PATH" -ForegroundColor Red
    Write-Host "  Install Python 3.x and add to PATH" -ForegroundColor Yellow
    exit 1
}

# Verify unicode_replacer.py exists
$scriptPath = "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py"
if (Test-Path $scriptPath) {
    Write-Host "✓ Unicode replacer script found" -ForegroundColor Green
}
else {
    Write-Host "✗ Unicode replacer script not found at: $scriptPath" -ForegroundColor Red
    exit 1
}

# Create Claude skills directory if it doesn't exist
if (!(Test-Path $ClaudeSkillsPath)) {
    Write-Host "Creating Claude skills directory: $ClaudeSkillsPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ClaudeSkillsPath -Force | Out-Null
}

# Copy skill to Claude skills directory
$targetPath = Join-Path $ClaudeSkillsPath "unicode-remover"
if (Test-Path $targetPath) {
    Write-Host "Updating existing skill at: $targetPath" -ForegroundColor Yellow
    Remove-Item $targetPath -Recurse -Force
}

$sourcePath = Split-Path -Parent $PSCommandPath
Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force

Write-Host "✓ Skill installed to: $targetPath" -ForegroundColor Green
Write-Host ""

# Create a symlink to the Python script for easy access (optional)
$skillScriptLink = Join-Path $targetPath "unicode_replacer.py"
if (!(Test-Path $skillScriptLink)) {
    try {
        # Create a copy rather than symlink (more reliable on Windows)
        Copy-Item $scriptPath $skillScriptLink -Force
        Write-Host "✓ Python script linked to skill directory" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Could not link Python script (non-critical)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage in Claude Code:" -ForegroundColor Cyan
Write-Host "  1. Start Claude Code in your project directory" -ForegroundColor White
Write-Host "  2. Ask: 'Use the unicode-remover skill to clean my PowerShell files'" -ForegroundColor White
Write-Host "  3. Claude will automatically invoke the skill" -ForegroundColor White
Write-Host ""
Write-Host "Manual invocation:" -ForegroundColor Cyan
Write-Host "  python `"$scriptPath`" `"<filepath>`" --no-backup" -ForegroundColor White
Write-Host ""
Write-Host "Skill location: $targetPath\SKILL.md" -ForegroundColor Gray
