# HyperSpeed Unicode Monitor Deployment Script
# Deploys the sub-millisecond response monitor

param(
    [switch]$Force = $false
)

Write-Host "="*70 -ForegroundColor Cyan
Write-Host "HYPERSPEED UNICODE MONITOR DEPLOYMENT" -ForegroundColor Cyan
Write-Host "="*70 -ForegroundColor Cyan
Write-Host "Target: Sub-0.5ms response time" -ForegroundColor Yellow
Write-Host ""

# Check if ultra-fast monitor exists
$UltraFastTask = "UnicodeUltraFastMonitor"
$HyperSpeedTask = "UnicodeHyperSpeedMonitor"

Write-Host "1. Checking existing monitors..." -ForegroundColor Green

$ExistingUltraFast = Get-ScheduledTask -TaskName $UltraFastTask -ErrorAction SilentlyContinue
$ExistingHyperSpeed = Get-ScheduledTask -TaskName $HyperSpeedTask -ErrorAction SilentlyContinue

if ($ExistingUltraFast) {
    Write-Host "   Found existing Ultra-Fast monitor (1.5ms)" -ForegroundColor Yellow
    if ($Force) {
        Write-Host "   Stopping and removing..." -ForegroundColor Yellow
        Stop-ScheduledTask -TaskName $UltraFastTask -ErrorAction SilentlyContinue
        Unregister-ScheduledTask -TaskName $UltraFastTask -Confirm:$false
        Write-Host "   [OK] Removed Ultra-Fast monitor" -ForegroundColor Green
    } else {
        Write-Host "   Use -Force to replace with HyperSpeed monitor" -ForegroundColor Red
        exit 1
    }
}

if ($ExistingHyperSpeed) {
    Write-Host "   HyperSpeed monitor already exists" -ForegroundColor Yellow
    Write-Host "   Current status: $($ExistingHyperSpeed.State)" -ForegroundColor Yellow

    if ($Force) {
        Write-Host "   Recreating..." -ForegroundColor Yellow
        Stop-ScheduledTask -TaskName $HyperSpeedTask -ErrorAction SilentlyContinue
        Unregister-ScheduledTask -TaskName $HyperSpeedTask -Confirm:$false
    } else {
        Write-Host "   Use -Force to recreate" -ForegroundColor Red
        exit 1
    }
}

Write-Host "2. Validating monitor script..." -ForegroundColor Green

$MonitorScript = "C:\temp\unicode-hyperspeed-monitor.py"
if (-not (Test-Path $MonitorScript)) {
    Write-Host "   [FAIL] Monitor script not found: $MonitorScript" -ForegroundColor Red
    Write-Host "   Please ensure the hyperspeed monitor is in C:\temp\" -ForegroundColor Red
    exit 1
}

Write-Host "   [OK] Monitor script found" -ForegroundColor Green

# Test Python availability
try {
    $PythonPath = (Get-Command python).Source
    Write-Host "   [OK] Python found: $PythonPath" -ForegroundColor Green
} catch {
    Write-Host "   [FAIL] Python not found in PATH" -ForegroundColor Red
    exit 1
}

Write-Host "3. Creating HyperSpeed scheduled task..." -ForegroundColor Green

# Create scheduled task
$Action = New-ScheduledTaskAction -Execute "python.exe" -Argument "`"$MonitorScript`""
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable:$false
$Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Add startup delay for system readiness
$Trigger.Delay = "PT30S"

# Configure restart on failure
$Settings.RestartCount = 3
$Settings.RestartInterval = "PT1M"

Register-ScheduledTask -TaskName $HyperSpeedTask -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Description "Ultra-fast Unicode replacement monitor targeting sub-0.5ms response time" | Out-Null

Write-Host "   [OK] Task created: $HyperSpeedTask" -ForegroundColor Green

Write-Host "4. Starting monitor..." -ForegroundColor Green

Start-ScheduledTask -TaskName $HyperSpeedTask
Start-Sleep -Seconds 2

$TaskInfo = Get-ScheduledTask -TaskName $HyperSpeedTask
Write-Host "   Status: $($TaskInfo.State)" -ForegroundColor Green

if ($TaskInfo.State -eq "Running") {
    Write-Host "   [OK] HyperSpeed monitor is running" -ForegroundColor Green
} else {
    Write-Host "   [WARNING] Monitor may not have started correctly" -ForegroundColor Yellow
}

Write-Host "5. Configuration summary..." -ForegroundColor Green
Write-Host "   Task Name: $HyperSpeedTask" -ForegroundColor White
Write-Host "   Script: $MonitorScript" -ForegroundColor White
Write-Host "   Principal: NT AUTHORITY\SYSTEM" -ForegroundColor White
Write-Host "   Startup: At system boot (30s delay)" -ForegroundColor White
Write-Host "   Target Performance: <500 microseconds" -ForegroundColor White
Write-Host "   Log File: C:\code\vscode.ext\Logs\unicode-hyperspeed.log" -ForegroundColor White

Write-Host ""
Write-Host "="*70 -ForegroundColor Cyan
Write-Host "HYPERSPEED MONITOR DEPLOYED SUCCESSFULLY" -ForegroundColor Green
Write-Host "="*70 -ForegroundColor Cyan
Write-Host ""
Write-Host "Management commands:" -ForegroundColor Yellow
Write-Host "  Get-ScheduledTask -TaskName '$HyperSpeedTask'" -ForegroundColor White
Write-Host "  Start-ScheduledTask -TaskName '$HyperSpeedTask'" -ForegroundColor White
Write-Host "  Stop-ScheduledTask -TaskName '$HyperSpeedTask'" -ForegroundColor White
Write-Host "  Get-Content 'C:\code\vscode.ext\Logs\unicode-hyperspeed.log' -Tail 10" -ForegroundColor White
Write-Host ""
Write-Host "Performance target: Files processed in <0.5ms each" -ForegroundColor Green
Write-Host "Expected improvement: 3x faster than current 1.5ms monitor" -ForegroundColor Green