# Verify file is pure ASCII
param($FilePath)

$bytes = [System.IO.File]::ReadAllBytes($FilePath)
$nonAscii = @()

for ($i = 0; $i -lt $bytes.Length; $i++) {
    if ($bytes[$i] -gt 127) {
        $nonAscii += @{
            Position = $i
            Byte = $bytes[$i]
            Hex = "0x{0:X2}" -f $bytes[$i]
        }
    }
}

if ($nonAscii.Count -eq 0) {
    Write-Host "SUCCESS: File is 100% ASCII!" -ForegroundColor Green
} else {
    Write-Host "FAILURE: Found $($nonAscii.Count) non-ASCII bytes:" -ForegroundColor Red
    $nonAscii | ForEach-Object {
        Write-Host "  Position $($_.Position): $($_.Hex) ($($_.Byte))"
    }
}