# AI Engineer Setup Guide - RunOnSave Extension for Unicode Replacement

## Overview

This guide documents the complete setup process for installing and configuring the modified RunOnSave VS Code extension across all users on a Windows system. This extension automatically replaces Unicode characters with ASCII equivalents when files are saved (Ctrl+S).

**Target Audience**: AI Engineers taking over this codebase
**Purpose**: Ensure consistent, error-free setup without repeating past mistakes
**Last Updated**: 2025-11-03

---

## Architecture Overview

### Components

1. **Modified RunOnSave Extension**
   - Base: emeraldwalk.RunOnSave v0.2.7
   - Modified version location: `C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\`
   - Modification: Fixed bug where extension did not work in single-file workspace mode
   - Key modification file: `C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\out\src\extension.js`

2. **Unicode Replacer Script**
   - Location: `C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py`
   - Purpose: Replaces Unicode characters with ASCII equivalents
   - Called by: RunOnSave extension on file save

3. **Installation Scripts**
   - All-users installer: `C:\code\UnicodeReplacementTool\install-runonsave-all-users.ps1`
   - Workspace configurator: `C:\code\UnicodeReplacementTool\setup-runonsave-workspace.ps1`
   - Extension verification: `C:\code\UnicodeReplacementTool\check-user-extension.ps1`
   - Original modified installer: `C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\install-modified-extension.ps1`

4. **Settings Files**
   - User settings (per user): `C:\Users\<USERNAME>\AppData\Roaming\Code\User\settings.json`
   - Workspace settings: `<WORKSPACE_ROOT>\.vscode\settings.json`
   - Extension registration: `C:\Users\<USERNAME>\.vscode\extensions\extensions.json`

---

## Installation Process - Step by Step

### CRITICAL: Order of Operations

**DO NOT deviate from this order. Past mistakes occurred by skipping steps.**

### Step 1: Install Base Extension

```
Command: code --install-extension emeraldwalk.RunOnSave
```

**Wait for completion** before proceeding. Do not proceed to Step 2 until you see:
```
Extension 'emeraldwalk.runonsave' v0.2.7 was successfully installed.
```

**Location after install**: `C:\Users\<CURRENT_USER>\.vscode\extensions\emeraldwalk.runonsave-0.2.7`

### Step 2: Apply Modified Version

Run the installer script (see: `C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\install-modified-extension.ps1`)

**What this does**:
- Creates backup of original extension
- Replaces `out\src\extension.js` with modified version
- Adds documentation file

**IMPORTANT**: VS Code must be closed OR use `-Force` flag.

### Step 3: Install for All Users

Run: `C:\code\UnicodeReplacementTool\install-runonsave-all-users.ps1`

**What this does**:
- Copies modified extension to all user profiles
- Registers extension in each user's `extensions.json`
- Sets correct file permissions

**Common mistake**: Running this before Step 1 completes. The script expects the modified extension to exist in user 'i' profile first.

### Step 4: Fix File Permissions (Critical for Multi-User)

For each additional user, run:
```powershell
icacls "C:\Users\<USERNAME>\.vscode\extensions\emeraldwalk.runonsave-0.2.7" /grant <USERNAME>:F /T /Q
```

**Why this matters**: Files copied from one user's profile retain original ownership. Without this, VS Code cannot read `package.json` and the extension fails silently.

**Error you'll see if skipped**:
```
Unable to read file 'c:\Users\<USERNAME>\.vscode\extensions\emeraldwalk.runonsave-0.2.7\package.json'
(Error: Unable to resolve nonexistent file...)
```

### Step 5: Configure User Settings

**Location**: `C:\Users\<USERNAME>\AppData\Roaming\Code\User\settings.json`

**Required settings block**: See `C:\code\UnicodeReplacementTool\vscode.ext\.vscode\settings.json` for reference configuration.

**Key settings**:
- `emeraldwalk.runonsave.commands`: Array of file patterns and commands
- `files.encoding`: "utf8"
- `files.autoGuessEncoding`: false
- Unicode highlighting settings (recommended)

**CRITICAL PATH**: The `cmd` property MUST use the correct path to `unicode_replacer.py`:
```
"cmd": "python \"C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py\" \"${file}\" --no-backup"
```

Note the double backslashes in JSON.

### Step 6: Verify Installation

Run verification script: `C:\code\UnicodeReplacementTool\check-user-extension.ps1`

**Expected output**: JSON showing extension is registered with correct metadata.

**If extension not found**: Repeat Steps 3-4.

---

## Configuration References

### User Settings Location

**Path**: `C:\Users\<USERNAME>\AppData\Roaming\Code\User\settings.json`

**Example reference**: `C:\Users\User\AppData\Roaming\Code\User\settings.json`

**Reference configuration**: `C:\code\UnicodeReplacementTool\vscode.ext\.vscode\settings.json`

### Workspace Settings Location

**Path**: `<WORKSPACE_ROOT>\.vscode\settings.json`

**Example**: `C:\code\UnicodeReplacementTool\.vscode\settings.json`

**Can be created with**: `C:\code\UnicodeReplacementTool\setup-runonsave-workspace.ps1`

### Extension Registration Location

**Path**: `C:\Users\<USERNAME>\.vscode\extensions\extensions.json`

**Example**: `C:\Users\User\.vscode\extensions\extensions.json`

**Modified by**: `C:\code\UnicodeReplacementTool\install-runonsave-all-users.ps1`

---

## Common Mistakes & How to Avoid Them

### Mistake 1: Incorrect Installation Order

❌ **Wrong**: Install for all users before installing base extension
✅ **Correct**: Install base extension first, then modify, then distribute

### Mistake 2: Forgetting File Permissions

❌ **Wrong**: Copy extension files and assume it works
✅ **Correct**: Always run `icacls` to grant target user full permissions

**Symptom**: Extension shows in Extensions list but doesn't activate. `package.json` read errors in console.

### Mistake 3: Wrong Path to unicode_replacer.py

❌ **Wrong**:
```json
"cmd": "python C:\\code\\UnicodeReplacementTool\\unicode_replacer.py ..."
```

✅ **Correct**:
```json
"cmd": "python \"C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py\" ..."
```

**Note the nested folder structure**: The actual script is in `UnicodeReplacementTool\UnicodeReplacementTool\`

### Mistake 4: Not Reloading VS Code

After any settings changes or extension installation:
- Press `Ctrl+Shift+P` → "Developer: Reload Window"
- OR restart VS Code completely

### Mistake 5: Modifying Wrong Settings File

**Three levels of settings exist**:
1. **User settings** (global): `C:\Users\<USERNAME>\AppData\Roaming\Code\User\settings.json`
2. **Workspace settings** (per workspace): `<WORKSPACE>\.vscode\settings.json`
3. **Folder settings** (deprecated in most cases)

**For this extension**: User settings take precedence. Configure at user level for global effect.

---

## Verification Checklist

Use this checklist after installation:

- [ ] Base extension installed: `code --list-extensions | grep emeraldwalk.runonsave`
- [ ] Modified extension files present: Check `C:\Users\<USERNAME>\.vscode\extensions\emeraldwalk.runonsave-0.2.7\README-MODIFICATIONS.md` exists
- [ ] File permissions correct: Run `icacls "C:\Users\<USERNAME>\.vscode\extensions\emeraldwalk.runonsave-0.2.7"` and verify user has (F)ull access
- [ ] Extension registered: Run `C:\code\UnicodeReplacementTool\check-user-extension.ps1`
- [ ] User settings configured: Check `emeraldwalk.runonsave` block exists in `C:\Users\<USERNAME>\AppData\Roaming\Code\User\settings.json`
- [ ] No errors in VS Code: Open Output panel → Filter "Run On Save"
- [ ] Functional test: Create test file with unicode, save with Ctrl+S, verify replacement occurs

---

## Testing the Setup

### Test File Creation

Create a test file: `C:\temp\test-unicode-replacement.ps1`

**Content**:
```powershell
# Test file with unicode characters
Write-Host "Test – with en-dash"
Write-Host "Test — with em-dash"
Write-Host "Test ' with smart quote"
```

### Test Procedure

1. Open VS Code as target user
2. Open the test file
3. Press `Ctrl+S`
4. Verify characters are replaced:
   - `–` (en-dash) becomes `-`
   - `—` (em-dash) becomes `--`
   - `'` (smart quote) becomes `'`

### Expected Behavior

- Replacement happens immediately on save
- No backup file created (due to `--no-backup` flag)
- No terminal window appears (due to `"notInTerminal": true`)
- File is updated in-place

### Troubleshooting Failed Test

**If nothing happens on save**:

1. Check Output panel: View → Output → "Run On Save"
2. Look for errors like:
   - "Command not found" → Check `python` is in PATH
   - "File not found" → Check `unicode_replacer.py` path
   - "Permission denied" → Run `icacls` fix (Step 4)
3. Reload VS Code window
4. Check extension is enabled: Extensions → "Run on Save" should show "Enabled"

---

## Script Reference

### Installation Scripts

| Script | Path | Purpose |
|--------|------|---------|
| Base extension installer | N/A | Run: `code --install-extension emeraldwalk.RunOnSave` |
| Modified extension installer | `C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\install-modified-extension.ps1` | Applies bug fix to base extension |
| All-users installer | `C:\code\UnicodeReplacementTool\install-runonsave-all-users.ps1` | Distributes extension to all user profiles |
| Workspace configurator | `C:\code\UnicodeReplacementTool\setup-runonsave-workspace.ps1` | Creates/updates workspace settings |
| Verification script | `C:\code\UnicodeReplacementTool\check-user-extension.ps1` | Checks if extension is registered for specific user |

### Core Script

| Script | Path | Purpose |
|--------|------|---------|
| Unicode replacer | `C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py` | Performs actual unicode-to-ASCII replacement |

---

## Settings Documentation

### Required Settings Keys

#### `emeraldwalk.runonsave`

**Type**: Object
**Required**: Yes
**Purpose**: Configures RunOnSave extension behavior

**Reference**: See `C:\code\UnicodeReplacementTool\vscode.ext\.vscode\settings.json:2-17`

**Structure**:
```json
{
  "commands": [
    {
      "match": "<regex>",
      "cmd": "<command>",
      "isAsync": false,
      "notInTerminal": true
    }
  ]
}
```

**Key properties**:
- `match`: Regex pattern for file matching (e.g., `"\\.(ps1|psm1|psd1)$"`)
- `cmd`: Command to execute. Use `${file}` placeholder for current file path
- `isAsync`: Set to `false` for synchronous execution
- `notInTerminal`: Set to `true` to run silently without terminal window

#### `files.encoding`

**Type**: String
**Required**: Recommended
**Value**: `"utf8"`
**Purpose**: Ensures consistent file encoding

**Reference**: See `C:\code\UnicodeReplacementTool\vscode.ext\.vscode\settings.json:19`

#### `files.autoGuessEncoding`

**Type**: Boolean
**Required**: Recommended
**Value**: `false`
**Purpose**: Prevents encoding detection issues

**Reference**: See `C:\code\UnicodeReplacementTool\vscode.ext\.vscode\settings.json:20`

#### `[powershell]` Language-Specific Settings

**Type**: Object
**Required**: For PowerShell files
**Purpose**: PowerShell-specific encoding settings

**Reference**: See `C:\code\UnicodeReplacementTool\vscode.ext\.vscode\settings.json:22-25`

**Keys**:
- `files.encoding`: `"utf8"`
- `files.eol`: `"\r\n"` (Windows line endings)

#### Unicode Highlighting Settings

**Type**: Boolean
**Required**: Optional (recommended)
**Purpose**: Visual indicators for unicode characters

**Reference**: See `C:\code\UnicodeReplacementTool\vscode.ext\.vscode\settings.json:27-31`

**Keys**:
- `editor.unicodeHighlight.ambiguousCharacters`
- `editor.unicodeHighlight.invisibleCharacters`
- `editor.unicodeHighlight.nonBasicASCII`
- `editor.unicodeHighlight.includeComments`
- `editor.unicodeHighlight.includeStrings`

---

## Extension Modification Details

### What Was Modified

**Original issue**: RunOnSave extension did not trigger when VS Code was opened with a single file (not a workspace).

**File modified**: `out\src\extension.js` in the extension directory

**Location of modified source**: `C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\out\src\extension.js`

**Documentation of changes**: See `C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\README-MODIFICATIONS.md`

### Backup Location

**Original extension backup**: `C:\Users\<USERNAME>\.vscode\extensions\emeraldwalk.runonsave-0.2.7-original`

**Created by**: `C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\install-modified-extension.ps1`

### Restoring Original

If needed, restore with:
```powershell
Copy-Item -Path "C:\Users\<USERNAME>\.vscode\extensions\emeraldwalk.runonsave-0.2.7-original\*" -Destination "C:\Users\<USERNAME>\.vscode\extensions\emeraldwalk.runonsave-0.2.7" -Recurse -Force
```

---

## Quick Reference Command Summary

### Installation Commands (in order)

```powershell
# 1. Install base extension
code --install-extension emeraldwalk.RunOnSave

# 2. Apply modifications (if VS Code running)
C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\install-modified-extension.ps1 -Force

# 3. Install for all users
C:\code\UnicodeReplacementTool\install-runonsave-all-users.ps1

# 4. Fix permissions for specific user (replace <USERNAME>)
icacls "C:\Users\<USERNAME>\.vscode\extensions\emeraldwalk.runonsave-0.2.7" /grant <USERNAME>:F /T /Q

# 5. Verify installation (for User example)
C:\code\UnicodeReplacementTool\check-user-extension.ps1
```

### Configuration Commands

```powershell
# Configure current workspace
C:\code\UnicodeReplacementTool\setup-runonsave-workspace.ps1

# Configure different workspace
C:\code\UnicodeReplacementTool\setup-runonsave-workspace.ps1 -WorkspacePath "C:\path\to\workspace"
```

---

## Support Files & Documentation

| Document | Path | Purpose |
|----------|------|---------|
| User guide | `C:\code\UnicodeReplacementTool\RUNONSAVE-SETUP-FOR-USER.md` | End-user instructions |
| This guide | `C:\code\UnicodeReplacementTool\AI-ENGINEER-SETUP-GUIDE.md` | AI engineer handoff documentation |
| Modification details | `C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\README-MODIFICATIONS.md` | Technical details of extension modification |
| Extension readme | `C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\README.md` | Original extension documentation |

---

## System Requirements

- **OS**: Windows (tested on Windows 10/11)
- **VS Code**: Any recent version supporting extensions
- **Python**: 3.x (accessible via `python` command in PATH)
- **Permissions**: Administrator access for multi-user installation
- **PowerShell**: 5.1 or later

---

## Current User Configurations

### User: i

- **Extension path**: `C:\Users\i\.vscode\extensions\emeraldwalk.runonsave-0.2.7`
- **Settings**: Configured (see workspace settings at `C:\code\UnicodeReplacementTool\.vscode\settings.json`)
- **Status**: ✅ Working

### User: User

- **Extension path**: `C:\Users\User\.vscode\extensions\emeraldwalk.runonsave-0.2.7`
- **User settings**: `C:\Users\User\AppData\Roaming\Code\User\settings.json`
- **Permissions**: Fixed with `icacls`
- **Status**: ✅ Working

### User: IT

- **VS Code**: Not installed
- **Status**: Skipped

---

## Future Maintenance

### Adding New Users

1. Run: `C:\code\UnicodeReplacementTool\install-runonsave-all-users.ps1`
2. If user already has VS Code open, they need to reload window
3. Verify with test file (see Testing section)

### Updating Extension

If base extension updates:
1. Uninstall current: `code --uninstall-extension emeraldwalk.runonsave`
2. Install new version: `code --install-extension emeraldwalk.runonsave`
3. Re-apply modifications from `C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\`
4. Redistribute to all users

### Updating unicode_replacer.py

If the Python script is updated:
- No extension changes needed
- Settings already reference the script path
- All users will automatically use new version on next save

---

## Troubleshooting Decision Tree

```
Extension not running on save?
│
├─ Is extension installed?
│  │
│  ├─ NO → Run Step 1 (install base extension)
│  │
│  └─ YES → Continue
│
├─ Is extension enabled in VS Code?
│  │
│  ├─ NO → Enable in Extensions panel
│  │
│  └─ YES → Continue
│
├─ Are user settings configured?
│  │
│  ├─ NO → Check C:\Users\<USERNAME>\AppData\Roaming\Code\User\settings.json
│  │       Add emeraldwalk.runonsave configuration
│  │
│  └─ YES → Continue
│
├─ Can VS Code read extension files?
│  │
│  ├─ Check Output panel for errors
│  │
│  ├─ If "package.json not found" → Run icacls fix (Step 4)
│  │
│  └─ If other error → Check permissions, verify installation
│
├─ Is Python accessible?
│  │
│  └─ Test: Run `python --version` in terminal
│
├─ Is unicode_replacer.py path correct?
│  │
│  └─ Verify: C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py exists
│
└─ Reload VS Code
   └─ Ctrl+Shift+P → "Developer: Reload Window"
```

---

## End of Guide

**Last Verified**: 2025-11-03
**Verified By**: AI Engineer
**Status**: Production-ready for users 'i' and 'User'
