$ErrorActionPreference = "Stop"

Write-Host "Installing Unicode Monitor Service..." -ForegroundColor Cyan

# Configuration
$ServiceName = "UnicodeMonitor"
$DisplayName = "Unicode Ultra-Fast Monitor"
$Description = "Real-time Unicode replacement monitor - 1.94x optimized"
$ScriptPath = "C:\code\UnicodeReplacementTool\vscode.ext\unicode-ultrafast-monitor-optimized.py"
$PythonPath = "C:\Program Files\Python313\python.exe"
$WorkingDir = "C:\code\UnicodeReplacementTool\vscode.ext"
$LogFile = "C:\code\UnicodeReplacementTool\vscode.ext\Logs\unicode-ultrafast.log"
$NssmPath = "C:\code\tools\nssm.exe"

# Ensure log directory exists
New-Item -Path (Split-Path $LogFile) -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

# Check if old tasks exist
Write-Host "Checking for old scheduled tasks..." -ForegroundColor Yellow
$oldTasks = @("UnicodeUltraFastMonitor", "UnicodeRealtimeMonitor", "UnicodeScanner")
foreach ($taskName in $oldTasks) {
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($task) {
        Write-Host "  Disabling old task: $taskName" -ForegroundColor Yellow
        Disable-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue | Out-Null
    }
}

# Check if service already exists
$existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Service already exists, removing..." -ForegroundColor Yellow
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    & $NssmPath remove $ServiceName confirm
    Start-Sleep -Seconds 2
}

# Install service
Write-Host "Installing service..." -ForegroundColor Cyan
& $NssmPath install $ServiceName $PythonPath $ScriptPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install service" -ForegroundColor Red
    exit 1
}

# Configure service
Write-Host "Configuring service..." -ForegroundColor Cyan
& $NssmPath set $ServiceName DisplayName $DisplayName
& $NssmPath set $ServiceName Description $Description
& $NssmPath set $ServiceName AppDirectory $WorkingDir
& $NssmPath set $ServiceName Start SERVICE_AUTO_START
& $NssmPath set $ServiceName AppStdout $LogFile
& $NssmPath set $ServiceName AppStderr $LogFile
& $NssmPath set $ServiceName AppExit Default Restart
& $NssmPath set $ServiceName AppRestartDelay 5000
& $NssmPath set $ServiceName AppThrottle 10000
& $NssmPath set $ServiceName DependOnService Tcpip

Write-Host "Starting service..." -ForegroundColor Cyan
& $NssmPath start $ServiceName

Start-Sleep -Seconds 3

# Check status
$service = Get-Service -Name $ServiceName
Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "SERVICE INSTALLED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Name:        $($service.Name)" -ForegroundColor White
Write-Host "DisplayName: $($service.DisplayName)" -ForegroundColor White
Write-Host "Status:      $($service.Status)" -ForegroundColor $(if($service.Status -eq 'Running'){'Green'}else{'Red'})
Write-Host "StartType:   $($service.StartType)" -ForegroundColor White
Write-Host ""
Write-Host "Log File:    $LogFile" -ForegroundColor Cyan
Write-Host ""

if ($service.Status -eq 'Running') {
    Write-Host "[SUCCESS] Service is running!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Management Commands:" -ForegroundColor Yellow
    Write-Host "  Get-Service $ServiceName           # Check status" -ForegroundColor White
    Write-Host "  Restart-Service $ServiceName       # Restart" -ForegroundColor White
    Write-Host ""
    Write-Host "View Logs:" -ForegroundColor Yellow
    Write-Host "  .\view-monitor-logs.ps1            # Interactive viewer" -ForegroundColor White
    Write-Host "  python view-monitor-logs.py        # Python viewer" -ForegroundColor White
} else {
    Write-Host "[ERROR] Service failed to start" -ForegroundColor Red
    if (Test-Path $LogFile) {
        Write-Host "Recent logs:" -ForegroundColor Yellow
        Get-Content $LogFile -Tail 10
    }
}
