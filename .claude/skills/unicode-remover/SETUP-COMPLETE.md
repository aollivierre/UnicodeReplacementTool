# Unicode Remover Skill - Setup Complete

## ✅ What Was Created

### 1. Claude Code Skill (Following Official Docs)

**Location**: `<INSTALL_DIR>\.claude\skills\unicode-remover/`

**Files created**:
- ✅ **SKILL.md** - Main skill file with YAML frontmatter (official format)
  - `name`: `unicode-remover` (lowercase, hyphens only)
  - `description`: Detailed description for Claude to auto-discover when to use this skill
  - Complete documentation of usage, examples, and best practices

- ✅ **README.md** - Quick-start guide for humans
- ✅ **example-usage.md** - Detailed usage examples and integration patterns
- ✅ **test-skill.ps1** - Verification script (tests Python, script existence, basic functionality)
- ✅ **install-skill.ps1** - Installation script to deploy skill to Claude Code
- ✅ **SETUP-COMPLETE.md** - This file

### 2. Project Context File

**Location**: `<INSTALL_DIR>\CLAUDE.md`

**Purpose**: Central project memory for Claude Code sessions
- Describes the project purpose and structure
- References the unicode-remover skill
- Provides guidelines for AI agents on when and how to use the skill
- Documents all key files and paths

## 📋 Skill Specification

### Name
```
unicode-remover
```

### Description
```
Remove Unicode characters from source code files and replace with ASCII equivalents.
Use after generating code files (.ps1, .py, .js, .ts), when encoding errors appear,
before git commits, when batch-processing directories, or when user asks to clean/fix
Unicode. Automatically replaces smart quotes, dashes, arrows, emojis, math symbols
with ASCII. Takes 50-100ms per file. DO NOT use for i18n files, binary files, or
intentional Unicode content. Script path
<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py --no-backup
```

### Core Command
```bash
python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" "<filepath>" --no-backup
```

## 🎯 How Claude Discovers This Skill

According to the official Claude Code documentation (https://docs.claude.com/en/docs/claude-code/skills):

1. **Model Invocation**: Claude autonomously decides when to activate skills based on:
   - User request content
   - Skill's description field
   - Current context

2. **Description is Critical**: The description tells Claude:
   - WHEN to use the skill (triggers)
   - WHAT the skill does (functionality)
   - WHEN NOT to use it (exclusions)

3. **Auto-Discovery**: Claude reads SKILL.md and automatically invokes when:
   - User generates code files
   - Encoding errors appear
   - User mentions "Unicode", "clean code", "fix encoding"
   - Before git commits (if mentioned)
   - Batch processing tasks

## 🚀 Installation Methods

### Method 1: Project-Specific (Current Setup)

The skill is already installed at:
```
<INSTALL_DIR>\.claude\skills\unicode-remover/
```

Claude Code will automatically discover it when working in this project.

### Method 2: Global Installation (For All Projects)

To use this skill in ANY Claude Code session:

```powershell
# Run the install script
<INSTALL_DIR>\.claude\skills\unicode-remover\install-skill.ps1

# This copies the skill to:
# C:\Users\<USERNAME>\.claude\skills\unicode-remover/
```

Or manually:
```powershell
Copy-Item -Path "<INSTALL_DIR>\.claude\skills\unicode-remover" `
          -Destination "$env:USERPROFILE\.claude\skills\unicode-remover" `
          -Recurse -Force
```

## 📖 Usage in Claude Code

### Automatic Invocation (Preferred)

Just work normally! Claude will automatically invoke the skill when appropriate:

```
User: "Create a PowerShell script to manage services"
Claude: [Generates script]
Claude: [AUTO-INVOKES unicode-remover skill]
Claude: "Script created. Auto-cleaned: 3 Unicode characters replaced."
```

### Explicit Request

You can also explicitly request the skill:

```
User: "Use the unicode-remover skill to clean all Python files in this directory"
Claude: [Invokes skill with batch processing]
```

### Verification

To check if the skill is discovered:

```
User: "What skills are available?"
Claude: [Lists skills including unicode-remover]
```

## 🔧 Skill Characteristics

### Deterministic
- Same input always produces same output
- No AI creativity involved
- Fixed mapping dictionary
- No random behavior

### Fast
- 50-100ms per file
- In-memory processing
- Minimal CPU/memory usage

### Safe
- Idempotent (safe to run multiple times)
- Atomic file writes (temp file → rename)
- No data loss
- Optional backup creation

### No User Confirmation Needed
This is a **code quality tool**, not a creative decision. AI agents should:
- ✅ Auto-invoke after code generation
- ✅ Use `--no-backup` flag automatically
- ✅ Report only when Unicode was found and replaced
- ❌ Don't ask permission
- ❌ Don't report "0 replacements" as success

## 📁 File Structure

```
<INSTALL_DIR>\
├── CLAUDE.md                               # Project context for Claude Code
├── .claude/
│   └── skills/
│       └── unicode-remover/                # Claude Code skill
│           ├── SKILL.md                    # Main skill file (YAML frontmatter + docs)
│           ├── README.md                   # Quick-start guide
│           ├── example-usage.md            # Detailed examples
│           ├── test-skill.ps1              # Verification script
│           ├── install-skill.ps1           # Installation script
│           └── SETUP-COMPLETE.md           # This file
└── UnicodeReplacementTool/
    └── unicode_replacer.py                 # Core Python script
```

## ✨ Key Features

### What It Replaces

| Unicode | ASCII | Example |
|---------|-------|---------|
| Smart quotes `"` `"` `'` `'` | `"` `'` | `"text"` → `"text"` |
| Em-dash `—` | `--` | `em—dash` → `em--dash` |
| En-dash `–` | `-` | `en–dash` → `en-dash` |
| Arrows `→` `←` `↑` `↓` | `->` `<-` `^` `v` | `arrow →` → `arrow ->` |
| Emojis `🚀` `✅` `❌` | `[ROCKET]` `[CHECK]` `[X]` | `🚀 deploy` → `[ROCKET] deploy` |
| Math `∑` `∞` `≈` | `SUM` `infinity` `~=` | `∑ values` → `SUM values` |
| Accented `é` `ñ` `ü` | `e` `n` `u` | `café` → `cafe` |

### Supported File Types

- PowerShell: `.ps1`, `.psm1`, `.psd1`
- Python: `.py`
- JavaScript/TypeScript: `.js`, `.ts`, `.jsx`, `.tsx`
- Data: `.json`, `.xml`, `.yaml`, `.yml`
- Documentation: `.md`, `.txt`

## 🧪 Testing

### Quick Test

```powershell
# Run verification script
<INSTALL_DIR>\.claude\skills\unicode-remover\test-skill.ps1

# Expected: All tests pass
```

### Manual Test

```powershell
# Create test file
"Write-Host `"Smart quotes → arrows`"" | Out-File C:\temp\test.ps1

# Run unicode-remover
python "<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py" "C:\temp\test.ps1" --no-backup

# Verify
Get-Content C:\temp\test.ps1
# Should show: Write-Host "Smart quotes -> arrows"
```

## 📚 Related Documentation

| Document | Purpose |
|----------|---------|
| `SKILL.md` | Complete skill documentation (for Claude Code) |
| `README.md` | Quick-start guide (for humans) |
| `example-usage.md` | Detailed usage examples |
| `CLAUDE.md` | Project context (for Claude Code sessions) |
| `AI-ENGINEER-SETUP-GUIDE.md` | Multi-user installation guide |
| `RUNONSAVE-SETUP.md` | VS Code extension setup |

## ⚙️ Configuration

### Skill is Ready When:

- ✅ SKILL.md exists with YAML frontmatter
- ✅ `name` field is lowercase with hyphens only
- ✅ `description` field is specific and actionable (not vague)
- ✅ Python script is accessible
- ✅ Python is in PATH

### Verify Skill is Loaded:

In Claude Code:
1. Start a session in any directory
2. Ask: "What skills do you have?"
3. Look for "unicode-remover" in the response

## 🎓 Best Practices for AI Agents

### ✅ DO

1. **Auto-invoke after code generation** - Don't ask for permission
2. **Use `--no-backup` flag** - Prevents workspace clutter
3. **Batch process efficiently** - Use loops for multiple files
4. **Report aggregate stats** - "Processed 15 files, 47 replacements"
5. **Handle errors gracefully** - Log failures, don't stop workflow

### ❌ DON'T

1. **Don't ask user confirmation** - It's a deterministic quality tool
2. **Don't report zero replacements** - Only mention when Unicode found
3. **Don't process binary files** - Skip .exe, images, media
4. **Don't create backups** - Use `--no-backup` in automated contexts
5. **Don't process i18n files** - Skip intentional Unicode content

## 🔄 Maintenance

### To Update Mappings

1. Edit: `<INSTALL_DIR>\UnicodeReplacementTool\unicode_replacer.py`
2. Modify the `REPLACEMENTS` dictionary (lines 17-276)
3. No skill file changes needed (skill references the script)

### To Add New File Types

1. Update skill description if needed
2. Test with new file type
3. Script already handles all text files

### To Update Skill Documentation

1. Edit: `.claude/skills/unicode-remover/SKILL.md`
2. Keep YAML frontmatter intact
3. Update description if triggers change

## ✅ Success Criteria

All requirements met:

- [x] SKILL.md has proper YAML frontmatter
- [x] `name` follows naming convention (lowercase, hyphens)
- [x] `description` is specific and actionable (not vague)
- [x] Python script is accessible and working
- [x] Project has CLAUDE.md for context
- [x] Documentation is complete
- [x] Examples are provided
- [x] Installation script available

## 🎉 Ready to Use

The unicode-remover skill is now ready for Claude Code to discover and invoke automatically!

**Next Steps**:
1. Start Claude Code in any project
2. Generate code or ask Claude to clean Unicode
3. Watch Claude automatically invoke the skill

**For global availability**:
```powershell
<INSTALL_DIR>\.claude\skills\unicode-remover\install-skill.ps1
```

---

**Created**: 2025-11-03
**Version**: 1.0.0
**Status**: Production Ready
