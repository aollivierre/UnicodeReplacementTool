# Complex Unicode Test Cases
$symbols = @{
    "arrow" = "→"
    "sum" = "∑"
    "pi" = "π"
    "infinity" = "∞"
}

# Mixed content
function Test-Unicode {
    Write-Host "→ Starting test..."
    Write-Host "π = 3.14159..."
    Write-Host "∑ of all values"
    return "✓"
}

# Edge cases
$empty = ""
$onlyUnicode = "✓✗⚠"
$nested = "He said '✓ Done' loudly"
$multiline = @"
✓ Line 1
✗ Line 2
⚠ Line 3
"@