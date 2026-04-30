#!/usr/bin/env python3
"""
Quick benchmark for OPTIMIZED unicode_replacer_optimized.py
"""

import time
import tempfile
import shutil
from pathlib import Path
import random

# Test unicode characters
UNICODE_CHARS = ['✓', '✔', '✗', '→', '←', '🔧', '📁', '💾', '⚠', 'ℹ']

def create_test_file(filepath: Path, num_lines: int, unicode_percent: float):
    """Create a test PowerShell file"""
    lines = []
    for i in range(num_lines):
        line = f'Write-Host "Processing item {i} - test line with content"'
        if random.random() < unicode_percent:
            pos = random.randint(0, len(line))
            char = random.choice(UNICODE_CHARS)
            line = line[:pos] + char + line[pos:]
        lines.append(line)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

def main():
    print("="*70)
    print("QUICK BENCHMARK - OPTIMIZED Implementation")
    print("="*70)

    # Import the optimized unicode_replacer
    import unicode_replacer_optimized as unicode_replacer

    # Test scenarios
    scenarios = [
        {'name': 'Small clean (100 lines, 0% unicode)', 'lines': 100, 'files': 10, 'unicode': 0.0},
        {'name': 'Small dirty (100 lines, 20% unicode)', 'lines': 100, 'files': 10, 'unicode': 0.20},
        {'name': 'Medium clean (1K lines, 0% unicode)', 'lines': 1000, 'files': 5, 'unicode': 0.0},
        {'name': 'Medium dirty (1K lines, 15% unicode)', 'lines': 1000, 'files': 5, 'unicode': 0.15},
        {'name': 'Large mixed (5K lines, 10% unicode)', 'lines': 5000, 'files': 3, 'unicode': 0.10},
    ]

    results = []

    for scenario in scenarios:
        print(f"\nTest: {scenario['name']}")
        print("-" * 70)

        with tempfile.TemporaryDirectory() as tmpdir:
            tmppath = Path(tmpdir)

            # Create test files
            files = []
            for i in range(scenario['files']):
                filepath = tmppath / f"test_{i}.ps1"
                create_test_file(filepath, scenario['lines'], scenario['unicode'])
                files.append(filepath)

            total_lines = scenario['lines'] * scenario['files']
            print(f"  Files: {scenario['files']}")
            print(f"  Total lines: {total_lines:,}")

            # Warm up
            _ = unicode_replacer.process_files_parallel(files[:1], preview_only=True, create_backup=False, max_workers=1)

            # Benchmark
            times = []
            for run in range(3):
                start = time.perf_counter()
                results_batch = unicode_replacer.process_files_parallel(files, preview_only=True, create_backup=False, max_workers=5)
                end = time.perf_counter()
                elapsed = end - start
                times.append(elapsed)
                print(f"  Run {run + 1}: {elapsed:.4f}s")

            avg_time = sum(times) / len(times)
            throughput = total_lines / avg_time

            print(f"  Average: {avg_time:.4f}s")
            print(f"  Throughput: {throughput:,.0f} lines/sec")

            results.append({
                'scenario': scenario['name'],
                'files': scenario['files'],
                'lines': total_lines,
                'time': avg_time,
                'throughput': throughput
            })

    # Summary
    print("\n" + "="*70)
    print("OPTIMIZED PERFORMANCE SUMMARY")
    print("="*70)
    print(f"\n{'Scenario':<40} {'Time (s)':<12} {'Throughput'}")
    print("-" * 70)

    total_time = 0
    total_lines = 0

    for r in results:
        total_time += r['time']
        total_lines += r['lines']
        print(f"{r['scenario']:<40} {r['time']:>10.4f}  {r['throughput']:>10,.0f} lines/s")

    print("-" * 70)
    overall_throughput = total_lines / total_time
    print(f"{'TOTAL':<40} {total_time:>10.4f}  {overall_throughput:>10,.0f} lines/s")

    print("\n" + "="*70)
    print("Optimized measurement complete!")
    print("="*70)

if __name__ == '__main__':
    main()
