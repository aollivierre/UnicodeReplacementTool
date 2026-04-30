#Requires -Version 5.1
<#
.SYNOPSIS
    Archives old/superseded files from today's optimization work

.DESCRIPTION
    Moves files that were superseded during the optimization work to .archive/v1.0-baseline/
    Does NOT touch files that weren't part of today's work
#>

$ErrorActionPreference = "Stop"

$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$archiveRoot = "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\.archive\v1.0-baseline-$timestamp"

Write-Host "Archiving old files from optimization work..." -ForegroundColor Cyan
Write-Host "Archive location: $archiveRoot" -ForegroundColor Yellow
Write-Host ""

# Create archive directory
New-Item -Path $archiveRoot -ItemType Directory -Force | Out-Null

# Files to archive (from today's work - superseded by optimized versions)
$filesToArchive = @(
    # Old README (superseded by new comprehensive README)
    @{
        Source = "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\README.md"
        Dest = "$archiveRoot\README-old.md"
        Reason = "Superseded by comprehensive v2.0 README"
    }

    # Non-optimized replacer (superseded by optimized version)
    @{
        Source = "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py"
        Dest = "$archiveRoot\unicode_replacer-baseline.py"
        Reason = "Superseded by unicode_replacer_optimized.py (1.94x faster)"
    }

    # Old monitor (superseded by optimized version)
    @{
        Source = "C:\code\UnicodeReplacementTool\vscode.ext\unicode-ultrafast-monitor.py"
        Dest = "$archiveRoot\unicode-ultrafast-monitor-baseline.py"
        Reason = "Superseded by unicode-ultrafast-monitor-optimized.py"
    }

    # Temporary setup scripts (superseded by master setup)
    @{
        Source = "C:\code\UnicodeReplacementTool\vscode.ext\setup-unicode-service.ps1"
        Dest = "$archiveRoot\setup-unicode-service.ps1"
        Reason = "Superseded by Setup-UnicodeMonitorSystem.ps1"
    }

    @{
        Source = "C:\code\UnicodeReplacementTool\vscode.ext\install-service-now.ps1"
        Dest = "$archiveRoot\install-service-now.ps1"
        Reason = "Temporary file, superseded by master setup"
    }

    @{
        Source = "C:\code\UnicodeReplacementTool\vscode.ext\start-service.ps1"
        Dest = "$archiveRoot\start-service.ps1"
        Reason = "Temporary file, superseded by master setup"
    }

    @{
        Source = "C:\code\UnicodeReplacementTool\vscode.ext\verify-service-config.ps1"
        Dest = "$archiveRoot\verify-service-config.ps1"
        Reason = "Temporary file, functionality in master setup"
    }
)

$archived = 0
$skipped = 0

foreach ($item in $filesToArchive) {
    if (Test-Path $item.Source) {
        try {
            # Copy to archive (not move, to be safe)
            Copy-Item $item.Source $item.Dest -Force
            Write-Host "[ARCHIVED] $($item.Source)" -ForegroundColor Green
            Write-Host "           → $($item.Dest)" -ForegroundColor DarkGray
            Write-Host "           Reason: $($item.Reason)" -ForegroundColor DarkGray
            Write-Host ""
            $archived++
        }
        catch {
            Write-Host "[ERROR] Failed to archive: $($item.Source)" -ForegroundColor Red
            Write-Host "        $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "[SKIP] Not found: $($item.Source)" -ForegroundColor Yellow
        $skipped++
    }
}

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Archive Summary:" -ForegroundColor White
Write-Host "  Archived: $archived files" -ForegroundColor Green
Write-Host "  Skipped: $skipped files (not found)" -ForegroundColor Yellow
Write-Host "  Location: $archiveRoot" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTE: Original files preserved for safety" -ForegroundColor Yellow
Write-Host "      Delete manually after verifying new system works" -ForegroundColor Yellow
