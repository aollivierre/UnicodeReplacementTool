# Comprehensive test of Python Unicode replacer
$python = "C:\Program Files\Python313\python.exe"
$replacer = "C:\code\UnicodeReplacementTool\TestEnvironment\unicode_replacer.py"
$testDir = "C:\code\UnicodeReplacementTool\TestEnvironment\ComprehensiveTest"

Write-Host "=== COMPREHENSIVE UNICODE REPLACEMENT TEST ===" -ForegroundColor Cyan

# Test 1: Preview mode
Write-Host "`nTest 1: Preview Mode" -ForegroundColor Yellow
& $python $replacer $testDir --preview

# Test 2: Actual replacement
Write-Host "`nTest 2: Performing Replacements" -ForegroundColor Yellow
& $python $replacer $testDir

# Test 3: Verify ASCII compliance
Write-Host "`nTest 3: Verifying ASCII Compliance" -ForegroundColor Yellow
Get-ChildItem $testDir -Filter "*.ps1" -Exclude "*.backup_*" | ForEach-Object {
    Write-Host "Checking: $($_.Name)" -NoNewline
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    $nonAscii = $bytes | Where-Object { $_ -gt 127 }
    if ($nonAscii.Count -eq 0) {
        Write-Host " [PASS]" -ForegroundColor Green
    } else {
        Write-Host " [FAIL] - Found $($nonAscii.Count) non-ASCII bytes" -ForegroundColor Red
    }
}

# Test 4: Show complex file output
Write-Host "`nTest 4: Complex File After Replacement:" -ForegroundColor Yellow
Get-Content "$testDir\test-complex.ps1" | Select-Object -First 25

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Cyan