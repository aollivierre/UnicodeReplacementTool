# Direct fix for Win11_Dashboard_RMM_AUTO.py

$file = "C:\code\Win11UpgradeScheduler\win11report\Win11_Dashboard_RMM_AUTO.py"

Write-Host "Reading file..."
$content = Get-Content $file -Raw

Write-Host "Removing Notepad fallback block..."
$old = @'
            inventory = ConnectWiseInventory(inv_config)
            auth_success = inventory.authenticate(automated_extraction_succeeded=automated_extraction_succeeded)

            # If authentication failed and automated extraction didn't run/failed, try Notepad fallback
            if not auth_success and not automated_extraction_succeeded:
                print("[FALLBACK] Automated extraction failed - trying manual Notepad method...")
                # Create new inventory with Notepad fallback enabled
                fallback_inventory = ConnectWiseInventory(inv_config)
                auth_success = fallback_inventory.authenticate(automated_extraction_succeeded=False)
                if auth_success:
                    inventory = fallback_inventory  # Use the successfully authenticated instance

            if auth_success:
'@

$new = @'
            inventory = ConnectWiseInventory(inv_config)
            auth_success = inventory.authenticate(automated_extraction_succeeded=automated_extraction_succeeded)

            if auth_success:
'@

$content = $content.Replace($old, $new)

Write-Host "Writing file..."
$content | Set-Content $file -NoNewline

Write-Host "[OK] Notepad fallback removed from Win11_Dashboard_RMM_AUTO.py"
