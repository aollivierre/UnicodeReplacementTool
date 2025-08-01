# Find exact files with Unicode in C:\code\SetupLab
$searchPath = "C:\code\SetupLab"
$filesWithUnicode = @()

Write-Host "Searching for files with Unicode characters in: $searchPath" -ForegroundColor Cyan

Get-ChildItem -Path $searchPath -Include "*.ps1", "*.psm1", "*.psd1" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -Encoding UTF8
    $hasUnicode = $false
    $unicodeChars = @()
    
    foreach ($char in $content.ToCharArray()) {
        if ([int]$char -gt 127) {
            $hasUnicode = $true
            $unicodeChars += $char
        }
    }
    
    if ($hasUnicode) {
        $filesWithUnicode += [PSCustomObject]@{
            FullPath = $_.FullName
            FileName = $_.Name
            UnicodeCount = $unicodeChars.Count
            UniqueChars = ($unicodeChars | Select-Object -Unique)
        }
    }
}

if ($filesWithUnicode.Count -gt 0) {
    Write-Host "`nFiles with Unicode characters:" -ForegroundColor Yellow
    foreach ($file in $filesWithUnicode) {
        Write-Host "`nEXACT PATH: $($file.FullPath)" -ForegroundColor Green
        Write-Host "  Unicode count: $($file.UnicodeCount)" -ForegroundColor White
        Write-Host "  Unique characters found:" -ForegroundColor White
        foreach ($char in $file.UniqueChars) {
            Write-Host "    '$char' (U+$([int]$char).ToString('X4'))" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "`nNo files with Unicode characters found." -ForegroundColor Green
}