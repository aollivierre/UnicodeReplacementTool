# VS Code RunOnSave - File Type Configuration

## Current Configuration (Conservative Approach)

The VS Code RunOnSave extension is configured to **only auto-clean PowerShell and Python files** on save (Ctrl+S).

### Files That ARE Auto-Cleaned

✅ **PowerShell Scripts**:
- `.ps1` - PowerShell scripts
- `.psm1` - PowerShell modules
- `.psd1` - PowerShell data files

✅ **Python Code**:
- `.py` - Python scripts and modules

### Files That Are NOT Auto-Cleaned

❌ **Documentation**:
- `.md` - Markdown files (may contain intentional Unicode examples)
- `.txt` - Text files (could be notes, user data, etc.)

❌ **Data/Config Files**:
- `.json` - JSON configuration (may have intentional Unicode in strings)
- `.xml` - XML data (could break with unexpected replacements)
- `.yaml`, `.yml` - YAML config (same concerns)

❌ **Web Code**:
- `.js`, `.ts`, `.jsx`, `.tsx` - JavaScript/TypeScript (not enabled by default)

## Why This Conservative Approach?

### Problem with Auto-Cleaning Everything

If we auto-clean **all file types** on every save, we risk:

1. **Breaking Documentation**
   ```markdown
   # Example: Unicode characters
   The arrow → symbol gets replaced with ->
   ```
   If saved, the example would change, breaking the documentation!

2. **Corrupting Data Files**
   ```json
   {
     "userName": "José",
     "location": "São Paulo"
   }
   ```
   These names would become `Jose` and `Sao Paulo`, corrupting user data!

3. **Removing Intentional Unicode**
   ```yaml
   welcome_message: "Welcome! 🎉"
   ```
   The emoji would become `[U+1F389]` or similar, breaking the intended message.

### Safe Approach for Code Files

PowerShell and Python code files:
- ✅ Should rarely have intentional Unicode
- ✅ Unicode is usually accidental (copy-paste from docs, smart quotes from editors)
- ✅ Replacing Unicode improves code compatibility
- ✅ Safe to auto-clean on every save

## Current Settings Location

### User Settings (Global)
**User: User**
```
C:\Users\User\AppData\Roaming\Code\User\settings.json
```

**User: i**
```
C:\Users\i\AppData\Roaming\Code\User\settings.json
```

### Workspace Settings (Project-Specific)
```
C:\code\UnicodeReplacementTool\.vscode\settings.json
```

### Reference Settings
```
C:\code\UnicodeReplacementTool\vscode.ext\.vscode\settings.json
```

## Current Configuration

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

## Adding More File Types (If Needed)

If you need to auto-clean additional file types, consider the risks first:

### Low Risk (Safe to Add)
- `.js`, `.ts` - JavaScript/TypeScript code (if you work with these)
- `.jsx`, `.tsx` - React components (if you work with React)

### Medium Risk (Use Caution)
- `.json` - Only if you control all JSON content
- `.xml` - Only if it's code-generated, not user data
- `.yaml`, `.yml` - Only if it's infrastructure config, not user content

### High Risk (Don't Auto-Clean)
- `.md` - Markdown documentation
- `.txt` - Generic text files
- Any file that might contain user data or examples

## How to Add a New File Type

### Step 1: Decide if It's Safe

Ask yourself:
- Is this a code file or data file?
- Could it contain intentional Unicode?
- Would replacing Unicode break anything?

### Step 2: Edit Settings

Add to the `commands` array:

```json
{
  "match": "\\.(newtype)$",
  "cmd": "python \"C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py\" \"${file}\" --no-backup",
  "isAsync": false,
  "notInTerminal": true
}
```

### Step 3: Test Carefully

1. Create a test file with Unicode
2. Save it (Ctrl+S)
3. Verify Unicode was replaced correctly
4. Check nothing broke

## Manual Cleaning for Other File Types

For files NOT auto-cleaned, use:

### Option 1: Claude Code Skill (Automatic)
```
User: "Clean Unicode from this markdown file"
Claude: [Invokes unicode-remover skill]
```

### Option 2: Direct Script (Manual)
```powershell
python "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py" "path\to\file.md" --no-backup
```

### Option 3: Preview First (Safe)
```powershell
python "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py" "path\to\file.md" --preview
```

## File Type Reference

| Extension | Auto-Clean? | Reason |
|-----------|-------------|--------|
| `.ps1`, `.psm1`, `.psd1` | ✅ Yes | PowerShell code files |
| `.py` | ✅ Yes | Python code files |
| `.js`, `.ts`, `.jsx`, `.tsx` | ❌ No | Not enabled (but could be) |
| `.json` | ❌ No | May contain intentional Unicode data |
| `.xml` | ❌ No | May contain intentional Unicode data |
| `.yaml`, `.yml` | ❌ No | May contain intentional Unicode data |
| `.md` | ❌ No | Documentation with intentional examples |
| `.txt` | ❌ No | Generic files, unpredictable content |

## Best Practices

### For Automatic Cleaning (RunOnSave)
1. ✅ Only enable for **code files** you actively work with
2. ✅ Keep it **conservative** - better to under-clean than over-clean
3. ✅ Test with sample files before enabling new types
4. ❌ Don't enable for documentation or data files

### For Manual Cleaning (Skill or Script)
1. ✅ Use for **one-off cleaning** of documentation
2. ✅ Use **preview mode** first for unfamiliar files
3. ✅ Keep **backups** for important files
4. ✅ Review changes after cleaning

## Common Scenarios

### Scenario 1: "I copied code from docs and it has smart quotes"
**Solution**: Just save the file (Ctrl+S) - auto-cleaning handles it! ✅

### Scenario 2: "My markdown doc has Unicode examples I need to preserve"
**Solution**: Don't enable auto-clean for .md files. That's why they're excluded! ✅

### Scenario 3: "I need to clean one JSON file, but not all JSON files"
**Solution**: Use manual cleaning with the skill or direct script. ❌ Don't add .json to auto-clean!

### Scenario 4: "I work with TypeScript and need it auto-cleaned"
**Solution**: Add `.ts` and `.tsx` to the settings - JavaScript/TypeScript code is safe to auto-clean. ✅

## Summary

**Current Setup**:
- ✅ Auto-cleans: PowerShell (.ps1, .psm1, .psd1) and Python (.py)
- ❌ Does NOT auto-clean: Documentation, data files, web code

**Why**:
- Conservative approach prevents accidental data corruption
- Code files are safe to auto-clean
- Documentation/data files may have intentional Unicode

**Alternatives**:
- Use Claude Code skill for other file types
- Use manual script execution
- Use preview mode for safety

---

**Updated**: 2025-11-03
**Reason**: User feedback - too many file types auto-cleaned
**Previous Config**: Included .js, .ts, .jsx, .tsx, .json, .md, .txt, .xml, .yaml, .yml
**New Config**: Only .ps1, .psm1, .psd1, .py (code files only)
