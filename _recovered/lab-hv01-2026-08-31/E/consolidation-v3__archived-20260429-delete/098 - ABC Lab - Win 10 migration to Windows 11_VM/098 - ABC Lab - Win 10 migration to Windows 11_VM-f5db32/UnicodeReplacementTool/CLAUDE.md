# Unicode Replacement Tool - Project Context

## Project Purpose

This project provides tools to automatically detect and replace Unicode characters in source code files with ASCII equivalents. It prevents encoding issues, ensures code compatibility, and maintains clean ASCII-only codebases.

## Target Use Cases

- PowerShell scripts with smart quotes, em-dashes, or special characters
- Python code with Unicode symbols that cause encoding errors
- JavaScript/TypeScript files with accidental Unicode from copy-paste
- Any code that needs to be ASCII-clean for maximum compatibility

## Available Skills

### unicode-remover

**Location**: `.claude/skills/unicode-remover/`

**Purpose**: Deterministic, automated removal of Unicode characters from code files.

**When to invoke**:
- ✅ After generating any code file (.ps1, .py, .js, .ts, etc.)
- ✅ When user asks to "clean" or "fix encoding" issues
- ✅ Before git commits (pre-commit cleanup)
- ✅ When batch processing files in a directory
- ✅ Proactively after any file creation or modification

**When NOT to invoke**:
- ❌ Binary files (.exe, .dll, images, media)
- ❌ Intentionally Unicode content (i18n files, non-English documentation)
- ❌ Already-processed files (check timestamps)

**Invocation examples**:
- User: "Create a PowerShell script to manage services"
  → Generate script, then AUTO-INVOKE unicode-remover
- User: "Clean all Python files in this directory"
  → INVOKE unicode-remover with batch processing
- User: "Check if this file has encoding issues"
  → INVOKE unicode-remover in preview mode

**Key characteristics**:
- **Deterministic**: Same input always produces same output (no AI decisions)
- **Fast**: 50-100ms per file
- **Idempotent**: Safe to run multiple times
- **No user confirmation needed**: This is a code quality tool, not creative work
- **Auto-clean by default**: AI agents should use this proactively

**Script path**: `C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py`

**Command template**:
```bash
python "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py" "<filepath>" --no-backup
```

**For detailed usage**: See `.claude/skills/unicode-remover/SKILL.md`

## Project Structure

```
C:\code\UnicodeReplacementTool\
├── CLAUDE.md                           # This file - project context for Claude
├── AI-ENGINEER-SETUP-GUIDE.md          # Complete setup guide for AI engineers
├── RUNONSAVE-SETUP-FOR-USER.md       # User guide for VS Code extension
├── .claude/
│   └── skills/
│       └── unicode-remover/            # Claude Code skill
│           ├── SKILL.md                # Complete skill documentation
│           ├── README.md               # Quick-start guide
│           ├── example-usage.md        # Usage examples
│           ├── test-skill.ps1          # Verification script
│           └── install-skill.ps1       # Installation script
├── UnicodeReplacementTool/
│   └── unicode_replacer.py             # Main Python script (hardcoded mappings)
├── vscode.ext/
│   ├── memory.md                       # Historical development notes
│   ├── Extensions/
│   │   └── RunOnSave-Modified/         # Modified VS Code extension
│   └── .vscode/
│       └── settings.json               # VS Code RunOnSave configuration
├── install-runonsave-all-users.ps1     # Multi-user extension installer
├── setup-runonsave-workspace.ps1       # Workspace configuration script
└── check-user-extension.ps1          # Extension verification script
```

## Key Documentation

| Document | Purpose | Audience |
|----------|---------|----------|
| `CLAUDE.md` | Project context for Claude Code | AI agents |
| `.claude/skills/unicode-remover/SKILL.md` | Complete skill documentation | AI agents |
| `AI-ENGINEER-SETUP-GUIDE.md` | Installation & troubleshooting | AI engineers |
| `RUNONSAVE-SETUP-FOR-USER.md` | VS Code extension setup | Human users |
| `vscode.ext/memory.md` | Development history | Reference only |

## Tool Capabilities

### unicode_replacer.py

**Type**: Hardcoded mapping dictionary (276 lines)

**Mappings**:
- Smart quotes → Standard quotes (`"` → `"`, `'` → `'`)
- Dashes → Hyphens (`–` → `-`, `—` → `--`)
- Arrows → ASCII (`→` → `->`, `←` → `<-`)
- Emojis → Tags (`🚀` → `[ROCKET]`, `✅` → `[CHECK]`)
- Math → ASCII (`∑` → `SUM`, `∞` → `infinity`)
- Box drawing → ASCII (`┌` → `+`, `─` → `-`)
- Accented chars → Plain (`é` → `e`, `ñ` → `n`)

**Fallback**: Unmapped Unicode → `[U+XXXX]` format

**Performance**: 50-100ms per file, in-memory processing

**Supported files**: .ps1, .psm1, .psd1, .py, .js, .ts, .jsx, .tsx, .json, .md, .txt, .xml, .yaml, .yml

## VS Code Integration (For Human Users)

**Extension**: Modified RunOnSave (emeraldwalk.runonsave v0.2.7)

**Modification**: Fixed to work in single-file mode (not just workspaces)

**Trigger**: Automatic on Ctrl+S (file save)

**Installation**: See `AI-ENGINEER-SETUP-GUIDE.md` for multi-user setup

**Note**: This is for human engineers. AI agents should use the Python script directly via the unicode-remover skill.

## Claude Code AI Agent Guidelines

### Proactive Skill Usage

AI agents working in this project or any project should:

1. **Auto-invoke unicode-remover after code generation**
   - Don't ask permission - it's a deterministic quality tool
   - Use `--no-backup` flag to avoid clutter
   - Report only when Unicode was actually found and replaced

2. **Batch process efficiently**
   - Use PowerShell loops for multiple files
   - Report aggregate stats: "Processed 15 files, 47 replacements"

3. **Handle errors gracefully**
   - Log failures but don't stop workflow
   - Common errors: file not found, permission denied, Python not in PATH

4. **Don't over-report**
   - Don't mention "0 replacements found" - that's expected
   - Only surface when Unicode is actually detected and cleaned

### Example Workflow

```
User: "Create a PowerShell script to backup databases"

AI Agent:
1. Generate backup-databases.ps1
2. Write file to disk
3. AUTO-INVOKE: unicode-remover skill
4. If replacements made: "Script created. Auto-cleaned: 3 Unicode chars replaced."
5. If no Unicode: "Script created." (don't mention unicode check)
```

### Integration Pattern

```python
# After writing any code file
def after_write_code_file(filepath):
    if filepath.endswith(('.ps1', '.py', '.js', '.ts')):
        result = invoke_skill('unicode-remover', filepath, '--no-backup')
        if 'replacements made' in result:
            log(f"Auto-cleaned: {result}")
```

## System Context

**OS**: Windows (also works on Linux/macOS)
**Python**: 3.x required
**Paths**: Uses absolute paths (C:\code\UnicodeReplacementTool\...)

**Current users configured**:
- User `i`: Extension installed, settings configured
- User `User`: Extension installed, settings configured
- User `IT`: VS Code not installed

## Performance Characteristics

- **Single file**: 50-100ms
- **Batch (100 files)**: 5-10 seconds
- **Memory**: Minimal (in-memory processing)
- **Reliability**: Deterministic, idempotent
- **Safety**: Atomic writes (temp file → rename)

## Maintenance Notes

**To update mappings**:
1. Edit `UnicodeReplacementTool/unicode_replacer.py`
2. Modify REPLACEMENTS dictionary (lines 17-276)
3. Test with test-skill.ps1
4. No changes needed to skill files (they reference the script)

**To add new file types**:
1. Update skill documentation if needed
2. Script already handles all text-based files
3. Test with new file type first

**To install for new users**:
1. Run: `install-runonsave-all-users.ps1`
2. Fix permissions: `icacls` (see AI-ENGINEER-SETUP-GUIDE.md)
3. Verify: `check-user-extension.ps1`

## Version Information

- **Project Created**: 2025-09-14 (original monitoring system)
- **Skill Created**: 2025-11-03 (Claude Code skill wrapper)
- **Script Version**: Stable with 276-line mapping dictionary
- **Extension Version**: emeraldwalk.runonsave v0.2.7 (modified for single-file mode)

## Related Projects

This Unicode replacement tool can be used across any coding project. Consider installing the skill globally for Claude Code to use in all sessions.

**Global installation**: Copy `.claude/skills/unicode-remover/` to `~/.claude/skills/`

## Support

For issues or questions:
1. Check `AI-ENGINEER-SETUP-GUIDE.md` for troubleshooting
2. Review `.claude/skills/unicode-remover/SKILL.md` for detailed usage
3. See `vscode.ext/memory.md` for historical context
4. Test with `.claude/skills/unicode-remover/test-skill.ps1`
