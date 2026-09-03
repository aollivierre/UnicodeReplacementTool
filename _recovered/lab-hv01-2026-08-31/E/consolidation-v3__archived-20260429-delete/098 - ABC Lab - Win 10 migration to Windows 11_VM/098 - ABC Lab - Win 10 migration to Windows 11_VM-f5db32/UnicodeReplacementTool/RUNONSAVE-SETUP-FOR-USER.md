# RunOnSave Extension Setup - For All Users (Including User)

## ✅ What's Been Done

The modified RunOnSave extension has been installed for **all users** including User.

- **Extension Location**: `C:\Users\User\.vscode\extensions\emeraldwalk.runonsave-0.2.7`
- **Status**: ✅ Installed and registered
- **Modification**: Fixed to work in single-file workspace mode

## 🎯 How to Use

### For This Workspace (C:\code\UnicodeReplacementTool)

This workspace is **already configured**. Just:

1. Open this folder in VS Code (as User or any user)
2. Edit any supported file (.ps1, .py, .js, .md, etc.)
3. Press **Ctrl+S** to save
4. **Unicode characters are automatically replaced!**

### For Other Workspaces

To enable automatic unicode replacement in any other workspace/folder:

1. Open PowerShell in that folder
2. Run:
   ```powershell
   C:\code\UnicodeReplacementTool\setup-runonsave-workspace.ps1
   ```

This will create/update `.vscode\settings.json` with the correct configuration.

## 📋 Supported File Types

The extension will automatically run on these file types when you save:

- **PowerShell**: `.ps1`, `.psm1`, `.psd1`
- **Python**: `.py`
- **JavaScript/TypeScript**: `.js`, `.ts`, `.jsx`, `.tsx`
- **Data/Config**: `.json`, `.md`, `.txt`, `.xml`, `.yaml`, `.yml`

## 🔧 What the Extension Does

When you save a file with **Ctrl+S**:

1. The RunOnSave extension detects the save
2. It runs: `python C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py "<your-file>" --no-backup`
3. Unicode characters are replaced with ASCII equivalents
4. File is updated in place (no backup created)

## 🛠️ Manual Configuration (Optional)

If you prefer to manually configure a workspace, create `.vscode\settings.json`:

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
        "match": "\\.(py|js|ts|jsx|tsx|json|md|txt|xml|yaml|yml)$",
        "cmd": "python \"C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py\" \"${file}\" --no-backup",
        "isAsync": false,
        "notInTerminal": true
      }
    ]
  },
  "files.encoding": "utf8",
  "files.autoGuessEncoding": false,
  "[powershell]": {
    "files.encoding": "utf8",
    "files.eol": "\r\n"
  }
}
```

## 🔍 Verifying the Extension

To verify the extension is installed for User:

```powershell
# Check extension files exist
Test-Path "C:\Users\User\.vscode\extensions\emeraldwalk.runonsave-0.2.7"

# Check extension registration
C:\code\UnicodeReplacementTool\check-user-extension.ps1
```

## ⚠️ Troubleshooting

### Extension Not Running

1. **Reload VS Code**: Press `Ctrl+Shift+P` → "Developer: Reload Window"
2. **Check Extension**: Press `Ctrl+Shift+X` → Search for "Run on Save" (should show as installed)
3. **Check Settings**: Open `.vscode\settings.json` and verify the `emeraldwalk.runonsave` section exists

### Permission Errors

If you see permission errors, run:

```powershell
icacls "C:\Users\User\.vscode\extensions\emeraldwalk.runonsave-0.2.7" /grant User:F /T /Q
```

### Extension Needs Reinstall

Run the all-users installer:

```powershell
C:\code\UnicodeReplacementTool\install-runonsave-all-users.ps1
```

## 📚 Related Files

- `install-runonsave-all-users.ps1` - Installs extension for all users
- `setup-runonsave-workspace.ps1` - Configures any workspace
- `check-user-extension.ps1` - Verifies User's installation
- `vscode.ext/Extensions/RunOnSave-Modified/` - Source of modified extension

## ✨ Benefits of This Setup

- **Automatic**: No need to manually run scripts
- **Fast**: Runs instantly on save (Ctrl+S)
- **Seamless**: Integrated into your normal workflow
- **Multi-user**: Works for all users on the system
- **Single-file mode**: Works even when opening individual files (not just workspaces)
