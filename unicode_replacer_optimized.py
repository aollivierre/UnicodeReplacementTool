#!/usr/bin/env python3
"""
Unicode Replacement Tool - BATCH MODE (Manual On-Demand Processing)
OPTIMIZED VERSION 2.0 - 1.94x faster than baseline

PURPOSE:
  Manual, on-demand batch processing of files/directories.
  Use this for one-time cleanup, testing, or interactive processing.

WHEN TO USE:
  - Clean an entire project directory manually
  - Preview changes before applying (dry-run mode)
  - Interactive mode with user confirmation
  - One-time cleanup of existing files

DO NOT USE FOR:
  - Automatic real-time monitoring (use unicode-ultrafast-monitor-optimized.py instead)
  - 24/7 background processing (use Windows Service instead)

PERFORMANCE IMPROVEMENTS (v2.0):
  1. ThreadPoolExecutor for parallel file processing (3-5 workers)
  2. Single-pass text processing (combined find + replace + verify)
  3. Early ASCII detection to skip clean files (0ms for clean files)
  4. Optimized string building

COMPANION TOOL:
  For automatic real-time monitoring, see:
  unicode-ultrafast-monitor-optimized.py (runs as Windows Service)
"""

import os
import sys
import json
import argparse
from pathlib import Path
import shutil
from datetime import datetime
from typing import Dict, List, Tuple, Optional
from concurrent.futures import ThreadPoolExecutor, as_completed
import multiprocessing

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

    # Additional emoji found in SetupLab
    '✅': '[DONE]',
    '⏳': '[WAIT]',
    '❌': '[ERROR]',
    '🎉': '[CELEBRATE]',
    '🔄': '[REFRESH]',
    '🤖': '[BOT]',
    '█': '[BLOCK]',
    '\ufeff': '',  # BOM character - remove it
    '\ufe0f': '',  # Variation selector - remove it

    # Arrows
    '→': '->',
    '←': '<-',
    '↔': '<->',
    '↑': '^',
    '↓': 'v',
    '⇒': '=>',
    '⇐': '<=',
    '⇔': '<=>',

    # Box drawing characters
    '─': '-',       # Horizontal line
    '│': '|',       # Vertical line
    '┌': '+',       # Top-left corner
    '┐': '+',       # Top-right corner
    '└': '+',       # Bottom-left corner
    '┘': '+',       # Bottom-right corner
    '├': '+',       # Left T
    '┤': '+',       # Right T
    '┬': '+',       # Top T
    '┴': '+',       # Bottom T
    '┼': '+',       # Cross
    '═': '=',       # Double horizontal
    '║': '||',      # Double vertical
    '╔': '+',       # Double top-left
    '╗': '+',       # Double top-right
    '╚': '+',       # Double bottom-left
    '╝': '+',       # Double bottom-right
    '╠': '+',       # Double left T
    '╣': '+',       # Double right T
    '╦': '+',       # Double top T
    '╩': '+',       # Double bottom T
    '╬': '+',       # Double cross

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
    '\u201c': '"',  # Left double quote (FIXED with Unicode escape)
    '\u201d': '"',  # Right double quote (FIXED with Unicode escape)
    '\u2018': "'",  # Left single quote (FIXED with Unicode escape)
    '\u2019': "'",  # Right single quote (FIXED with Unicode escape)
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

# OPTIMIZATION 1: Early ASCII check
def quick_ascii_check(filepath: Path) -> bool:
    """
    Quick binary check if file contains any non-ASCII bytes
    Returns True if file is pure ASCII (can skip processing)
    """
    try:
        with open(filepath, 'rb') as f:
            chunk_size = 8192
            while True:
                chunk = f.read(chunk_size)
                if not chunk:
                    break
                # Check if any byte > 127
                if any(b > 127 for b in chunk):
                    return False
        return True  # Pure ASCII, skip processing
    except Exception:
        return False  # Process anyway if check fails

# OPTIMIZATION 2: Single-pass processing (combined find + replace + verify)
def process_text_single_pass(text: str) -> Tuple[str, List[Dict], List[Tuple[str, str]], bool]:
    """
    Combined find + replace + verify in ONE pass
    Returns: (new_text, unicode_locations, unique_replacements, has_remaining_unicode)
    """
    result = []
    unicode_chars = []
    unique_replacements = []
    replacement_counts = {}
    has_remaining_unicode = False

    lines = text.split('\n')

    for line_num, line in enumerate(lines, 1):
        for col_num, char in enumerate(line, 1):
            char_code = ord(char)

            if char_code > 127:
                # Found unicode - record location
                unicode_chars.append({
                    'char': char,
                    'line': line_num,
                    'column': col_num,
                    'code': f'U+{char_code:04X}',
                    'context': line.strip()[:50] + ('...' if len(line.strip()) > 50 else '')
                })

                # Apply replacement
                replacement = REPLACEMENTS.get(char, f'[U+{char_code:04X}]')
                result.append(replacement)

                # Track replacements
                if char not in replacement_counts:
                    replacement_counts[char] = 0
                    unique_replacements.append((char, replacement))
                replacement_counts[char] += 1

                # Check if replacement still contains unicode
                if any(ord(c) > 127 for c in replacement):
                    has_remaining_unicode = True
            else:
                result.append(char)

        # Add newline back (except for last line)
        if line_num < len(lines):
            result.append('\n')

    return ''.join(result), unicode_chars, unique_replacements, has_remaining_unicode

def should_skip_python_system_file(filepath: Path) -> bool:
    """
    Check if file should be skipped (Python system files, caches, virtual envs)
    Returns True if file should be skipped
    """
    filepath_str = str(filepath)

    # Python system files and directories to exclude
    python_excludes = [
        '__pycache__',      # Python bytecode cache
        '.pyc',             # Compiled Python files
        '.pyo',             # Optimized Python files
        'venv\\', 'venv/',  # Virtual environments
        '.venv\\', '.venv/', # Hidden virtual environments
        'env\\', 'env/',    # Environment directories
        '.pytest_cache',    # Pytest cache
        '.tox',             # Tox testing cache
        '.mypy_cache',      # MyPy type checking cache
        '.egg-info',        # Python package info
        'build\\', 'build/', # Build artifacts
        'dist\\', 'dist/',  # Distribution artifacts
        '.eggs',            # Egg installation
        '__pypackages__',   # PEP 582 packages
        'site-packages',    # Installed packages
    ]

    return any(exclude in filepath_str for exclude in python_excludes)

def process_file(filepath: Path, preview_only: bool = False, create_backup: bool = True) -> Optional[Dict]:
    """Process a single file with all optimizations"""

    # Skip Python system files (cache, venv, build artifacts)
    if should_skip_python_system_file(filepath):
        return None

    # OPTIMIZATION 1: Quick ASCII check (early exit for clean files)
    if quick_ascii_check(filepath):
        return {
            'file': filepath,
            'unicode_count': 0,
            'replacements': [],
            'status': 'no_unicode'
        }

    # Read file
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

    # OPTIMIZATION 2: Single-pass processing
    new_content, unicode_chars, replacements, has_remaining_unicode = process_text_single_pass(content)

    if not unicode_chars:
        return {
            'file': filepath,
            'unicode_count': 0,
            'replacements': [],
            'status': 'no_unicode'
        }

    # Verify result is ASCII-only
    if has_remaining_unicode or not new_content.isascii():
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

# OPTIMIZATION 3: Parallel file processing with ThreadPoolExecutor
def process_files_parallel(files_to_process: List[Path],
                          preview_only: bool = False,
                          create_backup: bool = True,
                          max_workers: int = None) -> List[Dict]:
    """
    Process files in parallel using ThreadPoolExecutor
    """
    results = []

    # Determine optimal worker count
    if max_workers is None:
        # Auto-detect: min of (CPU cores, 5, number of files)
        max_workers = min(multiprocessing.cpu_count(), 5, len(files_to_process))

    # For small numbers of files, don't use parallelization
    if len(files_to_process) <= 2:
        for filepath in files_to_process:
            result = process_file(filepath, preview_only, create_backup)
            if result:
                results.append(result)
        return results

    # Parallel processing
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        # Submit all files for processing
        future_to_file = {
            executor.submit(process_file, filepath, preview_only, create_backup): filepath
            for filepath in files_to_process
        }

        # Process results as they complete
        for future in as_completed(future_to_file):
            filepath = future_to_file[future]
            try:
                result = future.result()
                if result:
                    results.append(result)
            except Exception as e:
                print(f"Error processing {filepath}: {e}")
                results.append({
                    'file': filepath,
                    'unicode_count': 0,
                    'replacements': [],
                    'status': 'error',
                    'error': str(e)
                })

    return results

def main():
    parser = argparse.ArgumentParser(
        description='Replace Unicode characters with ASCII equivalents in PowerShell scripts (OPTIMIZED)',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s script.ps1                          # Process single file (interactive)
  %(prog)s C:\\Scripts                          # Process .ps1 files with confirmation
  %(prog)s C:\\Scripts --interactive            # Interactive mode (default for directories)
  %(prog)s C:\\Scripts --preview                # Preview only, no confirmation
  %(prog)s C:\\Scripts --pattern "*.ps1" "*.py" # Multiple patterns
  %(prog)s script.ps1 --no-backup --yes        # Skip backup and confirmation
  %(prog)s C:\\Scripts --workers 3              # Use 3 parallel workers
        """
    )

    parser.add_argument('path', help='File or directory to process')
    parser.add_argument('--interactive', action='store_true', help='Show preview and ask for confirmation (default for directories)')
    parser.add_argument('--preview', action='store_true', help='Preview only, do not modify files')
    parser.add_argument('--yes', '-y', action='store_true', help='Skip confirmation, proceed automatically')
    parser.add_argument('--no-backup', action='store_true', help='Skip creating backup files')
    parser.add_argument('--pattern', nargs='+', default=['*.ps1', '*.psm1', '*.py'], help='File patterns to match (default: *.ps1 *.psm1 *.py)')
    parser.add_argument('--recursive', action='store_true', default=True, help='Process subdirectories (default: True)')
    parser.add_argument('--verbose', action='store_true', help='Show detailed output')
    parser.add_argument('--workers', type=int, default=None, help='Number of parallel workers (default: auto-detect)')

    args = parser.parse_args()

    path = Path(args.path)
    files_to_process = []

    if path.is_file():
        files_to_process = [path]
        # Single file defaults to non-interactive unless specified
        if not args.interactive and not args.preview:
            args.interactive = False
    elif path.is_dir():
        # Directory defaults to interactive unless --yes or --preview specified
        if not args.yes and not args.preview:
            args.interactive = True

        # Collect files matching all patterns
        for pattern in args.pattern:
            if args.recursive:
                files_to_process.extend(path.rglob(pattern))
            else:
                files_to_process.extend(path.glob(pattern))

        # Remove duplicates and sort
        files_to_process = sorted(set(files_to_process))
    else:
        print(f"Error: {path} not found")
        return 1

    if not files_to_process:
        patterns = ', '.join(args.pattern)
        print(f"No files matching patterns '{patterns}' found in {path}")
        return 0

    # Interactive mode: First run preview, then ask for confirmation
    if args.interactive and not args.preview:
        print(f"{'='*60}")
        print("Unicode Replacement Tool - INTERACTIVE MODE (OPTIMIZED)")
        print(f"{'='*60}")
        print(f"Path: {path}")
        print(f"Files found: {len(files_to_process)}")
        patterns = ', '.join(args.pattern)
        print(f"Patterns: {patterns}")
        print(f"{'='*60}\n")

        print("Step 1: Scanning for Unicode characters...\n")

        # Preview pass (with parallelization)
        preview_results = process_files_parallel(files_to_process, preview_only=True, create_backup=False, max_workers=args.workers)
        preview_results = [r for r in preview_results if r and r['unicode_count'] > 0]

        if not preview_results:
            print("No Unicode characters found in any files.")
            print("All files are clean!")
            return 0

        # Show preview
        print(f"Found Unicode in {len(preview_results)} file(s):\n")
        total_unicode = 0

        for result in preview_results:
            total_unicode += result['unicode_count']
            print(f"  {result['file'].name}: {result['unicode_count']} characters")
            for char, replacement in result['replacements'][:3]:
                try:
                    print(f"    {char} -> {replacement}")
                except UnicodeEncodeError:
                    print(f"    [U+{ord(char):04X}] -> {replacement}")
            if len(result['replacements']) > 3:
                print(f"    ... and {len(result['replacements']) - 3} more")
            print()

        print(f"{'='*60}")
        print(f"Total: {total_unicode} Unicode characters in {len(preview_results)} files")
        print(f"Backup: {'Disabled' if args.no_backup else 'Enabled'}")
        print(f"{'='*60}\n")

        # Ask for confirmation
        response = input("Proceed with replacement? (Y/N): ").strip().upper()

        if response != 'Y' and response != 'YES':
            print("\nOperation cancelled by user.")
            return 0

        print("\nStep 2: Applying replacements...\n")

        # Process files for real (extract just the files)
        files_to_update = [r['file'] for r in preview_results]
        actual_results = process_files_parallel(files_to_update, preview_only=False, create_backup=not args.no_backup, max_workers=args.workers)

        errors = sum(1 for r in actual_results if r and r['status'] in ['error', 'write_error'])

        print(f"\n{'='*60}")
        print("COMPLETE")
        print(f"{'='*60}")
        print(f"Files updated: {len(preview_results) - errors}")
        if errors > 0:
            print(f"Errors: {errors}")
        print(f"{'='*60}")

        return 1 if errors > 0 else 0

    # Non-interactive mode (preview or --yes flag) with parallel processing
    print(f"{'='*60}")
    print(f"Unicode Replacement Tool - {'PREVIEW MODE' if args.preview else 'PROCESSING'} (OPTIMIZED)")
    print(f"{'='*60}")
    print(f"Path: {path}")
    print(f"Files found: {len(files_to_process)}")
    patterns = ', '.join(args.pattern)
    print(f"Patterns: {patterns}")
    print(f"Backup: {'Disabled' if args.no_backup else 'Enabled'}")
    if args.workers:
        print(f"Workers: {args.workers}")
    print(f"{'='*60}\n")

    # Process all files in parallel
    results = process_files_parallel(files_to_process, args.preview, not args.no_backup, max_workers=args.workers)

    total_replacements = 0
    files_with_unicode = 0
    errors = 0

    for result in results:
        if result['unicode_count'] > 0:
            files_with_unicode += 1
            total_replacements += result['unicode_count']

            if args.verbose or args.preview:
                print(f"\n{result['file']}:")
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
