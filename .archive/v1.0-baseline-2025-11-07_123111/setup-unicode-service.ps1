#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Setup Unicode Monitor as a reliable Windows Service
.DESCRIPTION
    Uses NSSM to create a Windows Service for maximum reliability
    Includes automatic restart on failure and proper service management
#>

$ErrorActionPreference = "Stop"

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Unicode Monitor - Windows Service Setup" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

# Configuration
$ServiceName = "UnicodeMonitor"
$DisplayName = "Unicode Ultra-Fast Monitor"
$Description = "Real-time Unicode replacement monitor - 1.94x optimized"
$ScriptPath = "C:\code\UnicodeReplacementTool\vscode.ext\unicode-ultrafast-monitor.py"
$PythonPath = "C:\Program Files\Python313\python.exe"
$WorkingDir = "C:\code\UnicodeReplacementTool\vscode.ext"
$LogFile = "C:\code\UnicodeReplacementTool\vscode.ext\Logs\unicode-ultrafast.log"

# NSSM download location
$NssmPath = "C:\code\tools\nssm.exe"
$NssmDir = Split-Path $NssmPath

# Check Python
if (-not (Test-Path $PythonPath)) {
    Write-Host "ERROR: Python not found at: $PythonPath" -ForegroundColor Red
    Write-Host "Please update `$PythonPath in this script" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $ScriptPath)) {
    Write-Host "ERROR: Monitor script not found at: $ScriptPath" -ForegroundColor Red
    exit 1
}

# Check for NSSM
if (-not (Test-Path $NssmPath)) {
    Write-Host "NSSM (Non-Sucking Service Manager) not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Download NSSM from: https://nssm.cc/download" -ForegroundColor Cyan
    Write-Host "Extract nssm.exe to: $NssmPath" -ForegroundColor Cyan
    Write-Host ""

    $download = Read-Host "Download NSSM automatically? (Y/N)"
    if ($download -eq 'Y') {
        Write-Host "Downloading NSSM..." -ForegroundColor Cyan

        # Create tools directory
        New-Item -Path $NssmDir -ItemType Directory -Force | Out-Null

        # Download NSSM
        $nssmUrl = "https://nssm.cc/release/nssm-2.24.zip"
        $zipPath = "$env:TEMP\nssm.zip"
        $extractPath = "$env:TEMP\nssm"

        try {
            Invoke-WebRequest -Uri $nssmUrl -OutFile $zipPath -UseBasicParsing
            Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

            # Copy the appropriate version (64-bit)
            Copy-Item "$extractPath\nssm-2.24\win64\nssm.exe" $NssmPath

            Write-Host "NSSM downloaded successfully!" -ForegroundColor Green

            # Cleanup
            Remove-Item $zipPath -Force
            Remove-Item $extractPath -Recurse -Force
        }
        catch {
            Write-Host "ERROR: Failed to download NSSM: $_" -ForegroundColor Red
            Write-Host "Please download manually from: https://nssm.cc/download" -ForegroundColor Yellow
            exit 1
        }
    }
    else {
        exit 1
    }
}

# Check if service already exists
$existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host "Service '$ServiceName' already exists" -ForegroundColor Yellow
    Write-Host "Current status: $($existingService.Status)" -ForegroundColor $(if($existingService.Status -eq 'Running'){'Green'}else{'Yellow'})
    Write-Host ""

    $reinstall = Read-Host "Remove and reinstall service? (Y/N)"
    if ($reinstall -eq 'Y') {
        Write-Host "Stopping service..." -ForegroundColor Cyan
        Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2

        Write-Host "Removing service..." -ForegroundColor Cyan
        & $NssmPath remove $ServiceName confirm
        Start-Sleep -Seconds 2
    }
    else {
        Write-Host "Installation cancelled" -ForegroundColor Yellow
        exit 0
    }
}

# Install service
Write-Host ""
Write-Host "Installing service..." -ForegroundColor Cyan
& $NssmPath install $ServiceName $PythonPath $ScriptPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install service" -ForegroundColor Red
    exit 1
}

# Configure service
Write-Host "Configuring service..." -ForegroundColor Cyan

# Basic settings
& $NssmPath set $ServiceName DisplayName $DisplayName
& $NssmPath set $ServiceName Description $Description
& $NssmPath set $ServiceName AppDirectory $WorkingDir

# Startup settings
& $NssmPath set $ServiceName Start SERVICE_AUTO_START

# Output redirection to log file
& $NssmPath set $ServiceName AppStdout $LogFile
& $NssmPath set $ServiceName AppStderr $LogFile

# Restart settings (auto-restart on any exit)
& $NssmPath set $ServiceName AppExit Default Restart
& $NssmPath set $ServiceName AppRestartDelay 5000  # 5 second delay before restart

# Throttle (prevent restart loops if crashing immediately)
& $NssmPath set $ServiceName AppThrottle 10000  # 10 seconds

# Service dependencies (wait for network)
& $NssmPath set $ServiceName DependOnService Tcpip

Write-Host "Service configured successfully!" -ForegroundColor Green
Write-Host ""

# Start service
Write-Host "Starting service..." -ForegroundColor Cyan
& $NssmPath start $ServiceName

Start-Sleep -Seconds 3

# Check status
$service = Get-Service -Name $ServiceName
Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "SERVICE STATUS" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Name:        $($service.Name)" -ForegroundColor White
Write-Host "DisplayName: $($service.DisplayName)" -ForegroundColor White
Write-Host "Status:      $($service.Status)" -ForegroundColor $(if($service.Status -eq 'Running'){'Green'}else{'Red'})
Write-Host "StartType:   $($service.StartType)" -ForegroundColor White
Write-Host ""
Write-Host "Log File:    $LogFile" -ForegroundColor Cyan
Write-Host ""

if ($service.Status -eq 'Running') {
    Write-Host "✓ Service is running successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Management Commands:" -ForegroundColor Yellow
    Write-Host "  Get-Service $ServiceName                    # Check status" -ForegroundColor White
    Write-Host "  Restart-Service $ServiceName                # Restart service" -ForegroundColor White
    Write-Host "  Stop-Service $ServiceName                   # Stop service" -ForegroundColor White
    Write-Host "  Start-Service $ServiceName                  # Start service" -ForegroundColor White
    Write-Host ""
    Write-Host "View Logs:" -ForegroundColor Yellow
    Write-Host "  Get-Content '$LogFile' -Tail 20 -Wait       # Real-time logs (PowerShell)" -ForegroundColor White
    Write-Host "  python view-monitor-logs.py                 # Interactive log viewer" -ForegroundColor White
    Write-Host ""

    # Ask if they want to view logs now
    $viewLogs = Read-Host "Open real-time log viewer now? (Y/N)"
    if ($viewLogs -eq 'Y') {
        # Check if viewer exists
        $viewerPath = Join-Path $WorkingDir "view-monitor-logs.ps1"
        if (Test-Path $viewerPath) {
            Start-Process powershell -ArgumentList "-NoExit", "-Command", "& '$viewerPath'"
        }
        else {
            # Use simple tail
            Start-Process powershell -ArgumentList "-NoExit", "-Command", "Get-Content '$LogFile' -Tail 20 -Wait"
        }
    }
}
else {
    Write-Host "✗ Service failed to start" -ForegroundColor Red
    Write-Host "Check logs at: $LogFile" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Recent log entries:" -ForegroundColor Yellow
    if (Test-Path $LogFile) {
        Get-Content $LogFile -Tail 10
    }
    else {
        Write-Host "Log file not found - service may not have started" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "=" * 80 -ForegroundColor Cyan
