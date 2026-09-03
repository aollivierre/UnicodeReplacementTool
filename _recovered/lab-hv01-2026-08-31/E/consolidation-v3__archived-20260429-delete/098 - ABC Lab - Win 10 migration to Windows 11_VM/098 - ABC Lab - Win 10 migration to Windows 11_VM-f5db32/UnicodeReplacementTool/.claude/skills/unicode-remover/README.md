# Unicode Remover - Claude Code Skill

A deterministic, automated skill for removing Unicode characters from source code files and replacing them with ASCII equivalents.

## Quick Start

### Installation

```powershell
# Run from this directory
.\install-skill.ps1

# Or specify custom Claude skills path
.\install-skill.ps1 -ClaudeSkillsPath "C:\custom\path\.claude\skills"
```

### Usage in Claude Code

Just ask Claude to use the skill:

```
"Use the unicode-remover skill to clean all PowerShell files in this directory"
"Check if this file has Unicode and clean it"
"Process all Python files with unicode-remover"
```

Claude will automatically:
1. Detect the skill is available
2. Run the unicode replacement script
3. Report results

## What It Does

Replaces Unicode characters with ASCII equivalents:

- `"smart quotes"` → `"standard quotes"`
- `em—dash` → `em--dash`
- `arrow →` → `arrow ->`
- `✅ emoji` → `[CHECK] emoji`
- `∑ math` → `SUM math`

## Files in This Skill

| File | Purpose |
|------|---------|
| `SKILL.md` | Complete skill documentation for Claude Code |
| `README.md` | This quick-start guide |
| `install-skill.ps1` | Installation script |
| `unicode_replacer.py` | Copy of the Python script (auto-created) |

## Main Script Location

**Primary source**: `C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py`

The skill references this path directly. Updates to the main script automatically apply to the skill.

## Design Philosophy

This skill is **intentionally deterministic**:

- ✅ No AI creativity in replacements (fixed mappings)
- ✅ Same input always produces same output
- ✅ No user confirmation needed (it's a code quality tool)
- ✅ Idempotent (safe to run multiple times)
- ✅ Fast and lightweight (50-100ms per file)

This makes it perfect for AI agents to invoke automatically without human oversight.

## For AI Engineers

See `SKILL.md` for complete documentation including:
- When to invoke this skill
- Integration examples
- Error handling
- Performance characteristics
- Best practices

## Related Documentation

- **Complete Skill Guide**: `SKILL.md`
- **AI Engineer Setup**: `C:\code\UnicodeReplacementTool\AI-ENGINEER-SETUP-GUIDE.md`
- **VS Code Extension**: `C:\code\UnicodeReplacementTool\RUNONSAVE-SETUP-FOR-USER.md`
- **Tool History**: `C:\code\UnicodeReplacementTool\vscode.ext\memory.md`

## Version

**Skill Version**: 1.0.0
**Created**: 2025-11-03
**Compatibility**: Python 3.x, Windows/Linux/macOS
