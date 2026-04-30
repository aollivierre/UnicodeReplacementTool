#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Complete Unicode Monitor System Setup - Single Entry Point

.DESCRIPTION
    Installs and configures the complete Unicode monitoring system with:
    - Optimized batch replacer (1.94x faster)
    - Real-time file monitoring service
    - Windows Service with auto-restart
    - Public desktop shortcut for all users
    - Real-time colorized log viewer

.PARAMETER SkipServiceInstall
    Skip Windows Service installation (for testing)

.PARAMETER SkipShortcut
    Skip creating public desktop shortcut

.PARAMETER MonitorPaths
    Paths to monitor (default: C:\code, C:\temp)

.EXAMPLE
    .\Setup-UnicodeMonitorSystem.ps1
    Complete installation with defaults

.EXAMPLE
    .\Setup-UnicodeMonitorSystem.ps1 -MonitorPaths "C:\code","C:\projects"
    Install with custom monitor paths

.NOTES
    Version: 2.0.0 (Optimized)
    Author: Unicode Monitor Team
    Requires: Python 3.x, Administrator rights
#>

[CmdletBinding()]
param(
    [switch]$SkipServiceInstall,
    [switch]$SkipShortcut,
    [string[]]$MonitorPaths = @("C:\code", "C:\temp")
)

$ErrorActionPreference = "Stop"

# Configuration
$script:Config = @{
    # Paths
    ToolRoot = "C:\code\UnicodeReplacementTool\UnicodeReplacementTool"
    VscodeExtRoot = "C:\code\UnicodeReplacementTool\vscode.ext"
    ToolsDir = "C:\code\tools"
    PublicDesktop = "C:\Users\Public\Desktop"

    # Service
    ServiceName = "UnicodeMonitor"
    DisplayName = "Unicode Ultra-Fast Monitor"
    Description = "Real-time Unicode replacement monitor - 1.94x optimized"

    # Files
    OptimizedReplacer = "unicode_replacer_optimized.py"
    MonitorScript = "unicode-ultrafast-monitor-optimized.py"
    LogViewer = "view-monitor-logs.ps1"

    # Monitor settings
    MonitorPaths = $MonitorPaths
    FileExtensions = @('.ps1', '.psm1', '.py')

    # Python
    PythonExe = "C:\Program Files\Python313\python.exe"
}

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor White
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Text)
    Write-Host "[STEP] $Text" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Text)
    Write-Host "[SUCCESS] $Text" -ForegroundColor Green
}

function Write-Info {
    param([string]$Text)
    Write-Host "[INFO] $Text" -ForegroundColor Cyan
}

function Write-Warning {
    param([string]$Text)
    Write-Host "[WARNING] $Text" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Text)
    Write-Host "[ERROR] $Text" -ForegroundColor Red
}

function Test-Prerequisites {
    Write-Step "Checking prerequisites..."

    $issues = @()

    # Check Python
    if (-not (Test-Path $script:Config.PythonExe)) {
        # Try to find Python in PATH
        $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
        if ($pythonCmd) {
            $script:Config.PythonExe = $pythonCmd.Source
            Write-Info "Found Python at: $($pythonCmd.Source)"
        } else {
            $issues += "Python not found. Install Python 3.x from python.org"
        }
    } else {
        Write-Success "Python found: $($script:Config.PythonExe)"
    }

    # Check paths exist
    if (-not (Test-Path $script:Config.ToolRoot)) {
        $issues += "Tool root not found: $($script:Config.ToolRoot)"
    }

    if ($issues.Count -gt 0) {
        Write-Error "Prerequisites not met:"
        $issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
        return $false
    }

    Write-Success "All prerequisites met"
    return $true
}

function Install-PythonPackages {
    Write-Step "Installing Python packages..."

    $packages = @('watchdog')

    foreach ($package in $packages) {
        Write-Info "Installing $package..."
        & $script:Config.PythonExe -m pip install $package --quiet

        if ($LASTEXITCODE -eq 0) {
            Write-Success "$package installed"
        } else {
            Write-Warning "$package installation may have issues"
        }
    }
}

function Install-NSSM {
    Write-Step "Installing NSSM (service manager)..."

    $nssmPath = Join-Path $script:Config.ToolsDir "nssm.exe"

    if (Test-Path $nssmPath) {
        Write-Success "NSSM already installed"
        return $nssmPath
    }

    # Create tools directory
    New-Item -Path $script:Config.ToolsDir -ItemType Directory -Force | Out-Null

    Write-Info "Downloading NSSM..."
    $nssmUrl = "https://nssm.cc/release/nssm-2.24.zip"
    $zipPath = "$env:TEMP\nssm.zip"
    $extractPath = "$env:TEMP\nssm"

    try {
        Invoke-WebRequest -Uri $nssmUrl -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
        Copy-Item "$extractPath\nssm-2.24\win64\nssm.exe" $nssmPath

        # Cleanup
        Remove-Item $zipPath -Force
        Remove-Item $extractPath -Recurse -Force

        Write-Success "NSSM installed: $nssmPath"
        return $nssmPath
    }
    catch {
        Write-Error "Failed to download NSSM: $_"
        Write-Info "Download manually from: https://nssm.cc/download"
        return $null
    }
}

function Update-MonitorConfiguration {
    Write-Step "Updating monitor configuration..."

    $monitorScript = Join-Path $script:Config.VscodeExtRoot $script:Config.MonitorScript

    if (-not (Test-Path $monitorScript)) {
        Write-Error "Monitor script not found: $monitorScript"
        return $false
    }

    # Update MONITOR_PATHS in the script
    $content = Get-Content $monitorScript -Raw

    $pathsString = ($script:Config.MonitorPaths | ForEach-Object { "`"$($_ -replace '\\','\\')`"" }) -join ", "
    $content = $content -replace 'MONITOR_PATHS = \[.*?\]',"MONITOR_PATHS = [$pathsString]"

    Set-Content $monitorScript $content -NoNewline

    Write-Success "Monitor configured for paths: $($script:Config.MonitorPaths -join ', ')"
    return $true
}

function Install-WindowsService {
    param([string]$NssmPath)

    Write-Step "Installing Windows Service..."

    $serviceName = $script:Config.ServiceName
    $monitorScript = Join-Path $script:Config.VscodeExtRoot $script:Config.MonitorScript
    $logFile = Join-Path $script:Config.VscodeExtRoot "Logs\unicode-ultrafast.log"

    # Ensure log directory exists
    $logDir = Split-Path $logFile
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null

    # Remove old service if exists
    $existing = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Info "Removing existing service..."
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        & $NssmPath remove $serviceName confirm
        Start-Sleep -Seconds 2
    }

    # Install service
    Write-Info "Creating service..."
    & $NssmPath install $serviceName $script:Config.PythonExe $monitorScript

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install service"
        return $false
    }

    # Configure service
    Write-Info "Configuring service..."
    & $NssmPath set $serviceName DisplayName $script:Config.DisplayName
    & $NssmPath set $serviceName Description $script:Config.Description
    & $NssmPath set $serviceName AppDirectory $script:Config.VscodeExtRoot
    & $NssmPath set $serviceName Start SERVICE_AUTO_START
    & $NssmPath set $serviceName AppStdout $logFile
    & $NssmPath set $serviceName AppStderr $logFile
    & $NssmPath set $serviceName AppExit Default Restart
    & $NssmPath set $serviceName AppRestartDelay 5000
    & $NssmPath set $serviceName AppThrottle 10000
    & $NssmPath set $serviceName DependOnService Tcpip

    # Start service
    Write-Info "Starting service..."
    & $NssmPath start $serviceName
    Start-Sleep -Seconds 3

    $service = Get-Service -Name $serviceName
    if ($service.Status -eq 'Running') {
        Write-Success "Service installed and running"
        return $true
    } else {
        Write-Error "Service installed but not running. Check logs: $logFile"
        return $false
    }
}

function Install-PublicShortcut {
    Write-Step "Creating public desktop shortcut..."

    $shortcutPath = Join-Path $script:Config.PublicDesktop "Unicode Monitor Logs.lnk"
    $targetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $logViewer = Join-Path $script:Config.VscodeExtRoot $script:Config.LogViewer
    $arguments = "-NoExit -ExecutionPolicy Bypass -File `"$logViewer`""

    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $targetPath
    $Shortcut.Arguments = $arguments
    $Shortcut.WorkingDirectory = $script:Config.VscodeExtRoot
    $Shortcut.IconLocation = "C:\Windows\System32\shell32.dll,70"
    $Shortcut.Description = "View Unicode Monitor real-time logs"
    $Shortcut.WindowStyle = 1
    $Shortcut.Save()

    Write-Success "Public shortcut created: $shortcutPath"
}

function Show-Summary {
    Write-Header "INSTALLATION COMPLETE"

    $service = Get-Service -Name $script:Config.ServiceName -ErrorAction SilentlyContinue

    Write-Host "System Status:" -ForegroundColor Yellow
    Write-Host ""

    if ($service) {
        $statusColor = if ($service.Status -eq 'Running') { 'Green' } else { 'Red' }
        Write-Host "  Service: " -NoNewline
        Write-Host $service.Status -ForegroundColor $statusColor
    }

    Write-Host "  Optimized Replacer: " -NoNewline
    Write-Host "1.94x faster" -ForegroundColor Green

    Write-Host "  File Types: " -NoNewline
    Write-Host ($script:Config.FileExtensions -join ', ') -ForegroundColor Cyan

    Write-Host "  Monitor Paths:" -ForegroundColor Cyan
    $script:Config.MonitorPaths | ForEach-Object {
        Write-Host "    - $_" -ForegroundColor White
    }

    Write-Host ""
    Write-Host "Quick Start:" -ForegroundColor Yellow
    Write-Host "  1. Desktop shortcut: 'Unicode Monitor Logs' (all users)" -ForegroundColor White
    Write-Host "  2. Check status: Get-Service $($script:Config.ServiceName)" -ForegroundColor White
    Write-Host "  3. View logs: $($script:Config.VscodeExtRoot)\view-monitor-logs.ps1" -ForegroundColor White

    Write-Host ""
    Write-Host "Batch Tool:" -ForegroundColor Yellow
    Write-Host "  python $($script:Config.ToolRoot)\unicode_replacer_optimized.py <path> --interactive" -ForegroundColor White

    Write-Host ""
    Write-Host "Documentation:" -ForegroundColor Yellow
    Write-Host "  $($script:Config.ToolRoot)\README.md" -ForegroundColor White
    Write-Host "  $($script:Config.VscodeExtRoot)\RELIABLE-MONITOR-SETUP.md" -ForegroundColor White

    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host "Ready for production use!" -ForegroundColor Green
    Write-Host ("=" * 80) -ForegroundColor Cyan
}

# Main execution
try {
    Write-Header "Unicode Monitor System - Complete Setup"
    Write-Info "Version: 2.0.0 (Optimized - 1.94x faster)"
    Write-Info "This will install the complete Unicode monitoring system"
    Write-Host ""

    # Step 1: Prerequisites
    if (-not (Test-Prerequisites)) {
        exit 1
    }

    # Step 2: Python packages
    Install-PythonPackages

    # Step 3: NSSM
    $nssmPath = Install-NSSM
    if (-not $nssmPath) {
        Write-Error "NSSM installation required. Exiting."
        exit 1
    }

    # Step 4: Update configuration
    if (-not (Update-MonitorConfiguration)) {
        exit 1
    }

    # Step 5: Install service (optional)
    if (-not $SkipServiceInstall) {
        if (-not (Install-WindowsService -NssmPath $nssmPath)) {
            Write-Warning "Service installation had issues. Check manually."
        }
    } else {
        Write-Info "Service installation skipped"
    }

    # Step 6: Create shortcut (optional)
    if (-not $SkipShortcut) {
        Install-PublicShortcut
    } else {
        Write-Info "Shortcut creation skipped"
    }

    # Step 7: Summary
    Show-Summary

    exit 0
}
catch {
    Write-Error "Installation failed: $_"
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
