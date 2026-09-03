---
name: unicode-remover
description: Remove Unicode characters from source code files and replace with ASCII equivalents. Use after generating code files (.ps1, .py, .js, .ts), when encoding errors appear, before git commits, when batch-processing directories, or when user asks to clean/fix Unicode. Automatically replaces smart quotes, dashes, arrows, emojis, math symbols with ASCII. Takes 50-100ms per file. DO NOT use for i18n files, binary files, or intentional Unicode content. Script path C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py --no-backup
---

# Unicode Remover Skill

## Purpose
This skill provides deterministic, automated removal of Unicode characters from source code files, replacing them with ASCII equivalents. It is designed for AI agents and Claude Code to ensure code consistency and prevent encoding issues.

## When to Use This Skill

Use this skill when:
- You detect Unicode characters in code files (PowerShell, Python, JavaScript, etc.)
- You need to sanitize code before commits
- You're generating code and want to ensure clean ASCII output
- You need to batch-process files for Unicode removal
- You see warnings about encoding or special characters

**DO NOT** invoke this for:
- Files that legitimately need Unicode (documentation in non-English, user-facing text)
- Binary files or images
- Already-processed files (check if replacements were made recently)

## How It Works

This skill uses a battle-tested Python script with hardcoded Unicode-to-ASCII mappings:

**Script Location**: `C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py`

**Mappings Include**:
- Smart quotes → Standard quotes (`"` → `"`, `'` → `'`)
- Dashes → Hyphens/double-dash (`–` → `-`, `—` → `--`)
- Arrows → ASCII arrows (`→` → `->`, `←` → `<-`)
- Emojis → ASCII tags (`🚀` → `[ROCKET]`, `✅` → `[CHECK]`)
- Math symbols → ASCII equivalents (`∑` → `SUM`, `∞` → `infinity`)
- Box drawing → ASCII (`┌` → `+`, `─` → `-`)
- Accented characters → Plain ASCII (`é` → `e`, `ñ` → `n`)

**Fallback**: Unmapped Unicode becomes `[U+XXXX]` for visibility

## Usage Instructions

### For Single Files

When you detect Unicode in a specific file:

```bash
python "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py" "<FILEPATH>" --no-backup
```

**Example**:
```bash
python "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py" "C:\project\script.ps1" --no-backup
```

### For Multiple Files

Process all files in a directory:

```bash
# PowerShell files only
Get-ChildItem -Path "C:\project" -Filter *.ps1 -Recurse | ForEach-Object {
    python "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py" $_.FullName --no-backup
}

# All supported file types
Get-ChildItem -Path "C:\project" -Include *.ps1,*.py,*.js,*.ts -Recurse | ForEach-Object {
    python "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py" $_.FullName --no-backup
}
```

### Detection Before Processing

To check if a file has Unicode without modifying it:

```bash
python "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py" "<FILEPATH>" --preview
```

## Command-Line Options

| Flag | Purpose |
|------|---------|
| `--no-backup` | Don't create `.bak` backup files (recommended for AI agents) |
| `--preview` | Show what would be replaced without modifying the file |
| `--backup` | Create `.bak` backup before modification (default if not specified) |

## Expected Output

**Successful replacement**:
```
Processed C:\project\script.ps1: 15 replacements made
```

**No Unicode found**:
```
No Unicode characters found in C:\project\script.ps1
```

**Preview mode**:
```
Would replace in C:\project\script.ps1:
  Line 10: "Smart quote" → "Smart quote"
  Line 25: Write-Host "Arrow →" → Write-Host "Arrow ->"
```

## Integration with Claude Code Workflows

### Proactive Use

Claude Code agents should **automatically invoke this skill** when:

1. **After generating code files** - Always clean newly created files
2. **After editing existing files** - Check for Unicode introduction
3. **Before git commits** - Ensure clean commits
4. **When reading error messages** - If encoding errors appear

### Example Workflow

```
1. User: "Create a PowerShell script to manage services"
2. Claude Code: [Writes script.ps1]
3. Claude Code: [Automatically invokes unicode-remover skill]
4. Claude Code: "Script created and cleaned - 3 Unicode characters replaced"
```

## Error Handling

**If Python not found**:
- Verify Python is installed and in PATH
- Try: `python --version` or `python3 --version`

**If script not found**:
- Verify path: `C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py`
- Check the nested folder structure (UnicodeReplacementTool\UnicodeReplacementTool\)

**If permission errors**:
- Ensure file is not read-only
- Check user has write access to target file

## Performance Characteristics

- **Processing time**: 50-100ms per file (typical)
- **Memory usage**: Minimal (processes files in-memory)
- **Safety**: Atomic replacement (writes to temp, then renames)
- **Deterministic**: Same input always produces same output
- **Idempotent**: Running twice on same file is safe (no additional changes)

## File Type Support

**Supported Extensions** (tested and verified):
- PowerShell: `.ps1`, `.psm1`, `.psd1`
- Python: `.py`
- JavaScript/TypeScript: `.js`, `.ts`, `.jsx`, `.tsx`
- Data formats: `.json`, `.xml`, `.yaml`, `.yml`
- Documentation: `.md`, `.txt`

**Not recommended for**:
- Binary files (`.exe`, `.dll`, `.bin`)
- Compiled code (`.pyc`, `.class`)
- Media files (`.jpg`, `.png`, `.mp4`)
- Intentionally Unicode content (internationalization files)

## Deterministic Behavior

This skill is designed for **maximum determinism**:

✅ **Always produces same output** for same input
✅ **No randomness** - fixed mapping dictionary
✅ **No AI decisions** - pure rule-based replacement
✅ **No external dependencies** - self-contained Python script
✅ **Predictable failures** - clear error messages
✅ **Idempotent** - safe to run multiple times

## Best Practices for AI Agents

1. **Always use `--no-backup` flag** when invoked by AI
   - Prevents cluttering workspace with `.bak` files
   - Faster execution

2. **Run silently** unless errors occur
   - Don't report "0 replacements" as success
   - Only mention when Unicode was actually found and replaced

3. **Batch process efficiently**
   - If processing multiple files, use PowerShell loop
   - Report aggregate stats: "Processed 15 files, 47 replacements total"

4. **Don't ask user permission** for this deterministic operation
   - This is a code quality tool, not a creative decision
   - Auto-clean is expected behavior

5. **Log but don't interrupt** workflow
   - Process files in background
   - Only surface major issues

## Integration Example for AI Agents

```python
# Pseudocode for AI agent integration

def after_file_write(filepath):
    """Hook called after creating/modifying any code file"""

    # Auto-clean if code file
    if filepath.endswith(('.ps1', '.py', '.js', '.ts')):
        result = run_command(
            f'python "C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py" "{filepath}" --no-backup'
        )

        if "replacements made" in result:
            log(f"Auto-cleaned {filepath}: {result}")
        # Don't report if no Unicode found - that's expected
```

## Related Documentation

- **AI Engineer Setup Guide**: `C:\code\UnicodeReplacementTool\AI-ENGINEER-SETUP-GUIDE.md`
- **User Guide**: `C:\code\UnicodeReplacementTool\RUNONSAVE-SETUP-FOR-USER.md`
- **Script Source**: `C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py`
- **VS Code Extension Setup**: `C:\code\UnicodeReplacementTool\vscode.ext\memory.md`

## Version Information

- **Skill Version**: 1.0.0
- **Created**: 2025-11-03
- **Python Script**: Stable version with 276-line mapping dictionary
- **Compatibility**: Python 3.x, Windows/Linux/macOS

## Maintenance

**When to update this skill**:
- New Unicode characters need mapping (edit `unicode_replacer.py`)
- New file types need support (add to extension list)
- Performance improvements to Python script
- New command-line flags added

**Who maintains this**:
- Primary tool: `C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py`
- Skill wrapper: This SKILL.md file
- Contact: See AI-ENGINEER-SETUP-GUIDE.md for handoff procedures
