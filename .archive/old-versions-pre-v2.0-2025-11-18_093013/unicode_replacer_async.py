#!/usr/bin/env python3
"""
Unicode Replacer - ASYNC VERSION (aiofiles + asyncio)
Testing if async I/O provides performance gains over ThreadPoolExecutor
"""

import asyncio
import aiofiles
import multiprocessing
from pathlib import Path
from typing import List, Dict
import time

# Import existing optimizations
from unicode_replacer_optimized import (
    REPLACEMENTS,
    process_text_single_pass,
    quick_ascii_check
)


async def process_file_async(filepath: Path, preview_only: bool = False) -> Dict:
    """
    Async version of file processing using aiofiles for non-blocking I/O
    """
    start_time = time.perf_counter()

    try:
        # Quick ASCII check (still synchronous but fast - binary read)
        if quick_ascii_check(filepath):
            return {
                'file': str(filepath),
                'replacements': 0,
                'unicode_chars': [],
                'status': 'clean',
                'time_ms': (time.perf_counter() - start_time) * 1000,
                'early_exit': True
            }

        # ASYNC: Read file content
        async with aiofiles.open(filepath, 'r', encoding='utf-8') as f:
            content = await f.read()

        # Process content (CPU-bound, still synchronous)
        new_content, unicode_chars, replacements_list, has_remaining_unicode = process_text_single_pass(content)
        replacement_count = len(unicode_chars)

        if replacement_count > 0 and not preview_only and not has_remaining_unicode:
            # ASYNC: Write back to disk
            async with aiofiles.open(filepath, 'w', encoding='ascii') as f:
                await f.write(new_content)

        return {
            'file': str(filepath),
            'replacements': replacement_count,
            'unicode_chars': unicode_chars,
            'status': 'success' if replacement_count > 0 else 'clean',
            'time_ms': (time.perf_counter() - start_time) * 1000,
            'early_exit': False
        }

    except Exception as e:
        return {
            'file': str(filepath),
            'replacements': -1,
            'unicode_chars': [],
            'status': f'error: {str(e)}',
            'time_ms': (time.perf_counter() - start_time) * 1000,
            'early_exit': False
        }


async def process_files_async_batch(files_to_process: List[Path],
                                     preview_only: bool = False,
                                     max_concurrent: int = None) -> List[Dict]:
    """
    Process files concurrently using asyncio
    """
    if max_concurrent is None:
        # Auto-detect: use CPU count for optimal concurrency
        max_concurrent = min(multiprocessing.cpu_count() * 2, 20, len(files_to_process))

    # Create semaphore to limit concurrent operations
    semaphore = asyncio.Semaphore(max_concurrent)

    async def process_with_semaphore(filepath):
        async with semaphore:
            return await process_file_async(filepath, preview_only)

    # Process all files concurrently
    tasks = [process_with_semaphore(filepath) for filepath in files_to_process]
    results = await asyncio.gather(*tasks)

    return results


def process_files_async(files_to_process: List[Path],
                        preview_only: bool = False,
                        max_concurrent: int = None) -> List[Dict]:
    """
    Wrapper to run async processing from synchronous code
    """
    return asyncio.run(process_files_async_batch(files_to_process, preview_only, max_concurrent))
