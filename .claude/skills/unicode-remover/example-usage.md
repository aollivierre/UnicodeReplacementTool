# Unicode Remover Skill - Usage Examples

## For Claude Code AI Agents

### Example 1: Auto-Clean After Code Generation

**User request**: "Create a PowerShell script to manage Windows services"

**AI Agent workflow**:
```
1. Generate script content
2. Write to file: C:\project\service-manager.ps1
3. AUTO-INVOKE unicode-remover skill
4. Report: "Script created. Auto-cleaned: 3 Unicode characters replaced."
```

**Command executed by skill**:
```bash
python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" "C:\project\service-manager.ps1" --no-backup
```

---

### Example 2: Batch Processing Directory

**User request**: "Clean all PowerShell files in this project"

**AI Agent workflow**:
```powershell
# Get all PowerShell files
$files = Get-ChildItem -Path "C:\project" -Filter *.ps1 -Recurse

# Process each file
foreach ($file in $files) {
    python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" $file.FullName --no-backup
}

# Report aggregate results
# "Processed 15 files: 47 Unicode characters replaced total"
```

---

### Example 3: Pre-Commit Check

**User request**: "Prepare this code for commit"

**AI Agent workflow**:
```
1. Detect all modified files in git
2. Filter for code files (.ps1, .py, .js, .ts)
3. Run unicode-remover on each
4. Report: "Pre-commit check: 2 files cleaned, ready for commit"
```

**Commands**:
```bash
# Get staged files
git diff --name-only --cached --diff-filter=ACMR | grep -E '\.(ps1|py|js|ts)$'

# Process each
for file in $(git diff --name-only --cached); do
    python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" "$file" --no-backup
done
```

---

### Example 4: Selective Processing with Preview

**User request**: "Check if my script has any Unicode issues"

**AI Agent workflow**:
```bash
# Preview mode (don't modify file)
python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" "C:\project\script.ps1" --preview

# If Unicode found, ask user if they want to clean it
# If yes, run without --preview flag
```

---

## Direct Command-Line Usage

### Single File Processing

```bash
# Clean a specific file
python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" "C:\project\script.ps1" --no-backup

# Preview changes first
python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" "C:\project\script.ps1" --preview

# Create backup before cleaning
python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" "C:\project\script.ps1" --backup
```

### Batch Processing by Type

```powershell
# All PowerShell files
Get-ChildItem -Filter *.ps1 -Recurse | ForEach-Object {
    python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" $_.FullName --no-backup
}

# All Python files
Get-ChildItem -Filter *.py -Recurse | ForEach-Object {
    python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" $_.FullName --no-backup
}

# Multiple file types
Get-ChildItem -Include *.ps1,*.py,*.js,*.ts -Recurse | ForEach-Object {
    python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" $_.FullName --no-backup
}
```

### Specific Directory Only (Non-Recursive)

```powershell
Get-ChildItem -Path "C:\project\scripts" -Filter *.ps1 | ForEach-Object {
    python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" $_.FullName --no-backup
}
```

---

## Integration Patterns

### Pattern 1: Post-Generation Hook

```python
def after_code_generation(filepath):
    """Automatically clean Unicode after generating code files"""

    if filepath.endswith(('.ps1', '.py', '.js', '.ts')):
        result = subprocess.run([
            'python',
            'C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py',
            filepath,
            '--no-backup'
        ], capture_output=True, text=True)

        if 'replacements made' in result.stdout:
            return f"Auto-cleaned: {result.stdout.strip()}"
    return None
```

### Pattern 2: Conditional Cleaning

```python
def clean_if_needed(filepath):
    """Only clean if Unicode is detected"""

    # First, preview to check
    result = subprocess.run([
        'python',
        'C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py',
        filepath,
        '--preview'
    ], capture_output=True, text=True)

    if 'Would replace' in result.stdout:
        # Unicode found, now clean for real
        subprocess.run([
            'python',
            'C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py',
            filepath,
            '--no-backup'
        ])
        return True
    return False
```

### Pattern 3: Error-Safe Batch Processing

```python
def batch_clean_safe(filepaths):
    """Process multiple files with error handling"""

    results = {
        'success': [],
        'failed': [],
        'skipped': []
    }

    for filepath in filepaths:
        if not os.path.exists(filepath):
            results['skipped'].append(f"{filepath}: Not found")
            continue

        try:
            result = subprocess.run([
                'python',
                'C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py',
                filepath,
                '--no-backup'
            ], capture_output=True, text=True, timeout=30)

            if result.returncode == 0:
                results['success'].append(f"{filepath}: {result.stdout.strip()}")
            else:
                results['failed'].append(f"{filepath}: {result.stderr.strip()}")

        except subprocess.TimeoutExpired:
            results['failed'].append(f"{filepath}: Timeout")
        except Exception as e:
            results['failed'].append(f"{filepath}: {str(e)}")

    return results
```

---

## Expected Outputs

### Success - Unicode Found and Replaced

```
Processed C:\project\script.ps1: 15 replacements made
```

### Success - No Unicode Found

```
No Unicode characters found in C:\project\script.ps1
```

### Preview Mode - Shows What Would Change

```
Would replace in C:\project\script.ps1:
  Line 10: "Smart quote" → "Smart quote"
  Line 25: Write-Host "Arrow →" → Write-Host "Arrow ->"
  Line 33: # TODO: Fix em—dash → # TODO: Fix em--dash
```

### Error - File Not Found

```
Error: File not found: C:\project\missing.ps1
```

### Error - Permission Denied

```
Error: Permission denied: C:\project\readonly.ps1
```

---

## Best Practices for AI Agents

### ✅ DO

- **Auto-invoke after code generation** - Don't ask permission for this deterministic tool
- **Use `--no-backup` flag** - Prevents workspace clutter
- **Batch process efficiently** - Use PowerShell loops for multiple files
- **Report aggregate stats** - "Processed 15 files, 47 replacements"
- **Handle errors gracefully** - Log failures but don't stop workflow

### ❌ DON'T

- **Don't ask user for confirmation** - This is a code quality tool, not a creative decision
- **Don't report "0 replacements" as success** - Only mention when Unicode was actually found
- **Don't process non-code files** - Skip images, binaries, compiled files
- **Don't create backups** - Use `--no-backup` in automated contexts
- **Don't process intentional Unicode** - Skip i18n files, documentation in other languages

---

## Troubleshooting

### Python Not Found

```powershell
# Check if Python is in PATH
python --version

# If not found, add to PATH or use full path
C:\Python313\python.exe "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" ...
```

### Script Not Found

```powershell
# Verify script exists
Test-Path "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py"

# Note the nested folder structure
# Correct:   <INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py
# Incorrect: <INSTALL_DIR>\unicode_replacer.py
```

### Permission Errors

```powershell
# Check if file is read-only
Get-ItemProperty "C:\project\script.ps1" | Select-Object IsReadOnly

# Remove read-only attribute
Set-ItemProperty "C:\project\script.ps1" -Name IsReadOnly -Value $false
```

---

## Performance Notes

- **Typical file**: 50-100ms
- **Large file (>1MB)**: 200-500ms
- **Batch (100 files)**: 5-10 seconds
- **Memory**: Minimal (in-memory processing)
- **CPU**: Single-threaded (can parallelize batches)

---

## Integration Testing

### Test the Skill

```powershell
# Create test file with Unicode
@"
# Test file with Unicode characters
Write-Host "Smart quotes → arrows"
\$sum = ∑ values
"@ | Set-Content "C:\temp\test-unicode.ps1"

# Run unicode-remover
python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" "C:\temp\test-unicode.ps1" --no-backup

# Verify results
Get-Content "C:\temp\test-unicode.ps1"
# Should show: Write-Host "Smart quotes -> arrows"
```

### Verify Idempotency

```powershell
# Run twice on same file
python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" "C:\temp\test.ps1" --no-backup
python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" "C:\temp\test.ps1" --no-backup

# Second run should report: "No Unicode characters found"
```

---

## Summary

The unicode-remover skill is a **deterministic, automated tool** designed for AI agents to ensure code quality without requiring human decision-making. It's fast, reliable, and safe to invoke proactively on all code files.

**Key principle**: This is not a creative tool - it's a code quality enforcer. AI agents should use it automatically and confidently.
