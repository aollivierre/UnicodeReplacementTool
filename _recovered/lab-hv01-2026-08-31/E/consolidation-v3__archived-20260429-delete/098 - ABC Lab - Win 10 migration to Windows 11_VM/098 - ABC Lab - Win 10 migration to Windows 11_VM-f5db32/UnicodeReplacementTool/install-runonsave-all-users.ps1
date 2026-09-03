# Install Modified RunOnSave Extension for All Users
# This script installs the modified RunOnSave extension for all users on the system

param(
    [switch]$Force
)

$sourceExtension = "C:\Users\i\.vscode\extensions\emeraldwalk.runonsave-0.2.7"
$users = Get-ChildItem C:\Users -Directory | Where-Object {
    $_.Name -notin @('All Users', 'Default', 'Default User', 'Public')
}

Write-Host "Installing Modified RunOnSave Extension for All Users" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

if (!(Test-Path $sourceExtension)) {
    Write-Host "ERROR: Source extension not found at: $sourceExtension" -ForegroundColor Red
    Write-Host "Please install the extension for user 'i' first." -ForegroundColor Yellow
    exit 1
}

foreach ($user in $users) {
    $userName = $user.Name
    $userExtensionsPath = "C:\Users\$userName\.vscode\extensions"
    $targetExtension = "$userExtensionsPath\emeraldwalk.runonsave-0.2.7"
    $extensionsJson = "$userExtensionsPath\extensions.json"

    Write-Host "Processing user: $userName" -ForegroundColor Yellow

    # Check if user has VS Code installed
    if (!(Test-Path $userExtensionsPath)) {
        Write-Host "  Skipped - VS Code not installed for this user" -ForegroundColor Gray
        continue
    }

    # Copy extension files
    if (Test-Path $targetExtension) {
        Write-Host "  Extension already exists - updating..." -ForegroundColor Yellow
        Remove-Item $targetExtension -Recurse -Force
    }

    Copy-Item -Path $sourceExtension -Destination $targetExtension -Recurse -Force
    Write-Host "  Extension files copied" -ForegroundColor Green

    # Update extensions.json
    if (Test-Path $extensionsJson) {
        try {
            $jsonContent = Get-Content $extensionsJson -Raw | ConvertFrom-Json

            # Check if extension already registered
            $existingEntry = $jsonContent | Where-Object {
                $_.identifier.id -eq "emeraldwalk.runonsave"
            }

            if (!$existingEntry) {
                Write-Host "  Registering extension in extensions.json..." -ForegroundColor Yellow

                # Create new extension entry
                $newEntry = @{
                    identifier = @{
                        id = "emeraldwalk.runonsave"
                        uuid = "f5531ff0-6d38-42e1-9eda-168ce9b4c478"
                    }
                    version = "0.2.7"
                    location = @{
                        '$mid' = 1
                        path = "/c:/Users/$userName/.vscode/extensions/emeraldwalk.runonsave-0.2.7"
                        scheme = "file"
                    }
                    relativeLocation = "emeraldwalk.runonsave-0.2.7"
                    metadata = @{
                        isApplicationScoped = $false
                        isMachineScoped = $false
                        isBuiltin = $false
                        installedTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
                        pinned = $false
                        source = "gallery"
                        id = "f5531ff0-6d38-42e1-9eda-168ce9b4c478"
                        publisherId = "49cf6c77-f923-4931-8d3e-2bd8d02e34ab"
                        publisherDisplayName = "emeraldwalk"
                        targetPlatform = "undefined"
                        updated = $false
                        private = $false
                        isPreReleaseVersion = $false
                        hasPreReleaseVersion = $false
                        preRelease = $false
                    }
                }

                # Add to array
                $jsonArray = @($jsonContent)
                $jsonArray += $newEntry

                # Save back
                $jsonArray | ConvertTo-Json -Depth 10 -Compress | Set-Content $extensionsJson -NoNewline
                Write-Host "  Extension registered successfully" -ForegroundColor Green
            } else {
                Write-Host "  Extension already registered" -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "  WARNING: Could not update extensions.json: $_" -ForegroundColor Yellow
            Write-Host "  Extension files are installed, but VS Code may need to rescan" -ForegroundColor Yellow
        }
    }

    Write-Host "  Completed for $userName" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps for each user:" -ForegroundColor Yellow
Write-Host "1. Restart VS Code if it's running" -ForegroundColor White
Write-Host "2. Configure settings.json in your workspace with emeraldwalk.runonsave settings" -ForegroundColor White
Write-Host "3. Test by saving a file with Ctrl+S" -ForegroundColor White
