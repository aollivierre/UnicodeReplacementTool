# Download Python installer
$url = "https://www.python.org/ftp/python/3.13.5/python-3.13.5-amd64.exe"
$output = "C:\code\UnicodeReplacementTool\TestEnvironment\python-installer.exe"

Write-Host "Downloading Python 3.13.5..."
Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing

Write-Host "Download complete. Installing Python..."
# Install Python silently with PATH addition
Start-Process -FilePath $output -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait

Write-Host "Python installation complete!"