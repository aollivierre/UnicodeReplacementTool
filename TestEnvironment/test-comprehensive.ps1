# Comprehensive test of Python Unicode replacer
$python = "C:\Program Files\Python313\python.exe"
$replacer = "C:\code\UnicodeReplacementTool\TestEnvironment\unicode_replacer.py"

Write-Host "=== COMPREHENSIVE UNICODE REPLACEMENT TEST ===" -ForegroundColor Cyan

# Create test directory structure
$testDir = "C:\code\UnicodeReplacementTool\TestEnvironment\ComprehensiveTest"
if (Test-Path $testDir) {
    Remove-Item $testDir -Recurse -Force
}
New-Item -Path $testDir -ItemType Directory | Out-Null

# Test 1: Edge cases
Write-Host "`nTest 1: Edge Cases" -ForegroundColor Yellow
$edgeContent = @'
# Empty file test follows
'@
[System.IO.File]::WriteAllText("$testDir\test-empty.ps1", "", [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("$testDir\test-only-unicode.ps1", "✓✗⚠🚀💡", [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("$testDir\test-no-unicode.ps1", "Write-Host 'Hello World'", [System.Text.Encoding]::UTF8)

# Test 2: Complex Unicode scenarios  
Write-Host "`nTest 2: Complex Scenarios" -ForegroundColor Yellow
$complexContent = @'
# PowerShell script with various Unicode scenarios
function Test-Unicode {
    # Single quotes with Unicode
    Write-Host '✓ Success'
    
    # Double quotes with Unicode
    Write-Host "✗ Failed: $error"
    
    # Here-string with Unicode
    $message = @"
🚀 Deployment starting...
⚠ Warning: Check configuration
✓ Done!
"@
    
    # Unicode in variables
    $status = "✓"
    $arrows = @{
        "right" = "→"
        "left" = "←"
        "both" = "↔"
    }
    
    # Unicode in comments
    # → This is a comment with arrow
    # π = 3.14159...
    
    # Math operations (conceptual)
    # ∑(1..10) = 55
    # ∞ loops should be avoided
}

# Edge case: Unicode at file boundaries
Write-Host "Start→Middle→End"
'@
[System.IO.File]::WriteAllText("$testDir\test-complex.ps1", $complexContent, [System.Text.Encoding]::UTF8)

# Test 3: Run replacer on all test files
Write-Host "`nTest 3: Running Replacements" -ForegroundColor Yellow
& $python $replacer $testDir --preview

Write-Host "`nTest 4: Performing Actual Replacements" -ForegroundColor Yellow
& $python $replacer $testDir

# Test 5: Verify all files are ASCII
Write-Host "`nTest 5: Verifying ASCII Compliance" -ForegroundColor Yellow
Get-ChildItem $testDir -Filter "*.ps1" | ForEach-Object {
    Write-Host "Checking: $($_.Name)" -NoNewline
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    $nonAscii = $bytes | Where-Object { $_ -gt 127 }
    if ($nonAscii.Count -eq 0) {
        Write-Host " [PASS]" -ForegroundColor Green
    } else {
        Write-Host " [FAIL] - Found $($nonAscii.Count) non-ASCII bytes" -ForegroundColor Red
    }
}

# Test 6: Show sample output
Write-Host "`nTest 6: Sample Output" -ForegroundColor Yellow
Write-Host "Complex file after replacement:"
Get-Content "$testDir\test-complex.ps1" | Select-Object -First 20

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Cyan