<#
.SYNOPSIS
    PowerShell wrapper for Unicode Replacement Tool
.DESCRIPTION
    Replaces Unicode characters in PowerShell scripts with ASCII equivalents.
    This is a wrapper around the Python-based Unicode replacement tool that
    reliably handles all Unicode characters without the JSON parsing issues
    that affected the pure PowerShell implementation.
.PARAMETER Path
    File or directory to process
.PARAMETER PreviewOnly
    Preview changes without modifying files
.PARAMETER NoBackup
    Skip creating backup files
.PARAMETER Pattern
    File pattern to match (default: *.ps1)
.PARAMETER Recurse
    Process subdirectories (default: True)
.PARAMETER Verbose
    Show detailed output
.EXAMPLE
    .\Replace-Unicode.ps1 -Path "C:\Scripts"
    Process all .ps1 files in C:\Scripts and subdirectories
.EXAMPLE
    .\Replace-Unicode.ps1 -Path "script.ps1" -PreviewOnly
    Preview changes for a single file
.EXAMPLE
    .\Replace-Unicode.ps1 -Path "C:\Scripts" -Pattern "*.txt" -NoBackup
    Process .txt files without creating backups
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Path,
    
    [Parameter()]
    [switch]$PreviewOnly,
    
    [Parameter()]
    [switch]$NoBackup,
    
    [Parameter()]
    [string]$Pattern = "*.ps1",
    
    [Parameter()]
    [switch]$Recurse = $true,
    
    [Parameter()]
    [switch]$VerboseOutput
)

# Find Python
function Find-Python {
    $pythonPaths = @(
        "python.exe",
        "python3.exe",
        "C:\Python313\python.exe",
        "C:\Program Files\Python313\python.exe",
        "C:\Program Files (x86)\Python313\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe"
    )
    
    foreach ($pythonPath in $pythonPaths) {
        try {
            $result = & $pythonPath --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                return $pythonPath
            }
        } catch {
            # Continue to next path
        }
    }
    
    throw "Python not found. Please install Python 3.x from https://www.python.org/"
}

# Main execution
try {
    Write-Host "Unicode Replacement Tool - PowerShell Wrapper" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    # Find Python
    $python = Find-Python
    Write-Verbose "Using Python: $python"
    
    # Find the Unicode replacer script
    $replacerScript = Join-Path $PSScriptRoot "unicode_replacer.py"
    if (-not (Test-Path $replacerScript)) {
        throw "Unicode replacer script not found: $replacerScript"
    }
    
    # Build arguments
    $arguments = @($replacerScript, $Path)
    
    if ($PreviewOnly) {
        $arguments += "--preview"
    }
    
    if ($NoBackup) {
        $arguments += "--no-backup"
    }
    
    if ($Pattern -ne "*.ps1") {
        $arguments += "--pattern", $Pattern
    }
    
    if (-not $Recurse) {
        $arguments += "--recursive", "false"
    }
    
    if ($VerboseOutput -or $VerbosePreference -eq 'Continue') {
        $arguments += "--verbose"
    }
    
    # Execute Python script
    Write-Verbose "Executing: $python $($arguments -join ' ')"
    & $python $arguments
    
    if ($LASTEXITCODE -ne 0) {
        throw "Unicode replacement failed with exit code: $LASTEXITCODE"
    }
    
    Write-Host "`nOperation completed successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Error: $_"
    exit 1
}