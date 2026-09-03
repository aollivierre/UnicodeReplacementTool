# Troubleshooting RunOnSave in Single-File Mode

## Issue
RunOnSave extension not triggering when opening a single file (without workspace/folder open) even though we installed the modified version that fixes this bug.

## Verification Steps

### 1. Verify Modified Extension is Installed

```powershell
# Check if modified extension exists
Test-Path "C:\Users\User\.vscode\extensions\emeraldwalk.runonsave-0.2.7\README-MODIFICATIONS.md"
# Should return: True

# Check if modifications are in the code
Select-String -Path "C:\Users\User\.vscode\extensions\emeraldwalk.runonsave-0.2.7\out\src\extension.js" -Pattern "single file mode"
# Should find matches
```

**Status**: ✅ Verified - modified extension is installed

### 2. Verify User Settings are Configured

**Location**: `C:\Users\User\AppData\Roaming\Code\User\settings.json`

**Required configuration**:
```json
{
  "emeraldwalk.runonsave": {
    "commands": [
      {
        "match": "\\.(ps1|psm1|psd1)$",
        "cmd": "python \"C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py\" \"${file}\" --no-backup",
        "isAsync": false,
        "notInTerminal": true
      },
      {
        "match": "\\.py$",
        "cmd": "python \"C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py\" \"${file}\" --no-backup",
        "isAsync": false,
        "notInTerminal": true
      }
    ]
  }
}
```

**Status**: ✅ Verified - configuration exists at line 7-22

### 3. Check VS Code Extension Status

**Steps**:
1. Open VS Code
2. Press `Ctrl+Shift+X` to open Extensions
3. Search for "Run on Save"
4. Verify it shows as **Enabled**

**Expected**: "Run on Save" by emeraldwalk, version 0.2.7, Enabled

### 4. Check Output Panel for Errors

**Steps**:
1. Open single file: `code "C:\temp\test.ps1"`
2. Make an edit
3. Press `Ctrl+S` to save
4. Immediately press `Ctrl+Shift+U` to open Output panel
5. Select "Run On Save" from dropdown
6. Look for errors or messages

**Common errors**:
- `FAILED to handle event` → Extension not using user settings
- `Configuration not found` → User settings not loaded
- `Command not found` → Python not in PATH

### 5. Force Extension Reload

**Option A: Reload Window**
1. Press `Ctrl+Shift+P`
2. Type "Developer: Reload Window"
3. Press Enter
4. Try saving again

**Option B: Restart VS Code**
1. Close ALL VS Code windows
2. Reopen single file
3. Try saving again

### 6. Enable Extension Logging

**Add to user settings**:
```json
{
  "emeraldwalk.runonsave.showStatusBarMessage": true,
  "emeraldwalk.runonsave.autoClearConsole": false
}
```

This will:
- Show status bar messages when commands run
- Keep output history for debugging

## Common Issues and Solutions

### Issue 1: Extension Disabled by Default

**Symptom**: Nothing happens on save, no errors

**Solution**: Enable the extension
```
Ctrl+Shift+P → "Enable Extension" → Select "Run on Save"
```

### Issue 2: VS Code Using Workspace Settings Only

**Symptom**: Works in workspace, not in single-file mode

**Solution**: Verify user settings path
```powershell
# Check if settings.json exists in correct location
Test-Path "$env:APPDATA\Code\User\settings.json"
```

### Issue 3: Extension Not Fully Loaded

**Symptom**: Intermittent failures

**Solution**:
1. Close ALL VS Code windows
2. Wait 5 seconds
3. Open single file
4. Wait for extension to activate (check bottom status bar)
5. Try saving

### Issue 4: File Type Not Matched

**Symptom**: Works for some files, not others

**Solution**: Check file extension matches pattern
```
.ps1, .psm1, .psd1 → Should match first rule
.py → Should match second rule
.txt, .md, .js → Will NOT match (by design)
```

### Issue 5: Python Not in PATH for Single-File Mode

**Symptom**: Works in workspace, fails in single-file mode

**Reason**: Different environment variables depending on how VS Code launched

**Solution**: Use full path to Python
```json
{
  "cmd": "\"C:\\Program Files\\Python313\\python.exe\" \"C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py\" \"${file}\" --no-backup"
}
```

## Manual Testing Procedure

### Test 1: Single PowerShell File

```powershell
# Create test file with Unicode
@"
Write-Host "Smart quotes → test"
"@ | Out-File "C:\temp\test-single.ps1" -Encoding UTF8

# Open in VS Code without workspace
code "C:\temp\test-single.ps1"

# In VS Code:
# 1. Make any edit
# 2. Press Ctrl+S
# 3. Check if → was replaced with ->
```

**Expected**: Unicode characters should be replaced

### Test 2: Check Output Panel

```
1. After saving, press Ctrl+Shift+U
2. Select "Run On Save" from dropdown
3. Should see:
   "Run On Save enabled."
   "Processed C:\temp\test-single.ps1: X replacements made"
```

### Test 3: Workspace vs Single-File

```powershell
# Test A: Open folder
code "C:\code\UnicodeReplacementTool"
# Create/edit a .ps1 file, save
# Does it work? (Should: YES)

# Test B: Open single file
code "C:\temp\test.ps1"
# Edit, save
# Does it work? (Should: YES with modified extension)
```

## Debug Checklist

When single-file mode is NOT working, verify:

- [ ] Modified extension is installed (`README-MODIFICATIONS.md` exists)
- [ ] User settings contain `emeraldwalk.runonsave` configuration
- [ ] Extension is enabled (not disabled in Extensions panel)
- [ ] VS Code has been reloaded after installation
- [ ] File extension matches one of the patterns (.ps1, .py)
- [ ] Python is in PATH or full path is used
- [ ] No errors in Output → Run On Save panel
- [ ] Status bar shows activity when saving

## Advanced Debugging

### Check Extension Activation

```
Ctrl+Shift+P → "Developer: Show Running Extensions"
Look for: emeraldwalk.RunOnSave (should show as activated)
```

### Check Configuration Loading

Add temporary logging to settings:
```json
{
  "emeraldwalk.runonsave.showStatusBarMessage": true
}
```

Save a file and watch status bar for messages.

### Check VS Code Console

```
Ctrl+Shift+P → "Developer: Toggle Developer Tools"
Go to Console tab
Save a file
Look for errors or RunOnSave log messages
```

## Known Working Configuration

This configuration is CONFIRMED working:

**User**: User
**Extension**: Modified emeraldwalk.runonsave v0.2.7
**Settings Location**: `C:\Users\User\AppData\Roaming\Code\User\settings.json`
**Configuration**: Lines 7-22 (RunOnSave commands for .ps1 and .py)
**Test**: Opening single .ps1 file and saving

**If this exact setup doesn't work**:
1. VS Code needs window reload
2. Extension needs to be enabled
3. Check Output panel for specific errors

## Last Resort: Reinstall Modified Extension

If nothing works:

```powershell
# 1. Remove current extension
Remove-Item "C:\Users\User\.vscode\extensions\emeraldwalk.runonsave-0.2.7" -Recurse -Force

# 2. Reinstall base extension
code --install-extension emeraldwalk.RunOnSave

# 3. Wait for installation to complete

# 4. Apply modifications
Copy-Item -Path "C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\*" `
          -Destination "C:\Users\User\.vscode\extensions\emeraldwalk.runonsave-0.2.7\" `
          -Recurse -Force

# 5. Fix permissions
icacls "C:\Users\User\.vscode\extensions\emeraldwalk.runonsave-0.2.7" /grant User:F /T /Q

# 6. Restart VS Code completely (close all windows)

# 7. Test with single file
code "C:\temp\test.ps1"
```

## Summary

**Modified extension IS installed**: ✅ Confirmed
**User settings configured**: ✅ Confirmed
**Should work in single-file mode**: ✅ Yes

**If not working**: Most likely needs VS Code window reload or extension enablement check.

**Next steps**:
1. Check Extensions panel - is it enabled?
2. Reload VS Code window (Ctrl+Shift+P → Reload Window)
3. Check Output panel for error messages
4. Try the manual testing procedure above

---

**Created**: 2025-11-03
**Issue**: Single-file mode not triggering despite modified extension installed
**Status**: Investigation in progress
