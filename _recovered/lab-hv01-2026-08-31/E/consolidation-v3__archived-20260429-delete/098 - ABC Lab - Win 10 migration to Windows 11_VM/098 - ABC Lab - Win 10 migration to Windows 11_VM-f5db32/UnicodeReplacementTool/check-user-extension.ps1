$extensions = Get-Content "C:\Users\User\.vscode\extensions\extensions.json" | ConvertFrom-Json
$runOnSave = $extensions | Where-Object { $_.identifier.id -eq "emeraldwalk.runonsave" }
if ($runOnSave) {
    Write-Host "RunOnSave extension is registered for User" -ForegroundColor Green
    $runOnSave | ConvertTo-Json -Depth 5
} else {
    Write-Host "RunOnSave extension is NOT registered for User" -ForegroundColor Red
}
