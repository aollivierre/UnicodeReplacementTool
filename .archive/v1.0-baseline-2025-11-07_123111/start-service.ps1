Start-Service UnicodeMonitor
Start-Sleep -Seconds 3
$service = Get-Service UnicodeMonitor
Write-Host "Service Status: $($service.Status)" -ForegroundColor $(if($service.Status -eq 'Running'){'Green'}else{'Red'})
