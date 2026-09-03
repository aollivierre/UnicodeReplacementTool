# AI Engineer Complete Handoff - Unicode Replacement System

## Overview

This project provides **two complementary systems** for removing Unicode characters from source code:

1. **VS Code Extension** (for human engineers) - Auto-runs on Ctrl+S
2. **Claude Code Skill** (for AI agents) - Auto-invoked by Claude when needed

Both use the same underlying Python script but serve different purposes.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [System Architecture](#system-architecture)
3. [Complete Documentation Index](#complete-documentation-index)
4. [Setup Guide for New AI Engineer](#setup-guide-for-new-ai-engineer)
5. [Troubleshooting Common Issues](#troubleshooting-common-issues)
6. [Lessons Learned](#lessons-learned)

---

## Quick Start

### For Human Users (VS Code Extension)

**Goal**: Automatically replace Unicode when saving files in VS Code with Ctrl+S

**Read**: `AI-ENGINEER-SETUP-GUIDE.md` (complete multi-user setup)

**Key Points**:
- Modified RunOnSave extension (fixes single-file mode bug)
- User settings in `AppData\Roaming\Code\User\settings.json`
- Only PowerShell (.ps1, .psm1, .psd1) and Python (.py) auto-cleaned
- Requires VS Code restart after setup

### For AI Agents (Claude Code Skill)

**Goal**: Allow Claude to automatically invoke Unicode removal when generating code

**Read**: `.claude/skills/unicode-remover/SETUP-COMPLETE.md`

**Key Points**:
- Skill installed globally in `~/.claude/skills/unicode-remover/`
- SKILL.md with YAML frontmatter required
- Auto-discovered by Claude Code in any project
- Deterministic (no AI creativity, just fixed replacements)

---

## System Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────┐
│                 Unicode Replacement System              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Core Engine:                                           │
│  ┌───────────────────────────────────────────────┐     │
│  │  unicode_replacer.py                          │     │
│  │  - 276-line mapping dictionary                │     │
│  │  - Hardcoded replacements                     │     │
│  │  - 50-100ms per file                          │     │
│  │  Location: UnicodeReplacementTool/            │     │
│  │            UnicodeReplacementTool/            │     │
│  │            unicode_replacer.py                │     │
│  └───────────────────────────────────────────────┘     │
│                     ▲          ▲                        │
│                     │          │                        │
│         ┌───────────┘          └──────────┐            │
│         │                                  │            │
│         │                                  │            │
│  ┌──────▼──────────┐              ┌───────▼──────────┐ │
│  │  VS Code        │              │  Claude Code     │ │
│  │  Extension      │              │  Skill           │ │
│  │  (RunOnSave)    │              │  (unicode-       │ │
│  │                 │              │   remover)       │ │
│  │  For: Humans    │              │  For: AI Agents  │ │
│  │  Trigger: Ctrl+S│              │  Trigger: Auto   │ │
│  │  Scope: .ps1,.py│              │  Scope: Any file │ │
│  └─────────────────┘              └──────────────────┘ │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Why Two Systems?

**VS Code Extension**:
- Human engineer saves file → Extension runs script
- Automatic, no thinking required
- Limited to specific file types for safety
- Runs in VS Code's context

**Claude Code Skill**:
- Claude generates code → Claude invokes skill → Script runs
- AI-driven, context-aware
- Can process any file type (Claude decides when)
- Runs from command line

**Both use the same Python script** - they're just different trigger mechanisms.

---

## Complete Documentation Index

### 🎯 Start Here (Master Guides)

| Document | Purpose | Audience |
|----------|---------|----------|
| **AI-ENGINEER-COMPLETE-HANDOFF.md** | This file - complete overview | Next AI Engineer |
| **CLAUDE.md** | Project context for Claude Code | AI agents (Claude) |
| **README.md** (if exists) | Project overview | Humans browsing repo |

### 📘 VS Code Extension Setup (Human Users)

| Document | Location | Purpose |
|----------|----------|---------|
| **AI-ENGINEER-SETUP-GUIDE.md** | Root | Complete multi-user installation guide |
| **RUNONSAVE-SETUP-FOR-USER.md** | Root | End-user instructions |
| **VS-CODE-FILE-TYPE-SETTINGS.md** | Root | File type configuration explained |
| **TROUBLESHOOT-SINGLE-FILE-MODE.md** | Root | Debugging single-file mode issues |

### 🤖 Claude Code Skill Setup (AI Agents)

| Document | Location | Purpose |
|----------|----------|---------|
| **SKILL.md** | `.claude/skills/unicode-remover/` | Main skill file (YAML + docs) |
| **SETUP-COMPLETE.md** | `.claude/skills/unicode-remover/` | Skill installation guide |
| **example-usage.md** | `.claude/skills/unicode-remover/` | Usage patterns and examples |
| **README.md** | `.claude/skills/unicode-remover/` | Quick reference |
| **HOW-TO-MANAGE-MULTIPLE-SKILLS.md** | `~/.claude/skills/` | Managing multiple skills |
| **GLOBAL-SKILL-INSTALLATION-COMPLETE.md** | Root | Global installation summary |

### 🛠️ Technical Reference

| Document | Location | Purpose |
|----------|----------|---------|
| **unicode_replacer.py** | `UnicodeReplacementTool/UnicodeReplacementTool/` | Core Python script |
| **README-MODIFICATIONS.md** | VS Code extension folder | Extension modification details |
| **memory.md** | `vscode.ext/` | Historical development notes |

### 📋 Settings Files

| File | Location | Purpose |
|------|----------|---------|
| **User settings** | `C:\Users\<USER>\AppData\Roaming\Code\User\settings.json` | Global VS Code settings |
| **Workspace settings** | `.vscode\settings.json` | Project-specific VS Code settings |
| **Extension registry** | `C:\Users\<USER>\.vscode\extensions\extensions.json` | VS Code extension list |
| **SKILL.md** | `~/.claude/skills/unicode-remover/SKILL.md` | Claude Code skill definition |

---

## Setup Guide for New AI Engineer

### Scenario: Setting Up for a New User

**Goal**: Install both VS Code extension and Claude Code skill for a new user.

### Step 1: Install VS Code Extension (5-10 minutes)

**Follow**: `AI-ENGINEER-SETUP-GUIDE.md`

**Quick summary**:
```powershell
# 1. Install base extension
code --install-extension emeraldwalk.RunOnSave

# 2. Apply modified version
C:\code\UnicodeReplacementTool\vscode.ext\Extensions\RunOnSave-Modified\install-modified-extension.ps1 -Force

# 3. Install for all users
C:\code\UnicodeReplacementTool\install-runonsave-all-users.ps1

# 4. Fix permissions for each user
icacls "C:\Users\<USERNAME>\.vscode\extensions\emeraldwalk.runonsave-0.2.7" /grant <USERNAME>:F /T /Q

# 5. Update user settings
# Edit: C:\Users\<USERNAME>\AppData\Roaming\Code\User\settings.json
# Add emeraldwalk.runonsave configuration

# 6. Verify
C:\code\UnicodeReplacementTool\check-user-extension.ps1

# 7. Test
code C:\temp\test.ps1
# Edit, save with Ctrl+S, verify Unicode replaced
```

**Common mistakes** (documented in `AI-ENGINEER-SETUP-GUIDE.md`):
- ❌ Wrong installation order
- ❌ Forgetting file permissions
- ❌ Wrong path to unicode_replacer.py
- ❌ Not reloading VS Code

### Step 2: Install Claude Code Skill (2 minutes)

**Follow**: `.claude/skills/unicode-remover/SETUP-COMPLETE.md`

**Quick summary**:
```powershell
# Run installation script
C:\code\UnicodeReplacementTool\.claude\skills\unicode-remover\install-skill-fixed.ps1

# Or manual installation
Copy-Item -Path "C:\code\UnicodeReplacementTool\.claude\skills\unicode-remover" `
          -Destination "$env:USERPROFILE\.claude\skills\unicode-remover" `
          -Recurse -Force

# Verify
Test-Path "$env:USERPROFILE\.claude\skills\unicode-remover\SKILL.md"

# Test
# Start Claude Code and ask: "Create a PowerShell script to list files"
# Claude should auto-invoke unicode-remover after generating the script
```

**Key requirement**: SKILL.md must have proper YAML frontmatter (documented in `HOW-TO-MANAGE-MULTIPLE-SKILLS.md`)

### Step 3: Verification

**VS Code Extension**:
```powershell
# Test single file mode
code C:\temp\test-unicode.ps1
# Edit, add: Write-Host "arrow → test"
# Save (Ctrl+S)
# Verify → became ->
```

**Claude Code Skill**:
```bash
# Start Claude in any project
cd C:\SomeProject
claude

# Ask: "Create a PowerShell script"
# Watch for: "Auto-cleaned: X Unicode characters replaced"
```

---

## Troubleshooting Common Issues

### Issue 1: VS Code Extension Not Working

**Symptom**: Save file, nothing happens

**Checklist**:
- [ ] Extension installed? (`code --list-extensions | grep runonsave`)
- [ ] Extension enabled? (Check Extensions panel)
- [ ] User settings configured? (Check `AppData\Roaming\Code\User\settings.json`)
- [ ] VS Code reloaded? (Ctrl+Shift+P → Reload Window)
- [ ] File type matches? (.ps1 or .py only)
- [ ] Check Output panel (Ctrl+Shift+U → "Run On Save")

**Solution**: See `TROUBLESHOOT-SINGLE-FILE-MODE.md` for complete guide

### Issue 2: Claude Skill Not Invoked

**Symptom**: Claude generates code but doesn't clean Unicode

**Checklist**:
- [ ] Skill installed globally? (`~/.claude/skills/unicode-remover/`)
- [ ] SKILL.md has YAML frontmatter?
- [ ] Description is specific? (Not vague like "helps with files")
- [ ] Claude Code restarted? (Exit and restart)

**Debug**:
```bash
claude --debug
# Look for: "Loaded skill: unicode-remover"
```

**Solution**: See `.claude/skills/unicode-remover/SETUP-COMPLETE.md`

### Issue 3: Wrong Path to Python Script

**Symptom**: Extension/skill runs but errors occur

**Problem**: Path to `unicode_replacer.py` is wrong

**Correct path** (note the nested folder):
```
C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py
                                 ^^^^^^^^^^^^^^^^^^^
                                 Nested folder!
```

**Wrong path**:
```
C:\code\UnicodeReplacementTool\unicode_replacer.py
                               ❌ Missing nested folder
```

**Fix in settings**:
```json
"cmd": "python \"C:\\code\\UnicodeReplacementTool\\UnicodeReplacementTool\\unicode_replacer.py\" ..."
```

### Issue 4: Permission Errors

**Symptom**: "Access denied" or "Cannot read package.json"

**Cause**: Files owned by different user

**Solution**:
```powershell
icacls "C:\Users\<USERNAME>\.vscode\extensions\emeraldwalk.runonsave-0.2.7" /grant <USERNAME>:F /T /Q
```

**Details**: See `AI-ENGINEER-SETUP-GUIDE.md` Mistake #2

---

## Lessons Learned

### What Worked Well

✅ **Modified Extension Approach**
- Fixed single-file mode bug in extension source
- More reliable than workarounds
- Properly version controlled in `vscode.ext/Extensions/RunOnSave-Modified/`

✅ **Conservative File Type List**
- Only auto-clean code files (.ps1, .py)
- Prevents accidental documentation corruption
- User can manually clean other file types

✅ **Two Complementary Systems**
- VS Code for humans (manual workflow)
- Claude skill for AI (automatic workflow)
- Both use same core script

✅ **Comprehensive Documentation**
- Mistake documentation prevents repeat errors
- Multiple entry points for different audiences
- Troubleshooting guides for common issues

### What Didn't Work Initially

❌ **Too Many File Types Auto-Cleaned**
- Original: .py, .js, .ts, .jsx, .tsx, .json, .md, .txt, .xml, .yaml, .yml
- Problem: Could corrupt documentation and data files
- Solution: Reduced to .ps1, .psm1, .psd1, .py only
- Documented in: `VS-CODE-FILE-TYPE-SETTINGS.md`

❌ **Wrong Installation Order**
- Installing for all users before base extension exists
- Solution: Document exact order in `AI-ENGINEER-SETUP-GUIDE.md`

❌ **Missing File Permissions**
- Copied files not readable by target user
- Solution: Always run `icacls` after copying
- Documented in: `AI-ENGINEER-SETUP-GUIDE.md` Mistake #2

❌ **Vague Skill Descriptions**
- Initial skill description too generic
- Claude wouldn't auto-invoke
- Solution: Very specific description with triggers and file types
- Documented in: `HOW-TO-MANAGE-MULTIPLE-SKILLS.md`

### Critical Success Factors

🎯 **User Settings Required**
- VS Code extension MUST have user settings (not just workspace)
- Extension reads user settings in single-file mode
- Without this, single-file mode fails

🎯 **VS Code Restart Required**
- After installing extension
- After modifying extension
- After changing user settings
- Document this prominently!

🎯 **YAML Frontmatter Essential**
- Claude Code skills REQUIRE proper YAML frontmatter
- `name:` must be lowercase with hyphens
- `description:` must be specific with triggers
- No frontmatter = skill won't load

🎯 **Path Awareness**
- Script is in nested folder: `UnicodeReplacementTool\UnicodeReplacementTool\`
- Easy to forget the double folder
- Document prominently in all guides

### Best Practices Established

📋 **For Future AI Engineers**

1. **Always read existing docs first**
   - Start with this file
   - Check lesson learned section
   - Follow guides step-by-step

2. **Test both systems separately**
   - VS Code extension → Test with single file
   - Claude skill → Test in new project
   - Don't debug both at once

3. **Document all changes**
   - Update relevant markdown files
   - Add to lessons learned
   - Include error messages you fixed

4. **Verify before moving on**
   - Each step in installation has a verification
   - Don't skip these
   - Use the provided test scripts

5. **Ask user for feedback**
   - "Is it working in single-file mode?"
   - "Does Claude invoke it automatically?"
   - Don't assume success

---

## File Organization

### Root Directory Structure

```
C:\code\UnicodeReplacementTool\
├── CLAUDE.md                              # Project context for Claude
├── AI-ENGINEER-COMPLETE-HANDOFF.md        # This file - master guide
├── AI-ENGINEER-SETUP-GUIDE.md             # VS Code extension setup
├── RUNONSAVE-SETUP-FOR-USER.md          # User guide
├── GLOBAL-SKILL-INSTALLATION-COMPLETE.md  # Skill installation summary
├── VS-CODE-FILE-TYPE-SETTINGS.md          # File type configuration
├── TROUBLESHOOT-SINGLE-FILE-MODE.md       # Troubleshooting guide
├── .claude/
│   └── skills/
│       └── unicode-remover/               # Claude Code skill
│           ├── SKILL.md                   # Main skill file
│           ├── SETUP-COMPLETE.md          # Setup guide
│           ├── example-usage.md           # Usage examples
│           ├── README.md                  # Quick reference
│           ├── test-skill.ps1             # Verification
│           └── install-skill-fixed.ps1    # Installation
├── UnicodeReplacementTool/
│   └── UnicodeReplacementTool/
│       └── unicode_replacer.py            # Core Python script
├── vscode.ext/
│   ├── memory.md                          # Development history
│   └── Extensions/
│       └── RunOnSave-Modified/            # Modified extension source
├── install-runonsave-all-users.ps1        # Multi-user installer
├── setup-runonsave-workspace.ps1          # Workspace configurator
└── check-user-extension.ps1             # Verification script
```

### User-Specific Files

```
C:\Users\<USERNAME>\
├── AppData\Roaming\Code\User\
│   └── settings.json                      # VS Code user settings
├── .vscode\extensions\
│   ├── emeraldwalk.runonsave-0.2.7\       # Modified extension
│   └── extensions.json                    # Extension registry
└── .claude\skills\
    └── unicode-remover\                   # Global skill
        └── SKILL.md
```

---

## Quick Reference Commands

### VS Code Extension

```powershell
# Install for new user
code --install-extension emeraldwalk.RunOnSave
C:\code\UnicodeReplacementTool\install-runonsave-all-users.ps1
icacls "C:\Users\<USER>\.vscode\extensions\emeraldwalk.runonsave-0.2.7" /grant <USER>:F /T /Q

# Verify
code --list-extensions | grep runonsave
C:\code\UnicodeReplacementTool\check-user-extension.ps1

# Test
code C:\temp\test.ps1
# Edit, save, verify
```

### Claude Code Skill

```powershell
# Install for new user
C:\code\UnicodeReplacementTool\.claude\skills\unicode-remover\install-skill-fixed.ps1

# Verify
Test-Path "$env:USERPROFILE\.claude\skills\unicode-remover\SKILL.md"

# Test
claude
# Ask Claude to generate code, watch for auto-cleaning
```

### Direct Script Execution

```powershell
# Single file
python "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py" "file.ps1" --no-backup

# Preview mode
python "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py" "file.ps1" --preview

# With backup
python "C:\code\UnicodeReplacementTool\UnicodeReplacementTool\unicode_replacer.py" "file.ps1" --backup
```

---

## System Status (Current Deployment)

### Users Configured

| User | VS Code Extension | Claude Skill | Status |
|------|-------------------|--------------|--------|
| i | ✅ Installed | ✅ Installed | Working |
| User | ✅ Installed | ✅ Installed | Working |
| IT | ❌ No VS Code | N/A | Skipped |

### File Types Configured

| File Type | VS Code Auto-Clean | Claude Skill | Reason |
|-----------|-------------------|--------------|--------|
| .ps1, .psm1, .psd1 | ✅ Yes | ✅ Yes | PowerShell code |
| .py | ✅ Yes | ✅ Yes | Python code |
| .js, .ts, .jsx, .tsx | ❌ No | ✅ On request | Not enabled by default |
| .json, .xml, .yaml | ❌ No | ✅ On request | Could have data |
| .md, .txt | ❌ No | ✅ On request | Documentation |

### Current Version Info

- **Extension**: emeraldwalk.runonsave v0.2.7 (modified)
- **Python Script**: Stable version with 276-line mapping dictionary
- **Skill Version**: 1.0.0
- **Last Updated**: 2025-11-03
- **Status**: Production-ready

---

## Next Steps for New AI Engineer

### Onboarding Checklist

When taking over this project:

- [ ] Read this file completely
- [ ] Read `AI-ENGINEER-SETUP-GUIDE.md`
- [ ] Read `.claude/skills/unicode-remover/SETUP-COMPLETE.md`
- [ ] Test VS Code extension (single file mode)
- [ ] Test Claude Code skill (new project)
- [ ] Review all markdown files in root directory
- [ ] Check for any open issues or TODOs
- [ ] Verify both users (i and User) still working
- [ ] Update this file with any new findings

### Making Changes

If you need to:

**Update Unicode Mappings**:
1. Edit: `UnicodeReplacementTool/UnicodeReplacementTool/unicode_replacer.py`
2. Modify REPLACEMENTS dictionary (lines 17-276)
3. Test thoroughly
4. No re-installation needed (both systems reference the script)

**Add More File Types**:
1. Read: `VS-CODE-FILE-TYPE-SETTINGS.md`
2. Consider risks carefully
3. Update user settings
4. Test with sample files
5. Document the change

**Fix Extension Bug**:
1. Modify: `vscode.ext/Extensions/RunOnSave-Modified/out/src/extension.js`
2. Update: `README-MODIFICATIONS.md` with changes
3. Reinstall for all users
4. Test single-file mode specifically

**Update Skill Description**:
1. Edit: `.claude/skills/unicode-remover/SKILL.md` (YAML frontmatter)
2. Make description more specific if Claude not auto-invoking
3. Reinstall globally: `install-skill-fixed.ps1`
4. Test with Claude Code

---

## Summary

This Unicode replacement system consists of:

1. **Core**: Python script with hardcoded mappings (50-100ms per file)
2. **For Humans**: Modified VS Code extension (auto-runs on Ctrl+S)
3. **For AI**: Claude Code skill (auto-invoked by Claude when needed)

**Both are installed and working** for users i and User.

**All documentation is in place** for the next AI Engineer to:
- Understand the system
- Install for new users
- Troubleshoot issues
- Make modifications
- Avoid past mistakes

**Key principle**: Conservative auto-cleaning (only code files) with manual options for everything else.

---

**Handoff Complete**: 2025-11-03
**Status**: Production System - Fully Operational
**Next AI Engineer**: Read this file first, then dive into specific guides as needed

Good luck! 🚀
