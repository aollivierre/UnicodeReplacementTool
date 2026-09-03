# Script to remove all Notepad fallback logic from cookie extraction

$file1 = "C:\code\connectwise-rmm-automation\src\inventory\connectwise_inventory.py"
$file2 = "C:\code\Win11UpgradeScheduler\win11report\Win11_Dashboard_RMM_AUTO.py"

Write-Host "[1/3] Reading connectwise_inventory.py..."
$content1 = Get-Content $file1 -Raw

Write-Host "[2/3] Removing Notepad fallback logic from connectwise_inventory.py..."

# Remove the _open_cookie_in_notepad method entirely
$content1 = $content1 -replace '(?ms)    def _open_cookie_in_notepad\(self, cookie_file: str\) -> bool:.*?return False\r?\n', ''

# Simplify the authenticate method
$content1 = $content1 -replace 'automated_extraction_succeeded: If True, skip Notepad fallback \(Playwright/CDP already ran\)', 'automated_extraction_succeeded: Deprecated parameter (kept for compatibility)'
$content1 = $content1 -replace 'self\.headers = self\._setup_headers_with_validation\(cookie_file, use_notepad_fallback=\(not automated_extraction_succeeded\)\)', 'self.headers = self._setup_headers_with_validation(cookie_file)'

# Simplify _setup_headers_with_validation signature
$content1 = $content1 -replace 'def _setup_headers_with_validation\(self, cookie_file: str, max_attempts: int = 3, use_notepad_fallback: bool = True\)', 'def _setup_headers_with_validation(self, cookie_file: str, max_attempts: int = 1)'
$content1 = $content1 -replace '(?m)^        Args:\r?\n            cookie_file: Path to cookie file\r?\n            max_attempts: Maximum validation attempts\r?\n            use_notepad_fallback: If False, skip Notepad prompts \(when automated extraction was used\)\r?\n', "        Args:`r`n            cookie_file: Path to cookie file`r`n            max_attempts: Maximum validation attempts (always 1 now - no retries)`r`n"

# Remove all Notepad fallback logic from the validation loop
$content1 = $content1 -replace '(?m)^                if use_notepad_fallback:\r?\n                    self\._open_cookie_in_notepad\(cookie_file\)\r?\n                else:\r?\n                    print\(f"\[ERROR\] Cookie file not found: \{cookie_file\}"\)\r?\n                    return None\r?\n', "                print(f`"[ERROR] Cookie file not found: {cookie_file}`")`r`n                return None`r`n"

$content1 = $content1 -replace '(?m)^                    if use_notepad_fallback:\r?\n                        self\._open_cookie_in_notepad\(cookie_file\)\r?\n                        with open\(cookie_file, ''r''\) as f:\r?\n                            cookie_string = f\.read\(\)\.strip\(\)\r?\n                    else:\r?\n                        print\(f"\[ERROR\] Cookie file is empty or contains placeholder text"\)\r?\n                        return None\r?\n', "                    print(f`"[ERROR] Cookie file is empty or contains placeholder text`")`r`n                    return None`r`n"

$content1 = $content1 -replace '(?m)^                elif attempt < max_attempts:\r?\n                    if use_notepad_fallback:\r?\n                        print\(f"\[RETRY\] Cookie validation failed, opening Notepad for manual entry\.\.\."\)\r?\n                        self\._open_cookie_in_notepad\(cookie_file\)\r?\n                    else:\r?\n                        print\(f"\[ERROR\] Cookie validation failed \(automated extraction may have failed\)"\)\r?\n                        return None\r?\n', "                else:`r`n                    print(f`"[ERROR] Cookie validation failed - automated extraction likely failed`")`r`n                    return None`r`n"

$content1 = $content1 -replace '(?m)^                if attempt < max_attempts:\r?\n                    if use_notepad_fallback:\r?\n                        print\(f"\[ERROR\] \{e\} - opening Notepad for manual entry\.\.\."\)\r?\n                        self\._open_cookie_in_notepad\(cookie_file\)\r?\n                    else:\r?\n                        print\(f"\[ERROR\] \{e\}"\)\r?\n                        return None\r?\n', "                print(f`"[ERROR] {e}`")`r`n                return None`r`n"

Write-Host "[OK] Removed Notepad fallback from connectwise_inventory.py"
$content1 | Set-Content $file1 -NoNewline

Write-Host "[3/3] Removing Notepad fallback logic from Win11_Dashboard_RMM_AUTO.py..."
$content2 = Get-Content $file2 -Raw

# Remove fallback_to_notepad config
$content2 = $content2 -replace '(?m)^            "fallback_to_notepad": True\r?\n', ''

# Remove the entire fallback authentication block
$content2 = $content2 -replace '(?ms)            # If authentication failed and automated extraction didn''t run/failed, try Notepad fallback.*?if auth_success:\r?\n                inventory = fallback_inventory  # Use the successfully authenticated instance\r?\n\r?\n', ''

Write-Host "[OK] Removed Notepad fallback from Win11_Dashboard_RMM_AUTO.py"
$content2 | Set-Content $file2 -NoNewline

Write-Host ""
Write-Host "============================================"
Write-Host " NOTEPAD FALLBACK COMPLETELY ERADICATED"
Write-Host "============================================"
Write-Host ""
Write-Host "Modified files:"
Write-Host "  - $file1"
Write-Host "  - $file2"
Write-Host ""
Write-Host "All Notepad fallback logic has been removed."
Write-Host "Only Playwright cookie extraction remains."
