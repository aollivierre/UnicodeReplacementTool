# Find Python installation
$pythonPaths = @(
    "C:\Python313\python.exe",
    "C:\Program Files\Python313\python.exe",
    "C:\Program Files (x86)\Python313\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe"
)

foreach ($path in $pythonPaths) {
    if (Test-Path $path) {
        Write-Host "Found Python at: $path"
        & $path --version
        break
    }
}

# Also check if it's in PATH
try {
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCmd) {
        Write-Host "Python found in PATH: $($pythonCmd.Source)"
    }
} catch {
    Write-Host "Python not found in PATH"
}