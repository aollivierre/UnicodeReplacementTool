# Verify Unicode replacement was successful
Write-Host "=== UNICODE REPLACEMENT VERIFICATION ===" -ForegroundColor Cyan

# Sample file check
$sampleFile = "C:\code\SetupLab\final-focused-test.ps1"
$backupFile = Get-ChildItem "C:\code\SetupLab\final-focused-test.ps1.backup_*" | Select-Object -First 1

if ($backupFile) {
    Write-Host "`nSample comparison for: $sampleFile" -ForegroundColor Yellow
    
    # Get lines with Unicode from backup
    $beforeLines = Get-Content $backupFile.FullName | Where-Object { $_ -match '[\u0080-\uFFFF]' } | Select-Object -First 3
    Write-Host "`nBEFORE (with Unicode):" -ForegroundColor Magenta
    $beforeLines | ForEach-Object { Write-Host "  $_" }
    
    # Get corresponding lines from fixed file
    $afterLines = Get-Content $sampleFile | Where-Object { $_ -match '\[(OK|FAIL|WARNING|DONE|ERROR)\]' } | Select-Object -First 3
    Write-Host "`nAFTER (ASCII only):" -ForegroundColor Green
    $afterLines | ForEach-Object { Write-Host "  $_" }
}

# Verify all processed files are ASCII
Write-Host "`n`nVerifying all files are now ASCII-only..." -ForegroundColor Yellow

$allClean = $true
Get-ChildItem "C:\code\SetupLab" -Filter "*.ps1" -Recurse | ForEach-Object {
    $content = [System.IO.File]::ReadAllBytes($_.FullName)
    $nonAscii = $content | Where-Object { $_ -gt 127 }
    
    if ($nonAscii.Count -gt 0) {
        Write-Host "[FAIL] $($_.Name) - Still has $($nonAscii.Count) non-ASCII bytes" -ForegroundColor Red
        $allClean = $false
    }
}

if ($allClean) {
    Write-Host "`n[SUCCESS] All PowerShell files in SetupLab are now 100% ASCII!" -ForegroundColor Green
} else {
    Write-Host "`n[WARNING] Some files still contain non-ASCII characters" -ForegroundColor Yellow
}

# Summary
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total backup created: $((Get-ChildItem 'C:\code\SetupLab' -Filter '*.backup_*' -Recurse).Count)" -ForegroundColor Cyan
Write-Host "Full directory backup: C:\code\SetupLab_Backup_20250801_094949" -ForegroundColor Cyan