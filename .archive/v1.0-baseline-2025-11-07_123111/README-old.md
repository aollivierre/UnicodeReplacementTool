# Unicode Replacement Tool

## 🚨 Critical Tool for PowerShell 5.1 Compatibility

This tool reliably replaces Unicode characters in PowerShell scripts with ASCII equivalents. 

**IMPORTANT**: The original PowerShell-based version had a catastrophic bug that replaced Unicode with MORE Unicode (e.g., ✓ → [U+2705]). This Python-based version fixes that issue completely.

## Why This Tool Exists

PowerShell 5.1 has poor Unicode support and can break when encountering Unicode characters in:
- Script files (.ps1, .psm1, .psd1)
- Configuration files
- Log outputs
- Console displays

## Features

- ✅ **100% ASCII Output**: Guaranteed and byte-verified
- ✅ **Python-based**: Reliable Unicode handling (no JSON parsing bugs)
- ✅ **PowerShell Wrapper**: Easy to use from PS
- ✅ **Automatic Backups**: Timestamped backups before modification
- ✅ **Preview Mode**: See changes before applying
- ✅ **Comprehensive Mappings**: 100+ Unicode to ASCII replacements
- ✅ **Batch Processing**: Handle entire directories

## Quick Start

### For AI Agents

See [AI_INSTRUCTIONS.md](AI_INSTRUCTIONS.md) for quick reference.

### Installation

1. **Install Python 3.x** (required):
   ```powershell
   # Download from https://www.python.org/downloads/
   # Or check if already installed:
   python --version
   ```

2. **Clone this repository**:
   ```powershell
   git clone https://github.com/aollivierre/UnicodeReplacementTool.git
   cd UnicodeReplacementTool
   ```

### Usage

```powershell
# Preview Unicode characters in a directory
.\Replace-Unicode.ps1 -Path "C:\YourScripts" -PreviewOnly

# Replace Unicode characters (creates backups)
.\Replace-Unicode.ps1 -Path "C:\YourScripts"

# Process a single file
.\Replace-Unicode.ps1 -Path "script.ps1"

# Skip backups (not recommended)
.\Replace-Unicode.ps1 -Path "C:\YourScripts" -NoBackup
```

### Direct Python Usage

```bash
# Preview mode
python unicode_replacer.py C:\Scripts --preview

# Process files
python unicode_replacer.py C:\Scripts

# Custom file pattern
python unicode_replacer.py C:\Scripts --pattern "*.txt"
```

## Common Replacements

| Unicode | ASCII | Description |
|---------|-------|-------------|
| ✓ | [OK] | Checkmark |
| ✗ | [FAIL] | Cross mark |
| ✅ | [DONE] | Green checkmark |
| ❌ | [ERROR] | Red X |
| ⚠ | [WARNING] | Warning sign |
| → | -> | Arrow |
| 🚀 | [DEPLOY] | Rocket |
| 💡 | [IDEA] | Light bulb |
| 🤖 | [BOT] | Robot |
| π | pi | Pi symbol |
| ∑ | SUM | Summation |

See [unicode_replacer.py](unicode_replacer.py) for the complete mapping table (100+ mappings).

## Architecture

### Current (Working) Version
- `Replace-Unicode.ps1` - PowerShell wrapper for easy usage
- `unicode_replacer.py` - Python implementation with reliable Unicode handling
- `AI_INSTRUCTIONS.md` - Quick reference for AI agents
- `run-tests.ps1` - Test suite

### Legacy (Broken) Version
- `Scripts/` - Original PowerShell implementation (DO NOT USE - has Unicode bug)
- `Config/UnicodeReplacements.json` - JSON config that caused the Unicode bug

## Why Python?

The original PowerShell implementation had a critical bug:
- PowerShell's `ConvertFrom-Json` converts `\u2713` to actual `✓`
- This caused lookups to fail and return `[U+2713]` (still contains Unicode!)
- Python handles Unicode correctly without these parsing issues

## Safety Features

- **Automatic Backups**: Creates `.backup_YYYYMMDD_HHMMSS` files
- **Preview Mode**: Test without modifying files
- **ASCII Verification**: Confirms output is 100% ASCII
- **Error Reporting**: Clear messages for any issues

## Testing

```powershell
# Run test suite
.\run-tests.ps1

# Verify a file is ASCII-only
.\TestEnvironment\verify-ascii.ps1 -FilePath "yourfile.ps1"

# Run comprehensive tests
powershell -File TestEnvironment\run-comprehensive-test.ps1
```

## Real-World Usage

This tool has been used to successfully clean:
- 24 files in production codebase
- 65 Unicode characters replaced
- 100% ASCII compliance verified

## ⚠️ Important Warning

Always test on non-production files first. While this tool includes safety features and has been thoroughly tested, Unicode replacement can affect script behavior if the Unicode characters were intentional.

## License

MIT License - See LICENSE file for details

## Contributing

1. Fork the repository
2. Create a feature branch
3. Test thoroughly with the test suite
4. Submit a pull request

## Support

For issues or questions, please open an issue on GitHub.