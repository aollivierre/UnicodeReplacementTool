# Test to demonstrate the JSON Unicode bug
$jsonContent = @'
{
    "test": {
        "\u2713": "[OK]",
        "\u2717": "[FAIL]"
    }
}
'@

# Load JSON and see what happens
$parsed = $jsonContent | ConvertFrom-Json

Write-Host "JSON Keys after parsing:"
foreach ($key in $parsed.test.PSObject.Properties.Name) {
    Write-Host "Key: '$key' (Length: $($key.Length))"
    # Show byte values
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($key)
    Write-Host "Bytes: $($bytes -join ',')"
}