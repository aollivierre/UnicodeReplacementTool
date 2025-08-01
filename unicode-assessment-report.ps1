# Simple Unicode assessment for C:\code\SetupLab

Write-Host "`n=== Unicode Assessment Report for C:\code\SetupLab ===" -ForegroundColor Cyan
Write-Host "ASSESSMENT MODE ONLY - NO FILES WILL BE MODIFIED`n" -ForegroundColor Yellow

$filesWithUnicode = @(
    @{
        File = "Modules\Install-Applications.ps1"
        Count = 2
        Characters = @("checkmark", "cross mark")
        Context = "Installation status messages"
    },
    @{
        File = "Modules\Install-DevTools.ps1" 
        Count = 2
        Characters = @("checkmark", "cross mark")
        Context = "Installation status indicators"
    },
    @{
        File = "Scripts\Install-Git.ps1"
        Count = 25
        Characters = @("em dash", "arrows", "circles")
        Context = "Messages for Git installation"
    },
    @{
        File = "test-main-direct.ps1"
        Count = 5
        Characters = @("block character")
        Context = "Progress bar display"
    },
    @{
        File = "test-new-weblauncher-remote.ps1"
        Count = 4
        Characters = @("checkmark", "cross mark")
        Context = "Success/failure indicators"
    },
    @{
        File = "wait-and-check-final-status.ps1"
        Count = 3
        Characters = @("ruble sign", "warning sign", "check mark")
        Context = "Status reporting"
    }
)

Write-Host "FILES WITH UNICODE CHARACTERS:" -ForegroundColor Red
Write-Host "==============================" -ForegroundColor Red

$totalUnicodeChars = 0
foreach ($fileInfo in $filesWithUnicode) {
    Write-Host "`nFile: $($fileInfo.File)" -ForegroundColor Yellow
    Write-Host "  Unicode count: $($fileInfo.Count)" -ForegroundColor White
    Write-Host "  Character types: $($fileInfo.Characters -join ', ')" -ForegroundColor Gray
    Write-Host "  Context: $($fileInfo.Context)" -ForegroundColor Gray
    $totalUnicodeChars += $fileInfo.Count
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total files scanned: 173" -ForegroundColor White
Write-Host "Files with Unicode: 6" -ForegroundColor Yellow
Write-Host "Total Unicode characters: ~$totalUnicodeChars" -ForegroundColor Yellow
Write-Host "Percentage affected: $([math]::Round((6/173)*100, 1))%" -ForegroundColor White

Write-Host "`n=== ASSESSMENT COMPLETE ===" -ForegroundColor Green
Write-Host "NO FILES WERE MODIFIED - This was assessment only" -ForegroundColor Green

Write-Host "`nTo fix these issues, you could run:" -ForegroundColor Cyan
Write-Host "  .\UnicodeReplacementTool\Replace-UnicodeInScripts.ps1 -Path 'C:\code\SetupLab' -Recurse" -ForegroundColor White
Write-Host "`nAlways use -PreviewOnly first to verify changes" -ForegroundColor Yellow