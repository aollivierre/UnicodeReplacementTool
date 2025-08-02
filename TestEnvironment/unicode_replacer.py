#!/usr/bin/env python3
"""
Unicode Replacement Tool - Python Version
Reliably replaces Unicode characters with ASCII equivalents
"""

import os
import sys
import json
import argparse
from pathlib import Path
import shutil
from datetime import datetime

# Hardcoded replacements to avoid JSON Unicode issues
REPLACEMENTS = {
    '✓': '[OK]',
    '✔': '[SUCCESS]', 
    '✗': '[FAIL]',
    '✘': '[ERROR]',
    '⚠': '[WARNING]',
    '⚡': '[ALERT]',
    'ℹ': '[INFO]',
    '🔧': '[CONFIG]',
    '📁': '[FOLDER]',
    '📄': '[FILE]',
    '💾': '[SAVE]',
    '🔍': '[SEARCH]',
    '🔒': '[LOCKED]',
    '🔓': '[UNLOCKED]',
    '📦': '[PACKAGE]',
    '🚀': '[DEPLOY]',
    '🛠': '[BUILD]',
    '🐛': '[BUG]',
    '🔥': '[CRITICAL]',
    '🏁': '[COMPLETE]',
    '🚨': '[EMERGENCY]',
    '📊': '[STATS]',
    '📋': '[REPORT]',
    '💡': '[IDEA]',
    '→': '->',
    '←': '<-',
    '↔': '<->',
    '⇒': '=>',
    '⇐': '<=',
    '⇔': '<=>',
    '…': '...',
    '•': '*',
    '●': '*',
    '○': 'o',
    '■': '[#]',
    '□': '[ ]',
    '▶': '>',
    '◀': '<',
    '—': '--',
    '–': '-',
    '"': '"',
    '"': '"',
    ''': "'",
    ''': "'",
    '©': '(c)',
    '®': '(R)',
    '™': '(TM)',
    # Math symbols
    'π': 'pi',
    '∑': 'SUM',
    '∞': 'infinity',
    '≈': '~=',
    '≠': '!=',
    '≤': '<=',
    '≥': '>=',
    '±': '+/-',
    '×': 'x',
    '÷': '/',
    '√': 'sqrt',
}

def find_unicode_chars(text):
    """Find all non-ASCII characters in text"""
    unicode_chars = []
    for i, char in enumerate(text):
        if ord(char) > 127:
            unicode_chars.append({
                'char': char,
                'position': i,
                'code': f'U+{ord(char):04X}',
                'line': text[:i].count('\n') + 1
            })
    return unicode_chars

def replace_unicode(text):
    """Replace Unicode characters with ASCII equivalents"""
    result = []
    replacements_made = []
    
    for char in text:
        if ord(char) > 127:
            replacement = REPLACEMENTS.get(char, f'[U+{ord(char):04X}]')
            result.append(replacement)
            replacements_made.append((char, replacement))
        else:
            result.append(char)
    
    return ''.join(result), replacements_made

def process_file(filepath, preview_only=False, create_backup=True):
    """Process a single file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return None
    
    # Find Unicode characters
    unicode_chars = find_unicode_chars(content)
    if not unicode_chars:
        return {
            'file': filepath,
            'unicode_count': 0,
            'replacements': []
        }
    
    # Replace Unicode
    new_content, replacements = replace_unicode(content)
    
    # Verify result is ASCII-only
    for char in new_content:
        if ord(char) > 127:
            print(f"ERROR: Result still contains Unicode: {char} (U+{ord(char):04X})")
            return None
    
    if not preview_only:
        # Create backup
        if create_backup:
            backup_path = f"{filepath}.backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            shutil.copy2(filepath, backup_path)
            print(f"Backup created: {backup_path}")
        
        # Write new content
        with open(filepath, 'w', encoding='ascii') as f:
            f.write(new_content)
        print(f"Updated: {filepath}")
    
    return {
        'file': filepath,
        'unicode_count': len(unicode_chars),
        'replacements': replacements
    }

def main():
    parser = argparse.ArgumentParser(description='Replace Unicode characters with ASCII equivalents')
    parser.add_argument('path', help='File or directory to process')
    parser.add_argument('--preview', action='store_true', help='Preview changes without modifying files')
    parser.add_argument('--no-backup', action='store_true', help='Skip creating backup files')
    parser.add_argument('--pattern', default='*.ps1', help='File pattern to match (default: *.ps1)')
    
    args = parser.parse_args()
    
    path = Path(args.path)
    files_to_process = []
    
    if path.is_file():
        files_to_process = [path]
    elif path.is_dir():
        files_to_process = list(path.rglob(args.pattern))
    else:
        print(f"Error: {path} not found")
        return 1
    
    print(f"{'PREVIEW MODE' if args.preview else 'PROCESSING'} - {len(files_to_process)} files")
    print("=" * 60)
    
    total_replacements = 0
    
    for filepath in files_to_process:
        result = process_file(filepath, args.preview, not args.no_backup)
        if result:
            if result['unicode_count'] > 0:
                print(f"\n{filepath}:")
                print(f"  Found {result['unicode_count']} Unicode characters")
                if args.preview:
                    for char, replacement in result['replacements'][:5]:  # Show first 5
                        try:
                            print(f"  {char} -> {replacement}")
                        except UnicodeEncodeError:
                            # Fallback for Windows console encoding issues
                            print(f"  [U+{ord(char):04X}] -> {replacement}")
                    if len(result['replacements']) > 5:
                        print(f"  ... and {len(result['replacements']) - 5} more")
                total_replacements += result['unicode_count']
    
    print("\n" + "=" * 60)
    print(f"Total Unicode characters {'found' if args.preview else 'replaced'}: {total_replacements}")
    return 0

if __name__ == '__main__':
    sys.exit(main())