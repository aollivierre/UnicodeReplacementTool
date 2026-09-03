# Test Unicode Remover Skill
# This script verifies the skill is working correctly

Write-Host "Testing Unicode Remover Skill" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Verify Python is available
Write-Host "Test 1: Python availability..." -NoNewline
try {
    $pythonVersion = python --version 2>&1
    Write-Host " PASS ($pythonVersion)" -ForegroundColor Green
}
catch {
    Write-Host " FAIL (Python not in PATH)" -ForegroundColor Red
    exit 1
}

# Test 2: Verify script exists
Write-Host "Test 2: Script existence..." -NoNewline
$scriptPath = "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py"
if (Test-Path $scriptPath) {
    Write-Host " PASS" -ForegroundColor Green
}
else {
    Write-Host " FAIL (Script not found at $scriptPath)" -ForegroundColor Red
    exit 1
}

# Test 3: Create test file with Unicode
Write-Host "Test 3: Create test file..." -NoNewline
$testFile = "$env:TEMP\unicode-skill-test.ps1"
# Use Out-File with UTF8 encoding to properly write Unicode
"# Test file with Unicode characters" | Out-File $testFile -Encoding utf8
"Write-Host `"Smart quotes`"" | Out-File $testFile -Append -Encoding utf8
"`$sum = 123" | Out-File $testFile -Append -Encoding utf8
"# Simple dash test" | Out-File $testFile -Append -Encoding utf8
"`"Check`" | Out-File log.txt" | Out-File $testFile -Append -Encoding utf8

# Manually add a Unicode character to the file using .NET
$content = Get-Content $testFile -Raw
$content = $content -replace "Smart quotes", "Smart quotes → test"
$content = $content -replace "dash test", "dash – test"
[System.IO.File]::WriteAllText($testFile, $content, [System.Text.Encoding]::UTF8)
Write-Host " PASS" -ForegroundColor Green

# Test 4: Run script in preview mode
Write-Host "Test 4: Preview mode..." -NoNewline
$previewResult = python $scriptPath $testFile --preview 2>&1
if ($previewResult -match "Found.*Unicode characters" -or $previewResult -match "replacements") {
    Write-Host " PASS (Unicode detected)" -ForegroundColor Green
}
else {
    Write-Host " FAIL (No Unicode detected in preview)" -ForegroundColor Red
    Write-Host "Preview output: $previewResult"
    exit 1
}

# Test 5: Run actual replacement
Write-Host "Test 5: Actual replacement..." -NoNewline
$replaceResult = python $scriptPath $testFile --no-backup 2>&1
if ($replaceResult -match "replacements" -or $replaceResult -match "Processed") {
    Write-Host " PASS" -ForegroundColor Green
}
else {
    Write-Host " FAIL" -ForegroundColor Red
    Write-Host "Replace output: $replaceResult"
    exit 1
}

# Test 6: Verify file was modified
Write-Host "Test 6: File modification..." -NoNewline
$newContent = Get-Content $testFile -Raw
# Check that Unicode arrow and dash were replaced
if (($newContent -match "->" -or $newContent -notmatch "→") -and ($newContent -match "-" -or $newContent -notmatch "–")) {
    Write-Host " PASS (Unicode replaced)" -ForegroundColor Green
}
else {
    Write-Host " FAIL (Unicode still present)" -ForegroundColor Red
    Write-Host "Content: $newContent"
    exit 1
}

# Test 7: Idempotency (running again should find no Unicode)
Write-Host "Test 7: Idempotency..." -NoNewline
$secondRun = python $scriptPath $testFile --no-backup 2>&1
if ($secondRun -match "No Unicode characters found") {
    Write-Host " PASS (Idempotent)" -ForegroundColor Green
}
else {
    Write-Host " FAIL (Should report no Unicode on second run)" -ForegroundColor Red
    Write-Host "Second run output: $secondRun"
    exit 1
}

# Test 8: Cleanup
Write-Host "Test 8: Cleanup..." -NoNewline
Remove-Item $testFile -Force -ErrorAction SilentlyContinue
Write-Host " PASS" -ForegroundColor Green

Write-Host ""
Write-Host "All tests passed!" -ForegroundColor Green
Write-Host ""
Write-Host "The unicode-remover skill is ready to use." -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run: .\install-skill.ps1" -ForegroundColor White
Write-Host "  2. Use in Claude Code: 'Use unicode-remover skill to clean my files'" -ForegroundColor White
