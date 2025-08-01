#!/usr/bin/env python3
"""
Unicode Replacement Tool - Production Version
Reliably replaces Unicode characters with ASCII equivalents in PowerShell scripts
"""

import os
import sys
import json
import argparse
from pathlib import Path
import shutil
from datetime import datetime
from typing import Dict, List, Tuple, Optional

# Comprehensive Unicode to ASCII replacement mappings
REPLACEMENTS = {
    # Check marks and status symbols
    '✓': '[OK]',
    '✔': '[SUCCESS]', 
    '✗': '[FAIL]',
    '✘': '[ERROR]',
    '⚠': '[WARNING]',
    '⚡': '[ALERT]',
    'ℹ': '[INFO]',
    
    # Emoji - Development
    '🔧': '[CONFIG]',
    '📁': '[FOLDER]',
    '📂': '[FOLDER_OPEN]',
    '📄': '[FILE]',
    '💾': '[SAVE]',
    '🔍': '[SEARCH]',
    '🔎': '[SEARCH]',
    '🔒': '[LOCKED]',
    '🔓': '[UNLOCKED]',
    '🔑': '[KEY]',
    
    # Emoji - Operations
    '📦': '[PACKAGE]',
    '🚀': '[DEPLOY]',
    '🛠': '[BUILD]',
    '⚙': '[SETTINGS]',
    '🐛': '[BUG]',
    '🔥': '[CRITICAL]',
    '🏁': '[COMPLETE]',
    '🚨': '[EMERGENCY]',
    '📊': '[STATS]',
    '📈': '[GROWTH]',
    '📉': '[DECLINE]',
    '📋': '[REPORT]',
    '💡': '[IDEA]',
    '🎯': '[TARGET]',
    '⏰': '[TIME]',
    '📅': '[CALENDAR]',
    
    # Arrows
    '→': '->',
    '←': '<-',
    '↔': '<->',
    '↑': '^',
    '↓': 'v',
    '⇒': '=>',
    '⇐': '<=',
    '⇔': '<=>',
    
    # Punctuation and typography
    '…': '...',
    '•': '*',
    '●': '*',
    '○': 'o',
    '◦': 'o',
    '▪': '*',
    '▫': 'o',
    '■': '[#]',
    '□': '[ ]',
    '▶': '>',
    '◀': '<',
    '▲': '^',
    '▼': 'v',
    '★': '*',
    '☆': 'o',
    
    # Dashes and quotes
    '—': '--',
    '–': '-',
    '"': '"',
    '"': '"',
    ''': "'",
    ''': "'",
    '„': '"',
    '‚': "'",
    '«': '<<',
    '»': '>>',
    
    # Special characters
    '©': '(c)',
    '®': '(R)',
    '™': '(TM)',
    '°': 'deg',
    '¢': 'cents',
    '£': 'GBP',
    '€': 'EUR',
    '¥': 'JPY',
    '§': 'S',
    '¶': 'P',
    
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
    '∝': 'proportional',
    '∈': 'in',
    '∉': 'not in',
    '⊂': 'subset',
    '∩': 'intersection',
    '∪': 'union',
    'Δ': 'delta',
    '∂': 'partial',
    '∫': 'integral',
    
    # Fractions
    '½': '1/2',
    '⅓': '1/3',
    '⅔': '2/3',
    '¼': '1/4',
    '¾': '3/4',
    '⅕': '1/5',
    '⅖': '2/5',
    '⅗': '3/5',
    '⅘': '4/5',
    '⅙': '1/6',
    '⅚': '5/6',
    '⅐': '1/7',
    '⅛': '1/8',
    '⅜': '3/8',
    '⅝': '5/8',
    '⅞': '7/8',
    '⅑': '1/9',
    '⅒': '1/10',
}

def find_unicode_chars(text: str) -> List[Dict]:
    """Find all non-ASCII characters in text"""
    unicode_chars = []
    lines = text.split('\n')
    
    for line_num, line in enumerate(lines, 1):
        for col_num, char in enumerate(line, 1):
            if ord(char) > 127:
                unicode_chars.append({
                    'char': char,
                    'line': line_num,
                    'column': col_num,
                    'code': f'U+{ord(char):04X}',
                    'context': line.strip()[:50] + ('...' if len(line.strip()) > 50 else '')
                })
    
    return unicode_chars

def replace_unicode(text: str) -> Tuple[str, List[Tuple[str, str]]]:
    """Replace Unicode characters with ASCII equivalents"""
    result = []
    replacements_made = []
    replacement_counts = {}
    
    for char in text:
        if ord(char) > 127:
            replacement = REPLACEMENTS.get(char, f'[U+{ord(char):04X}]')
            result.append(replacement)
            
            # Track replacements
            if char not in replacement_counts:
                replacement_counts[char] = 0
            replacement_counts[char] += 1
            
            # Only record unique replacements
            if (char, replacement) not in replacements_made:
                replacements_made.append((char, replacement))
        else:
            result.append(char)
    
    return ''.join(result), replacements_made

def verify_ascii(text: str) -> bool:
    """Verify text contains only ASCII characters"""
    for char in text:
        if ord(char) > 127:
            return False
    return True

def process_file(filepath: Path, preview_only: bool = False, create_backup: bool = True) -> Optional[Dict]:
    """Process a single file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        print(f"Warning: {filepath} - Unicode decode error, trying with errors='replace'")
        try:
            with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
                content = f.read()
        except Exception as e:
            print(f"Error reading {filepath}: {e}")
            return None
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return None
    
    # Find Unicode characters
    unicode_chars = find_unicode_chars(content)
    if not unicode_chars:
        return {
            'file': filepath,
            'unicode_count': 0,
            'replacements': [],
            'status': 'no_unicode'
        }
    
    # Replace Unicode
    new_content, replacements = replace_unicode(content)
    
    # Verify result is ASCII-only
    if not verify_ascii(new_content):
        print(f"ERROR: {filepath} - Result still contains Unicode characters!")
        return {
            'file': filepath,
            'unicode_count': len(unicode_chars),
            'replacements': replacements,
            'status': 'error'
        }
    
    if not preview_only:
        # Create backup
        if create_backup:
            backup_path = filepath.with_suffix(filepath.suffix + f'.backup_{datetime.now().strftime("%Y%m%d_%H%M%S")}')
            shutil.copy2(filepath, backup_path)
            print(f"Backup created: {backup_path}")
        
        # Write new content with ASCII encoding
        try:
            with open(filepath, 'w', encoding='ascii') as f:
                f.write(new_content)
            print(f"Updated: {filepath}")
        except UnicodeEncodeError as e:
            print(f"ERROR writing {filepath}: {e}")
            return {
                'file': filepath,
                'unicode_count': len(unicode_chars),
                'replacements': replacements,
                'status': 'write_error'
            }
    
    return {
        'file': filepath,
        'unicode_count': len(unicode_chars),
        'replacements': replacements,
        'status': 'success'
    }

def main():
    parser = argparse.ArgumentParser(
        description='Replace Unicode characters with ASCII equivalents in PowerShell scripts',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s script.ps1                    # Process single file
  %(prog)s C:\\Scripts                    # Process all .ps1 files in directory
  %(prog)s C:\\Scripts --preview          # Preview changes without modifying
  %(prog)s C:\\Scripts --pattern "*.txt"  # Process .txt files
  %(prog)s script.ps1 --no-backup       # Skip backup creation
        """
    )
    
    parser.add_argument('path', help='File or directory to process')
    parser.add_argument('--preview', action='store_true', help='Preview changes without modifying files')
    parser.add_argument('--no-backup', action='store_true', help='Skip creating backup files')
    parser.add_argument('--pattern', default='*.ps1', help='File pattern to match (default: *.ps1)')
    parser.add_argument('--recursive', action='store_true', default=True, help='Process subdirectories (default: True)')
    parser.add_argument('--verbose', action='store_true', help='Show detailed output')
    
    args = parser.parse_args()
    
    path = Path(args.path)
    files_to_process = []
    
    if path.is_file():
        files_to_process = [path]
    elif path.is_dir():
        if args.recursive:
            files_to_process = list(path.rglob(args.pattern))
        else:
            files_to_process = list(path.glob(args.pattern))
    else:
        print(f"Error: {path} not found")
        return 1
    
    if not files_to_process:
        print(f"No files matching pattern '{args.pattern}' found in {path}")
        return 0
    
    print(f"{'='*60}")
    print(f"Unicode Replacement Tool - {'PREVIEW MODE' if args.preview else 'PROCESSING'}")
    print(f"{'='*60}")
    print(f"Path: {path}")
    print(f"Files found: {len(files_to_process)}")
    print(f"Pattern: {args.pattern}")
    print(f"Backup: {'Disabled' if args.no_backup else 'Enabled'}")
    print(f"{'='*60}\n")
    
    total_replacements = 0
    files_with_unicode = 0
    errors = 0
    
    for filepath in files_to_process:
        result = process_file(filepath, args.preview, not args.no_backup)
        
        if result:
            if result['unicode_count'] > 0:
                files_with_unicode += 1
                total_replacements += result['unicode_count']
                
                if args.verbose or args.preview:
                    print(f"\n{filepath}:")
                    print(f"  Found {result['unicode_count']} Unicode characters")
                    
                    if args.preview:
                        # Show sample replacements
                        for char, replacement in result['replacements'][:5]:
                            try:
                                print(f"  {char} -> {replacement}")
                            except UnicodeEncodeError:
                                print(f"  [U+{ord(char):04X}] -> {replacement}")
                        
                        if len(result['replacements']) > 5:
                            print(f"  ... and {len(result['replacements']) - 5} more unique replacements")
            
            if result['status'] == 'error' or result['status'] == 'write_error':
                errors += 1
    
    # Summary
    print(f"\n{'='*60}")
    print("SUMMARY")
    print(f"{'='*60}")
    print(f"Files processed: {len(files_to_process)}")
    print(f"Files with Unicode: {files_with_unicode}")
    print(f"Total replacements: {total_replacements}")
    if errors > 0:
        print(f"Errors: {errors}")
    print(f"Status: {'Preview complete' if args.preview else 'Processing complete'}")
    
    return 1 if errors > 0 else 0

if __name__ == '__main__':
    sys.exit(main())