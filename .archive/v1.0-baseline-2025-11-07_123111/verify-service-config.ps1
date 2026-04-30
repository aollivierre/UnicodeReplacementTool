$nssm = "C:\code\tools\nssm.exe"
Write-Host "Service Configuration:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Script Path:" -ForegroundColor Yellow
& $nssm get UnicodeMonitor Application
& $nssm get UnicodeMonitor AppParameters
Write-Host ""
Write-Host "Status:" -ForegroundColor Yellow
$service = Get-Service UnicodeMonitor
Write-Host "  Running: $($service.Status -eq 'Running')" -ForegroundColor $(if($service.Status -eq 'Running'){'Green'}else{'Red'})
