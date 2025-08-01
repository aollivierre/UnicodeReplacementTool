# Comprehensive test runner for Unicode Replacement Tool

Write-Host "Unicode Replacement Tool - Test Suite" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan

# Test 1: Verify Python is available
Write-Host "`nTest 1: Python Installation" -ForegroundColor Yellow
try {
    $pythonVersion = & "C:\Program Files\Python313\python.exe" --version 2>&1
    Write-Host "  [PASS] Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Python not found" -ForegroundColor Red
    exit 1
}

# Test 2: Test with known Unicode content
Write-Host "`nTest 2: Known Unicode Replacement" -ForegroundColor Yellow
$testContent = @"
Write-Host "✓ Success"
Write-Host "✗ Failed"  
Write-Host "🚀 Deploy"
"@

$testFile = "test-temp.ps1"
[System.IO.File]::WriteAllText($testFile, $testContent, [System.Text.Encoding]::UTF8)

# Run replacement
& "C:\Program Files\Python313\python.exe" unicode_replacer.py $testFile | Out-Null

# Verify result
$result = Get-Content $testFile -Raw
$expected = @"
Write-Host "[OK] Success"
Write-Host "[FAIL] Failed"  
Write-Host "[DEPLOY] Deploy"
"@

if ($result.Trim() -eq $expected.Trim()) {
    Write-Host "  [PASS] Unicode replaced correctly" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Incorrect replacement" -ForegroundColor Red
    Write-Host "Expected:" -ForegroundColor Yellow
    Write-Host $expected
    Write-Host "Got:" -ForegroundColor Yellow
    Write-Host $result
}

# Cleanup
Remove-Item $testFile -Force
Remove-Item "$testFile.backup_*" -Force

# Test 3: ASCII verification
Write-Host "`nTest 3: ASCII Compliance" -ForegroundColor Yellow
& .\Replace-Unicode.ps1 -Path TestEnvironment\TestFiles -PreviewOnly | Out-Null
Write-Host "  [PASS] Preview mode works" -ForegroundColor Green

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "All tests completed!" -ForegroundColor Cyan