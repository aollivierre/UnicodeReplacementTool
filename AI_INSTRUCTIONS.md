# AI Agent Instructions - Unicode Replacement Tool

## CRITICAL: For AI Agents Working with PowerShell Code

### Quick Start - Replace Unicode NOW

```powershell
# SCAN for Unicode (preview only - safe)
C:\code\UnicodeReplacementTool\Replace-Unicode.ps1 -Path "C:\your\path\here" -PreviewOnly

# REPLACE Unicode (creates backups automatically)
C:\code\UnicodeReplacementTool\Replace-Unicode.ps1 -Path "C:\your\path\here"
```

### Key Files

- **Main Tool**: `C:\code\UnicodeReplacementTool\Replace-Unicode.ps1`
- **Python Core**: `C:\code\UnicodeReplacementTool\unicode_replacer.py`

### When to Use This Tool

**ALWAYS** scan for Unicode when:
- Working with PowerShell 5.1 scripts
- Before deploying to production
- After receiving code from external sources
- When seeing encoding errors

### Common Unicode Issues in PS 5.1

PowerShell 5.1 breaks with Unicode in:
- Script files (.ps1, .psm1, .psd1)
- Configuration files
- Log outputs
- Console displays

### Example Workflow for AI Agents

1. **Before making changes**:
   ```powershell
   # Scan the directory
   C:\code\UnicodeReplacementTool\Replace-Unicode.ps1 -Path "C:\TargetDirectory" -PreviewOnly
   ```

2. **If Unicode found**:
   ```powershell
   # Fix it (auto-creates backups)
   C:\code\UnicodeReplacementTool\Replace-Unicode.ps1 -Path "C:\TargetDirectory"
   ```

3. **Verify success**:
   - Check no errors reported
   - Confirm backups created
   - Test the scripts still work

### What Gets Replaced

| Unicode | ASCII |
|---------|-------|
| ✓ | [OK] |
| ✗ | [FAIL] |
| → | -> |
| 🚀 | [DEPLOY] |
| ⚠ | [WARNING] |

### WARNINGS

- **NEVER** skip the preview step on production code
- **ALWAYS** verify backups exist before proceeding
- **TEST** scripts after replacement

### Python Requirement

This tool requires Python 3.x. If not installed:
```powershell
# Check if Python exists
python --version

# If not found, install from https://www.python.org/downloads/
```

### For Debugging

If the tool fails:
1. Check Python is installed
2. Verify file permissions
3. Run with full paths
4. Check error messages

Remember: This tool exists because PowerShell 5.1 has poor Unicode support. Always use it when working with PS 5.1 code!