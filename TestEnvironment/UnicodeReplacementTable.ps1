# Unicode Replacement Table - PowerShell 5.1 Compatible
# This avoids JSON Unicode parsing issues by using byte-based lookups

function Get-UnicodeReplacementTable {
    # Create hashtable with byte sequences as keys
    $replacements = @{}
    
    # Common symbols - using byte arrays to avoid Unicode in source
    $replacements[[byte[]](0xE2,0x9C,0x93)] = "[OK]"          # ✓
    $replacements[[byte[]](0xE2,0x9C,0x97)] = "[FAIL]"        # ✗
    $replacements[[byte[]](0xE2,0x9A,0xA0)] = "[WARNING]"     # ⚠
    $replacements[[byte[]](0xE2,0x86,0x92)] = "->"            # →
    
    # Emoji (4-byte UTF-8)
    $replacements[[byte[]](0xF0,0x9F,0x9A,0x80)] = "[DEPLOY]" # 🚀
    $replacements[[byte[]](0xF0,0x9F,0x92,0xA1)] = "[IDEA]"   # 💡
    
    return $replacements
}

function Replace-UnicodeInFile {
    param(
        [string]$FilePath,
        [hashtable]$ReplacementTable = (Get-UnicodeReplacementTable)
    )
    
    # Read file as bytes to avoid encoding issues
    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    $output = [System.Collections.ArrayList]::new()
    
    $i = 0
    while ($i -lt $bytes.Length) {
        $matched = $false
        
        # Check each replacement pattern
        foreach ($pattern in $ReplacementTable.Keys) {
            if ($i + $pattern.Length -le $bytes.Length) {
                $match = $true
                for ($j = 0; $j -lt $pattern.Length; $j++) {
                    if ($bytes[$i + $j] -ne $pattern[$j]) {
                        $match = $false
                        break
                    }
                }
                
                if ($match) {
                    # Add replacement text as bytes
                    $replacementBytes = [System.Text.Encoding]::UTF8.GetBytes($ReplacementTable[$pattern])
                    $output.AddRange($replacementBytes)
                    $i += $pattern.Length
                    $matched = $true
                    break
                }
            }
        }
        
        if (-not $matched) {
            # Keep original byte
            $output.Add($bytes[$i])
            $i++
        }
    }
    
    return [byte[]]$output.ToArray()
}

# Test function
function Test-Replacement {
    $testFile = "test.ps1"
    $testContent = @"
Write-Host "✓ Success"
Write-Host "✗ Failed"
Write-Host "⚠ Warning"
Write-Host "🚀 Deploy"
"@
    
    # Write test file
    [System.IO.File]::WriteAllText($testFile, $testContent, [System.Text.Encoding]::UTF8)
    
    Write-Host "Original content:"
    Get-Content $testFile
    
    # Replace Unicode
    $newBytes = Replace-UnicodeInFile -FilePath $testFile
    
    Write-Host "`nReplaced content:"
    [System.Text.Encoding]::UTF8.GetString($newBytes)
    
    # Verify no Unicode remains
    $hasUnicode = $false
    foreach ($byte in $newBytes) {
        if ($byte -gt 127) {
            $hasUnicode = $true
            Write-Host "Found non-ASCII byte: $byte"
        }
    }
    
    if (-not $hasUnicode) {
        Write-Host "`nSUCCESS: All Unicode removed!"
    }
    
    Remove-Item $testFile
}

# Run test
Test-Replacement