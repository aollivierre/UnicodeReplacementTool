# Setup RunOnSave for Unicode Replacement in Current Workspace
# Run this script in any folder where you want automatic unicode replacement on save

param(
    [string]$WorkspacePath = "."
)

$vscodePath = Join-Path $WorkspacePath ".vscode"
$settingsPath = Join-Path $vscodePath "settings.json"
$unicodeReplacerPath = "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py"

Write-Host "Setting up RunOnSave for Unicode Replacement" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Verify unicode_replacer.py exists
if (!(Test-Path $unicodeReplacerPath)) {
    Write-Host "ERROR: unicode_replacer.py not found at: $unicodeReplacerPath" -ForegroundColor Red
    exit 1
}

# Create .vscode directory if it doesn't exist
if (!(Test-Path $vscodePath)) {
    Write-Host "Creating .vscode directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $vscodePath | Out-Null
}

# Check if settings.json exists
$existingSettings = @{}
if (Test-Path $settingsPath) {
    Write-Host "Reading existing settings.json..." -ForegroundColor Yellow
    try {
        $existingSettings = Get-Content $settingsPath -Raw | ConvertFrom-Json -AsHashtable
    }
    catch {
        Write-Host "WARNING: Could not parse existing settings.json. Creating backup..." -ForegroundColor Yellow
        $backupPath = "$settingsPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $settingsPath $backupPath
        Write-Host "Backup created: $backupPath" -ForegroundColor Green
    }
}

# Add/Update RunOnSave settings
$runOnSaveConfig = @{
    "emeraldwalk.runonsave" = @{
        commands = @(
            @{
                match = "\\.(ps1|psm1|psd1)$"
                cmd = "python `"$unicodeReplacerPath`" `"`${file}`" --no-backup"
                isAsync = $false
                notInTerminal = $true
            },
            @{
                match = "\\.(py|js|ts|jsx|tsx|json|md|txt|xml|yaml|yml)$"
                cmd = "python `"$unicodeReplacerPath`" `"`${file}`" --no-backup"
                isAsync = $false
                notInTerminal = $true
            }
        )
    }
    "files.encoding" = "utf8"
    "files.autoGuessEncoding" = $false
    "[powershell]" = @{
        "files.encoding" = "utf8"
        "files.eol" = "`r`n"
    }
    "editor.unicodeHighlight.ambiguousCharacters" = $true
    "editor.unicodeHighlight.invisibleCharacters" = $true
    "editor.unicodeHighlight.nonBasicASCII" = $true
    "editor.unicodeHighlight.includeComments" = $true
    "editor.unicodeHighlight.includeStrings" = $true
    "terminal.integrated.unicode.version" = "11"
}

# Merge with existing settings
foreach ($key in $runOnSaveConfig.Keys) {
    $existingSettings[$key] = $runOnSaveConfig[$key]
}

# Save settings
Write-Host "Writing settings.json..." -ForegroundColor Yellow
$existingSettings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "RunOnSave is now configured for this workspace:" -ForegroundColor Cyan
Write-Host "  Workspace: $(Resolve-Path $WorkspacePath)" -ForegroundColor White
Write-Host "  Settings: $settingsPath" -ForegroundColor White
Write-Host ""
Write-Host "How to use:" -ForegroundColor Yellow
Write-Host "  1. Open this workspace in VS Code" -ForegroundColor White
Write-Host "  2. Edit any .ps1, .py, .js, .md, etc. file" -ForegroundColor White
Write-Host "  3. Press Ctrl+S to save" -ForegroundColor White
Write-Host "  4. Unicode characters will be automatically replaced!" -ForegroundColor White
Write-Host ""
Write-Host "Supported file types:" -ForegroundColor Gray
Write-Host "  - PowerShell: .ps1, .psm1, .psd1" -ForegroundColor Gray
Write-Host "  - Python: .py" -ForegroundColor Gray
Write-Host "  - JavaScript/TypeScript: .js, .ts, .jsx, .tsx" -ForegroundColor Gray
Write-Host "  - Other: .json, .md, .txt, .xml, .yaml, .yml" -ForegroundColor Gray
